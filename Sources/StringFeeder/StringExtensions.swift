//
//  StringExtensions.swift.swift
//  
//
//  Created by Artur Hellmann on 13.07.23.
//

import Foundation

extension String {
    var isValidParamNameByCharacters: Bool {
        let allowedCharacterSet = Feeder.allowedCharacters
        let inputStringCharacterSet = CharacterSet(charactersIn: self)

        return allowedCharacterSet.isSuperset(of: inputStringCharacterSet)
    }
    var isValidParamNameByKey: Bool {
        !Feeder.forbiddenKeywords.contains(self)
    }
    
    func replaceNestedParentheses(openPlaceholder: String, closePlaceholder: String, indicatorPlaceholder: String, indicator: Character) -> String {
        var result = self
        var depth = 0
        var index = result.startIndex

        while index < result.endIndex {
            let character = result[index]
            switch character {
            case "(":
                depth += 1
                if depth >= 2 {
                    result.replaceSubrange(index...index, with: openPlaceholder)
                    index = result.index(index, offsetBy: openPlaceholder.count - 1) // "- 1" to offset for the removed "("
                }
            case ")":
                if depth >= 2 {
                    result.replaceSubrange(index...index, with: closePlaceholder)
                    index = result.index(index, offsetBy: closePlaceholder.count - 1) // "- 1" to offset for the removed ")"
                }
                depth -= 1
            case indicator:
                if depth >= 1 {
                    result.replaceSubrange(index...index, with: indicatorPlaceholder)
                    index = result.index(index, offsetBy: indicatorPlaceholder.count - 1) // "- 1" to offset for the removed ")"
                }
            default:
                break
            }
            index = result.index(after: index)
        }

        return result
    }
    
    func restoreNestedParentheses(openPlaceholder: String, closePlaceholder: String, indicatorPlaceholder: String, indicator: Character) -> String {
        var result = self
        result = result.replacingOccurrences(of: openPlaceholder, with: "(")
        result = result.replacingOccurrences(of: closePlaceholder, with: ")")
        result = result.replacingOccurrences(of: indicatorPlaceholder, with: String(indicator))
        return result
    }

}
