//
//  Feeder+Boolean.swift
//  
//
//  Created by Artur Hellmann on 13.07.23.
//

import Foundation

extension Feeder {
    func handleBoolean(parameters: [Parameter], value: Bool, in template: String) throws -> String? {
        let pattern = #"\(\s*"?([^"]*)"?\s*;\s*"?([^"]*)"?\s*\)"#
        
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        
        let matches = regex.matches(in: template, options: [], range: NSRange(location: 0, length: template.utf16.count))
        
        guard let match = matches.first else  {
            return nil
        }
        
        if value {
            return try self.recursiveFeed(parameters: parameters, into: String(template[Range(match.range(at: 1), in: template)!]))
        } else {
            return try self.recursiveFeed(parameters: parameters, into: String(template[Range(match.range(at: 2), in: template)!]))
        }
    }
}
 
 
