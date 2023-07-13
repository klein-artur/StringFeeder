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
}
