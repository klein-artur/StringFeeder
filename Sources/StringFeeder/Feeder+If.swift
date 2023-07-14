//
//  Feeder+If.swift
//  
//
//  Created by Artur Hellmann on 14.07.23.
//

import Foundation

extension Feeder {
    private static let ifClausePattern = #"\(\s*([a-zA-Z0-9-_]+)\s*;\s*"?([^"]*)"?\s*;\s*"?([^"]*)"?\s*\)"#
    
    func handleIfSet(parameters: [Parameter], set: Bool, in template: String) throws -> String {
        let regex = try NSRegularExpression(pattern: Self.ifClausePattern, options: [])
        
        let matches = regex.matches(in: template, options: [], range: NSRange(location: 0, length: template.utf16.count))
        
        guard let match = matches.first else  {
            return template
        }
        
        let name = String(template[Range(match.range(at: 1), in: template)!])
        let contains = parameters.contains { $0.name == name }
        
        if (set ? contains : !contains) {
            return try self.feed(parameters: parameters, into: String(template[Range(match.range(at: 2), in: template)!]))
        } else {
            return try self.feed(parameters: parameters, into: String(template[Range(match.range(at: 3), in: template)!]))
        }
    }
    
    func handleIf(parameters: [Parameter], in template: String) throws -> String {
        let regex = try NSRegularExpression(pattern: Self.ifClausePattern, options: [])
        
        let matches = regex.matches(in: template, options: [], range: NSRange(location: 0, length: template.utf16.count))
        
        guard let match = matches.first else  {
            return template
        }
        
        let name = String(template[Range(match.range(at: 1), in: template)!])
        
        if let parameter = parameters.first(where: { $0.name == name }), case let .boolean(value) = parameter.value, value {
            return try self.feed(parameters: parameters, into: String(template[Range(match.range(at: 2), in: template)!]))
        } else {
            return try self.feed(parameters: parameters, into: String(template[Range(match.range(at: 3), in: template)!]))
        }
    }
}
