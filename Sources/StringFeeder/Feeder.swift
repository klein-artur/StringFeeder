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
    
    public init(parameterIndicator: Indicator = .dollar) {
        self.parameterIndicator = parameterIndicator.rawValue
    }
    
    private let nestedOpenParantesesPlaceholder = UUID().uuidString
    private let nestedCloseParantesesPlaceholder = UUID().uuidString
    private let nestedParantesesIndicatorPlaceholder = UUID().uuidString
    private let doubleQuotesPlaceholder = UUID().uuidString
    private let semicolonPlaceholder = UUID().uuidString
    
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
        
        var result = template.restoreNestedParentheses(
            openPlaceholder: nestedOpenParantesesPlaceholder,
            closePlaceholder: nestedCloseParantesesPlaceholder,
            indicatorPlaceholder: nestedParantesesIndicatorPlaceholder,
            doubleQuotesPlaceholder: doubleQuotesPlaceholder,
            semicolonPlaceholder: semicolonPlaceholder,
            indicator: self.parameterIndicator
        )
        
        try checkForbiddenCharacters(parameters: parameters)
        
        result = placeholders.reduce(result, { (partialResult, content) in
            partialResult.replacingOccurrences(of: content.value.0, with: content.key)
        })
        
        result = result.replaceNestedParentheses(
            openPlaceholder: nestedOpenParantesesPlaceholder,
            closePlaceholder: nestedCloseParantesesPlaceholder,
            indicatorPlaceholder: nestedParantesesIndicatorPlaceholder,
            doubleQuotesPlaceholder: doubleQuotesPlaceholder,
            semicolonPlaceholder: semicolonPlaceholder,
            indicator: self.parameterIndicator
        )
        
        result = try feedParameters(parameters: parameters, into: result)
        
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
                case .string(let value):
                    result.replaceSubrange(Range(match.range(at: 1), in: result)!, with: value)
                case .integer(let value):
                    result.replaceSubrange(Range(match.range(at: 1), in: result)!, with: String(value))
                case .boolean(let value):
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
            let toReplace: String
            if let set {
                toReplace = try self.handleIfSet(parameters: parameters, set: set, in: result)
            } else {
                toReplace = try self.handleIf(parameters: parameters, in: result)
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
