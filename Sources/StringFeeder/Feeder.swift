//
//  Feeder.swift
//  
//
//  Created by Artur Hellmann on 13.07.23.
//

import Foundation


class Feeder {
    
    static let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-")
    static let forbiddenKeywords = [
        "if"
    ]
    
    private static let paramRegex = "(?!if)([a-zA-Z0-9_-]+)"
    
    enum Value {
        case string(String)
        case boolean(Bool)
        case integer(Int)
    }
    
    enum FeedingError: Error {
        case containsForbiddenCharacter(String)
        case keyForbidden(String)
    }
    
    let parameterIndicator: String
    
    init(parameterIndicator: String = "$") {
        self.parameterIndicator = parameterIndicator
    }
    
    func feed(parameters: [String: Value], into template: String) throws -> String {
        
        try checkForbiddenCharacters(parameters: parameters)
        
        // Create a mutable copy of the string
        var result = template
        
        // Handle escaped placeholders by replacing "$$" with a temporary placeholder
        let escapedCommandPlaceholder = "\u{FFFF}"
        // let escapedBrackedPlaceholder = "\u{FFFE}" // "\u{FFF0}""\u{0FFF}""\u{1FFF}"
        
        result = result.replacingOccurrences(of: "\\\(parameterIndicator)", with: escapedCommandPlaceholder)
        
        result = try feedParameters(parameters: parameters, into: result)
        
        // Replace the temporary placeholder with "$"
        result = result.replacingOccurrences(of: escapedCommandPlaceholder, with: "\(parameterIndicator)")
        
        return result
    }
    
    private func feedParameters(parameters: [String: Value], into template: String) throws -> String {
        var result = template
        
        let pattern = regexablePatternIndicator + Self.paramRegex
        
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        
        let matches = regex.matches(in: result, options: [], range: NSRange(location: 0, length: result.utf16.count))
        
        for match in matches.reversed() { // reversed to prevent range problem
            let paramNameRange = Range(match.range(at: 1), in: result)!
            let paramName = String(result[paramNameRange])
            
            guard let paramValue = parameters[paramName] else {
                continue
            }
            
            var replacement: String
            switch paramValue {
            case .string(let value):
                replacement = value
            case .integer(let value):
                replacement = String(value)
            case .boolean(let value):
                replacement = String(value)
            }
            
            // Perform the replacement
            result.replaceSubrange(Range(match.range, in: result)!, with: replacement)
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
