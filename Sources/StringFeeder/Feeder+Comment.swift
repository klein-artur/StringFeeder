//
//  File.swift
//  
//
//  Created by Artur Hellmann on 14.07.23.
//

import Foundation

extension Feeder {
    func ruleOutComments(template: String) -> String {
        let escapedHashtagPlaceholder = UUID().uuidString
        
        var text = template.replacingOccurrences(of: "\\#", with: escapedHashtagPlaceholder)
        let lines = text.components(separatedBy: "\n")
        var resultLines = [String]()
        for i in 0..<lines.count {
            let line = lines[i]
            var parts = line.components(separatedBy: "#")
            parts = parts.enumerated().compactMap { (index, part) in index % 2 == 0 ? part : nil }
            resultLines.append(parts.joined(separator: ""))
        }
        text = resultLines.joined(separator: "\n")
        text = text.replacingOccurrences(of: escapedHashtagPlaceholder, with: "#")
        
        return text
    }

}
