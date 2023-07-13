//
//  Feeder.swift
//  
//
//  Created by Artur Hellmann on 13.07.23.
//

import Foundation

public class Feeder {
    
    static let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-")
    static let forbiddenKeywords = [
        "if"
    ]
    
    private static func paramRegex(indicator: String, name: String) -> String {
        "(" + indicator + #"(?!if)"# + name + #")(?:\(.*\))?"#
    }
    
    public enum Value {
        case string(String)
        case boolean(Bool)
        case integer(Int)
    }
    
    enum FeedingError: Error {
        case containsForbiddenCharacter(String)
        case keyForbidden(String)
    }
    
    let parameterIndicator: String
    
    public init(parameterIndicator: String = "$") {
        self.parameterIndicator = parameterIndicator
    }
    
    private var placeholders: [String: (String, String)] {
        [
            "\u{FFFF}pi": ("\\\(parameterIndicator)", parameterIndicator),
            "\u{FFFF}ob": ("\\(", "("),
            "\u{FFFF}cb": ("\\)", ")"),
            "\u{FFFF}dq": ("\\\"", "\"")
        ]
    }
    
    public func feed(parameters: [String: Value], into template: String) throws -> String {
        
        try checkForbiddenCharacters(parameters: parameters)
        
        // Create a mutable copy of the string
        var result = template
        
        result = placeholders.reduce(result, { (partialResult, content) in
            partialResult.replacingOccurrences(of: content.value.0, with: content.key)
        })
        
        result = try feedParameters(parameters: parameters, into: result)
        
        result = placeholders.reduce(result, { (partialResult, content) in
            partialResult.replacingOccurrences(of: content.key, with: content.value.1)
        })
        
        return result
    }
    
    private func feedParameters(parameters: [String: Value], into template: String) throws -> String {
        var result = template
        
        for (paramName, paramValue) in parameters {
            let pattern = Self.paramRegex(indicator: regexablePatternIndicator, name: paramName)
            
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            
            let matches = regex.matches(in: result, options: [], range: NSRange(location: 0, length: result.utf16.count))
            
            for match in matches.reversed() { // reversed to prevent range problem
                
                guard let paramValue = parameters[paramName] else {
                    continue
                }
                
                var replacement: String
                switch paramValue {
                case .string(let value):
                    result.replaceSubrange(Range(match.range(at: 1), in: result)!, with: value)
                case .integer(let value):
                    result.replaceSubrange(Range(match.range(at: 1), in: result)!, with: String(value))
                case .boolean(let value):
                    if let booleanResult = try handleBoolean(value: value, in: String(result[Range(match.range, in: result)!])) {
                        result.replaceSubrange(Range(match.range, in: result)!, with: booleanResult)
                    } else {
                        result.replaceSubrange(Range(match.range(at: 1), in: result)!, with: String(value))
                    }
                }
            
            }
        }
        
        return result
    }
    
    private func checkForbiddenCharacters(parameters: [String: Value]) throws {
        for (key, _) in parameters {
            if !key.isValidParamNameByCharacters {
                throw FeedingError.containsForbiddenCharacter(key)
            }
            if !key.isValidParamNameByKey {
                throw FeedingError.keyForbidden(key)
            }
        }
    }
    
    private var regexablePatternIndicator: String {
        // Check if patternIndicator is a special character that needs escaping
        let specialCharacters = ["$", "(", ")", "{", "}", "[", "]", "^", "$", ".", "|", "?", "*", "+", "\\"]
        if specialCharacters.contains(parameterIndicator) {
            return "\\\(parameterIndicator)"
        } else {
            return "\(parameterIndicator)"
        }
    }
}
