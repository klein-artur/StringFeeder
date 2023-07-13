//
//  StringExtensionsTests.swift
//  
//
//  Created by Artur Hellmann on 13.07.23.
//

import XCTest
@testable import StringFeeder

final class StringExtensionsTests: XCTestCase {
    func testParanthesisEscaping() throws {
        // given
        let openPlaceholder = UUID().uuidString
        let closePlaceholder = UUID().uuidString
        let indicator: Character = "$"
        let indicatorPlaceholder = UUID().uuidString
        let doubleQuotesPlaceholder = UUID().uuidString
        let semicolonPlaceholder = UUID().uuidString
        let testString = "test string (\(indicator)some(internal(parantheses)are)there) test (other(paranthesis(that(should)be)escaped)correctly) test"
        let resultString = "test string (\(indicatorPlaceholder)some\(openPlaceholder)internal\(openPlaceholder)parantheses\(closePlaceholder)are\(closePlaceholder)there) test (other\(openPlaceholder)paranthesis\(openPlaceholder)that\(openPlaceholder)should\(closePlaceholder)be\(closePlaceholder)escaped\(closePlaceholder)correctly) test"
        
        // when
        let result = testString.replaceNestedParentheses(
            openPlaceholder: openPlaceholder,
            closePlaceholder: closePlaceholder,
            indicatorPlaceholder: indicatorPlaceholder,
            doubleQuotesPlaceholder: doubleQuotesPlaceholder,
            semicolonPlaceholder: semicolonPlaceholder,
            indicator: indicator
        )
        
        // then
        XCTAssertEqual(result, resultString)
    }
    
    func testRestoreNestedParantheses() throws {
        // given
        let openPlaceholder = UUID().uuidString
        let closePlaceholder = UUID().uuidString
        let indicator: Character = "$"
        let indicatorPlaceholder = UUID().uuidString
        let doubleQuotesPlaceholder = UUID().uuidString
        let semicolonPlaceholder = UUID().uuidString
        let resultString = "test string (\(indicator)some(internal(parantheses)are)there) test (other(paranthesis(that(should)be)escaped)correctly) test"
        let testString = "test string (\(indicatorPlaceholder)some\(openPlaceholder)internal\(openPlaceholder)parantheses\(closePlaceholder)are\(closePlaceholder)there) test (other\(openPlaceholder)paranthesis\(openPlaceholder)that\(openPlaceholder)should\(closePlaceholder)be\(closePlaceholder)escaped\(closePlaceholder)correctly) test"
        
        // when
        let result = testString.restoreNestedParentheses(
            openPlaceholder: openPlaceholder,
            closePlaceholder: closePlaceholder,
            indicatorPlaceholder: indicatorPlaceholder,
            doubleQuotesPlaceholder: doubleQuotesPlaceholder,
            semicolonPlaceholder: semicolonPlaceholder,
            indicator: indicator
        )
        
        // then
        XCTAssertEqual(result, resultString)
    }
}
