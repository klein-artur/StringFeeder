//
//  Feeder.swift
//  
//
//  Created by Artur Hellmann on 13.07.23.
//

import Foundation

public class Feeder {
    
    public struct Parameter {
        let name: String
        let value: Value
        
        public init(name: String, value: Value) {
            self.name = name
            self.value = value
        }
    }
    
    public static let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-")
    public static let forbiddenKeywords = [
        "ifSet",
        "ifNotSet",
        "if"
    ]
    
    private static func paramRegex(indicator: String, name: String) -> String {
        "(" + indicator + #"(?!ifSet)(?!ifNotSet)(?!if)"# + name + #")(?:\([^)]*\))?"#
    }
    
    private static func ifSetRegex(indicator: String, ifCase: String) -> String {
        indicator + ifCase + #"(?:\([^)]*\))?"#
    }
    
    public enum Value {
        case string(String)
        case boolean(Bool)
        case integer(Int)
        case converter((String) throws -> String)
    }
    
    public enum FeedingError: Error {
        case containsForbiddenCharacter(String)
        case keyForbidden(String)
    }
    
    public enum Indicator: Character {
        case dollar = "$"
        case percent = "%"
    }
    
    let parameterIndicator: Character
    
    private var deepness: Int = 0
    
    public init(parameterIndicator: Indicator = .dollar) {
        self.parameterIndicator = parameterIndicator.rawValue
    }
    
    let nestedOpenParantesesPlaceholder = UUID().uuidString
    let nestedCloseParantesesPlaceholder = UUID().uuidString
    let nestedParantesesIndicatorPlaceholder = UUID().uuidString
    let doubleQuotesPlaceholder = UUID().uuidString
    let semicolonPlaceholder = UUID().uuidString
    
    private let commentHashtagPlaceholder = UUID().uuidString
    
    private lazy var placeholders: [String: (String, String)] = {
        [
            UUID().uuidString: ("\\\\", "\\"),
            UUID().uuidString: ("\\\(parameterIndicator)", String(parameterIndicator)),
            UUID().uuidString: ("\\(", "("),
            UUID().uuidString: ("\\)", ")"),
            UUID().uuidString: ("\\;", ";"),
            UUID().uuidString: ("\\\"", "\"")
        ]
    }()
    
    public func feed(parameters: [Parameter], into template: String) throws -> String {
        return try recursiveFeed(parameters: parameters, into: template)
    }
    
    func recursiveFeed(parameters: [Parameter], into template: String) throws -> String {

        var result = ruleOutComments(template: template)
        
        result = self.restoreNestedParentheses(template: result)
        
        try checkForbiddenCharacters(parameters: parameters)
        
        result = placeholders.reduce(result, { (partialResult, content) in
            partialResult.replacingOccurrences(of: content.value.0, with: content.key)
        })
        
        result = self.replaceNestedParentheses(template: result)
        
        result = try feedParameters(parameters: parameters, into: result)
        
        result = try handleParantheses(parameters: parameters, in: result)
        
        result = self.restoreNestedParentheses(template: result)
        
        result = placeholders.reduce(result, { (partialResult, content) in
            partialResult.replacingOccurrences(of: content.key, with: content.value.1)
        })
        
        return result
    }
    
    private func feedParameters(parameters: [Parameter], into template: String) throws -> String {
        var result = template
        
        result = try checkForIfs(parameters: parameters, into: result, set: true)
        result = try checkForIfs(parameters: parameters, into: result, set: false)
        result = try checkForIfs(parameters: parameters, into: result, set: nil)
        
        for parameter in parameters {
            let paramName = parameter.name
            let paramValue = parameter.value
            
            let pattern = Self.paramRegex(indicator: regexablePatternIndicator, name: paramName)
            
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            
            let matches = regex.matches(in: result, options: [], range: NSRange(location: 0, length: result.utf16.count))
            
            for match in matches.reversed() { // reversed to prevent range problem
                
                switch paramValue {
                case let .string(value):
                    result.replaceSubrange(Range(match.range(at: 1), in: result)!, with: value)
                case let .integer(value):
                    result.replaceSubrange(Range(match.range(at: 1), in: result)!, with: String(value))
                case let .converter(function):
                    result.replaceSubrange(
                        Range(match.range, in: result)!,
                        with: try handleFunction(parameters: parameters, function: function, in: String(result[Range(match.range, in: result)!]))
                    )
                case let .boolean(value):
                    if let booleanResult = try handleBoolean(parameters: parameters, value: value, in: String(result[Range(match.range, in: result)!])) {
                        result.replaceSubrange(Range(match.range, in: result)!, with: booleanResult)
                    } else {
                        result.replaceSubrange(Range(match.range(at: 1), in: result)!, with: String(value))
                    }
                }
            
            }
        }
        
        return result
    }
    
    private func checkForIfs(parameters: [Parameter], into template: String, set: Bool?) throws -> String {
        var result = template
        
        let ifCase: String
        if let set {
            ifCase = set ? "ifSet" : "ifNotSet"
        } else {
            ifCase = "if"
        }
        
        let pattern = Self.ifSetRegex(indicator: regexablePatternIndicator, ifCase: ifCase)
        
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        
        let matches = regex.matches(in: result, options: [], range: NSRange(location: 0, length: result.utf16.count))
        
        for match in matches.reversed() {
            let ifClause = String(result[Range(match.range, in: result)!])
            let toReplace: String
            if let set {
                toReplace = try self.handleIfSet(parameters: parameters, set: set, in: ifClause)
            } else {
                toReplace = try self.handleIf(parameters: parameters, in: ifClause)
            }
            result.replaceSubrange(Range(match.range(at: 0), in: result)!, with: toReplace)
        }
        
        return result
    }
    
    private func checkForbiddenCharacters(parameters: [Parameter]) throws {
        for parameter in parameters {
            if !parameter.name.isValidParamNameByCharacters {
                throw FeedingError.containsForbiddenCharacter(parameter.name)
            }
            if !parameter.name.isValidParamNameByKey {
                throw FeedingError.keyForbidden(parameter.name)
            }
        }
    }
    
    private func replaceNestedParentheses(
        template: String
    ) -> String {
        var result = template
        var depth = 0
        var index = result.startIndex

        while index < result.endIndex {
            let character = result[index]
            switch character {
            case "(":
                depth += 1
                if depth >= 2 {
                    result.replaceSubrange(index...index, with: nestedOpenParantesesPlaceholder)
                    index = result.index(index, offsetBy: nestedOpenParantesesPlaceholder.count - 1) // "- 1" to offset for the removed "("
                }
            case ")":
                if depth >= 2 {
                    result.replaceSubrange(index...index, with: nestedCloseParantesesPlaceholder)
                    index = result.index(index, offsetBy: nestedCloseParantesesPlaceholder.count - 1) // "- 1" to offset for the removed ")"
                }
                depth -= 1
            case parameterIndicator:
                if depth >= 1 {
                    result.replaceSubrange(index...index, with: nestedParantesesIndicatorPlaceholder)
                    index = result.index(index, offsetBy: nestedParantesesIndicatorPlaceholder.count - 1) // "- 1" to offset for the removed ")"
                }
            case "\"":
                if depth >= 2 {
                    result.replaceSubrange(index...index, with: doubleQuotesPlaceholder)
                    index = result.index(index, offsetBy: doubleQuotesPlaceholder.count - 1) // "- 1" to offset for the removed ")"
                }
            case ";":
                if depth >= 2 {
                    result.replaceSubrange(index...index, with: semicolonPlaceholder)
                    index = result.index(index, offsetBy: semicolonPlaceholder.count - 1) // "- 1" to offset for the removed ")"
                }
            default:
                break
            }
            index = result.index(after: index)
        }

        return result
    }
    
    private func restoreNestedParentheses(
        template: String
    ) -> String {
        var result = template
        result = result.replacingOccurrences(of: nestedOpenParantesesPlaceholder, with: "(")
        result = result.replacingOccurrences(of: nestedCloseParantesesPlaceholder, with: ")")
        result = result.replacingOccurrences(of: nestedParantesesIndicatorPlaceholder, with: String(parameterIndicator))
        result = result.replacingOccurrences(of: doubleQuotesPlaceholder, with: String("\""))
        result = result.replacingOccurrences(of: semicolonPlaceholder, with: String(";"))
        return result
    }
    
    private var regexablePatternIndicator: String {
        // Check if patternIndicator is a special character that needs escaping
        let specialCharacters = ["$"]
        if specialCharacters.contains(String(parameterIndicator)) {
            return "\\\(parameterIndicator)"
        } else {
            return "\(parameterIndicator)"
        }
    }
}

extension Feeder.Value: Equatable {
    public static func == (lhs: Feeder.Value, rhs: Feeder.Value) -> Bool {
        switch (lhs, rhs) {
        case let (.string(a), .string(b)):
            return a == b
        case let (.boolean(a), .boolean(b)):
            return a == b
        case let (.integer(a), .integer(b)):
            return a == b
        case (.converter, .converter):
            return true
        default:
            return false
        }
    }
}

extension Feeder.Parameter: Hashable {
    public static func == (lhs: StringFeeder.Feeder.Parameter, rhs: StringFeeder.Feeder.Parameter) -> Bool {
        lhs.name == rhs.name && lhs.value == rhs.value
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        switch self.value {
        case let .string(value):
            hasher.combine(value)
        case let .boolean(value):
            hasher.combine(value)
        case let .integer(value):
            hasher.combine(value)
        default: break
        }
    }
}
