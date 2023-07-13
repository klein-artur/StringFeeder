//
//  Feeder+Boolean.swift
//  
//
//  Created by Artur Hellmann on 13.07.23.
//

import Foundation

extension Feeder {
    func handleBoolean(value: Bool, in template: String) throws -> String? {
        let pattern = #"\("(.*)";\s*"(.*)"\)"#
        
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        
        let matches = regex.matches(in: template, options: [], range: NSRange(location: 0, length: template.utf16.count))
        
        guard let match = matches.first else  {
            return nil
        }
        
        let trueCondition = String(template[Range(match.range(at: 1), in: template)!])
        let falseCondition = String(template[Range(match.range(at: 2), in: template)!])
        
        return value ? trueCondition : falseCondition
    }
}
