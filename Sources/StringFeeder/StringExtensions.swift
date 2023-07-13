//
//  StringExtensions.swift.swift
//  
//
//  Created by Artur Hellmann on 13.07.23.
//

import Foundation

extension String {
    var isValidParamName: Bool {
        let allowedCharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-")
        let inputStringCharacterSet = CharacterSet(charactersIn: self)

        return allowedCharacterSet.isSuperset(of: inputStringCharacterSet)
    }
}
