//
//  StringFeederBooleanTests.swift
//  
//
//  Created by Artur Hellmann on 13.07.23.
//

import XCTest
@testable import StringFeeder

final class StringFeederBooleanTests: XCTestCase {
    var sut: Feeder!
    
    override func setUpWithError() throws {
        sut = Feeder()
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }

    func testSimpleBooleanInjection() throws {
        // given
        let string = "This boolean should be $some_bool."
        let parameters = [
            Feeder.Parameter(name: "some_bool", value: Feeder.Value.boolean(true))
        ]
        
        // when
        let result = try sut.feed(parameters: parameters, into: string)
        
        // then
        XCTAssertEqual(result, "This boolean should be true.")
    }
    
    func testConditionalReplaceWithWrongBackets() throws {
        // given
        let string = "This boolean should be $some_bool(\"with wrong brackets\")."
        let parameters = [
            Feeder.Parameter(name: "some_bool", value: Feeder.Value.boolean(true))
        ]
        
        // when
        let result = try sut.feed(parameters: parameters, into: string)
        
        // then
        XCTAssertEqual(result, "This boolean should be true(\"with wrong brackets\").")
    }
    
    func testConditionalReplaceWithCorrectBrackets() throws {
        // given
        let string = "This boolean should be $some_bool(\"with correct brackets\"; \"with wrong brackets\")."
        let parameters = [
            Feeder.Parameter(name: "some_bool", value: Feeder.Value.boolean(true))
        ]
        
        // when
        let result = try sut.feed(parameters: parameters, into: string)
        
        // then
        XCTAssertEqual(result, "This boolean should be with correct brackets.")
    }
    
    func testConditionalReplaceWithCorrectBracketswithoutSpace() throws {
        // given
        let string = "This boolean should be $some_bool(\"with correct brackets\";\"with wrong brackets\")."
        let parameters = [
            Feeder.Parameter(name: "some_bool", value: Feeder.Value.boolean(false))
        ]
        
        // when
        let result = try sut.feed(parameters: parameters, into: string)
        
        // then
        XCTAssertEqual(result, "This boolean should be with wrong brackets.")
    }
    
    func testConditionalReplaceWithBracketInCondition() throws {
        // given
        let string = "This boolean should be $some_bool(\"with correct brackets\";\"with wrong \\(\\) brackets\")."
        let parameters = [
            Feeder.Parameter(name: "some_bool", value:  Feeder.Value.boolean(false))
        ]
        
        // when
        let result = try sut.feed(parameters: parameters, into: string)
        
        // then
        XCTAssertEqual(result, "This boolean should be with wrong () brackets.")
    }
    
    func testConditionalReplaceWithDoubleQuotInCondition() throws {
        // given
        let string = "This boolean should be $some_bool(\"with correct brackets\";\"with wrong \\\" brackets\")."
        let parameters = [
            Feeder.Parameter(name: "some_bool", value: Feeder.Value.boolean(false))
        ]
        
        // when
        let result = try sut.feed(parameters: parameters, into: string)
        
        // then
        XCTAssertEqual(result, "This boolean should be with wrong \" brackets.")
    }
    
    func testConditionalReplaceWithConditionWithParam() throws {
        // given
        let string = "This boolean should be $some_bool(\"$some_true_string\";\"$some_wrong_string\")."
        let parameters = [
            Feeder.Parameter(name: "some_true_string", value: Feeder.Value.string("is True")),
            Feeder.Parameter(name: "some_wrong_string", value: Feeder.Value.string("is False")),
            Feeder.Parameter(name: "some_bool", value: Feeder.Value.boolean(false))
        ]
        
        // when
        let result = try sut.feed(parameters: parameters, into: string)
        
        // then
        XCTAssertEqual(result, "This boolean should be is False.")
    }
    
    func testConditionalReplaceWithConditionWithParamDifferentOrder() throws {
        // given
        let string = "This boolean should be $some_bool(\"$some_true_string\";\"$some_wrong_string\")."
        let parameters = [
            Feeder.Parameter(name: "some_bool", value: Feeder.Value.boolean(false)),
            Feeder.Parameter(name: "some_true_string", value: Feeder.Value.string("is True")),
            Feeder.Parameter(name: "some_wrong_string", value: Feeder.Value.string("is False"))
        ]
        
        // when
        let result = try sut.feed(parameters: parameters, into: string)
        
        // then
        XCTAssertEqual(result, "This boolean should be is False.")
    }
    
    func testSomeComplexConditionReplacement() throws {
        // given
        let string = "This boolean should be $some_bool(\"$some_true_value(\"yes\";\"no\")\";\"$some_wrong_string\")."
        let parameters = [
            Feeder.Parameter(name: "some_true_value", value: Feeder.Value.boolean(true)),
            Feeder.Parameter(name: "some_wrong_string", value: Feeder.Value.string("is False")),
            Feeder.Parameter(name: "some_bool", value: Feeder.Value.boolean(false))
        ]
        
        // when
        let result = try sut.feed(parameters: parameters, into: string)
        
        // then
        XCTAssertEqual(result, "This boolean should be is False.")
    }
    
    func testSomeComplexConditionReplacementWithNestedParanteses() throws {
        // given
        let string = "This boolean should be $some_bool(\"$some_true_value(\"yes\";\"no\")\";\"$some_wrong_string\")."
        let parameters = [
            Feeder.Parameter(name: "some_true_value", value: Feeder.Value.boolean(true)),
            Feeder.Parameter(name: "some_wrong_string", value: Feeder.Value.string("is False")),
            Feeder.Parameter(name: "some_bool", value: Feeder.Value.boolean(true))
        ]
        
        // when
        let result = try sut.feed(parameters: parameters, into: string)
        
        // then
        XCTAssertEqual(result, "This boolean should be yes.")
    }

}
