//
//  Feeder+Function.swift
//  
//
//  Created by Artur Hellmann on 14.07.23.
//

import Foundation

extension Feeder {
    func handleFunction(parameters: [Parameter], function: ((String) throws -> String), in template: String) throws -> String {
        let pattern = #"\(\s*"?([^"]*)"?\s*\)"#
        
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        
        let matches = regex.matches(in: template, options: [], range: NSRange(location: 0, length: template.utf16.count))
        
        guard let match = matches.first else  {
            return template
        }
        
        var result = String(template[Range(match.range(at: 1), in: template)!])
        result = try self.recursiveFeed(parameters: parameters, into: result)
        result = try function(result)
        
        return result
    }
}
