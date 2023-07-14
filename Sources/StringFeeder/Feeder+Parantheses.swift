//
//  Feeder+Parantheses.swift
//  
//
//  Created by Artur Hellmann on 14.07.23.
//

import Foundation

extension Feeder {
    func handleParantheses(parameters: [Parameter], in template: String) throws -> String {
        let pattern = #"\(([^)]*)\)"#
        var result = template
        
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        
        let matches = regex.matches(in: result, options: [], range: NSRange(location: 0, length: template.utf16.count))
        
        for match in matches.reversed() { // reversed to prevent range problem
            
            let foundContent = try self.recursiveFeed(parameters: parameters, into: String(template[Range(match.range(at: 1), in: result)!]))
            
            result.replaceSubrange(
                Range(match.range(at: 1), in: result)!,
                with: foundContent
            )
        
        }
        
        return result
    }
}
