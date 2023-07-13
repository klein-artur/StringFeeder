//
//  StringFeederIfSetUnsetTests.swift
//  
//
//  Created by Artur Hellmann on 14.07.23.
//

import XCTest
@testable import StringFeeder

final class StringFeederIfSetUnsetTests: XCTestCase {
    var sut: Feeder!
    
    override func setUpWithError() throws {
        sut = Feeder()
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }

    func testIfSetAndSet() throws {
        // given
        let params = [
            Feeder.Parameter(name: "field_set", value: .string("is set"))
        ]
        let testString = "This string $ifSet(field_set; \"$field_set\"; \"should not be set\")."
        
        // when
        let result = try sut.feed(parameters: params, into: testString)
        
        // then
        XCTAssertEqual(result, "This string is set.")
    }
    
    func testIfSetAndUnset() throws {
        // given
        let params = [
            Feeder.Parameter(name: "field_set_other", value: .string("is not set"))
        ]
        let testString = "This string $ifSet(field_set; \"should be set\"; \"$field_set_other\")."
        
        // when
        let result = try sut.feed(parameters: params, into: testString)
        
        // then
        XCTAssertEqual(result, "This string is not set.")
    }
    
    func testIfUnsetAndSet() throws {
        // given
        let params = [
            Feeder.Parameter(name: "field_set", value: .string("is set"))
        ]
        let testString = "This string $ifNotSet(field_set; \"$field_set\"; \"should not be set\")."
        
        // when
        let result = try sut.feed(parameters: params, into: testString)
        
        // then
        XCTAssertEqual(result, "This string should not be set.")
    }
    
    func testIfUnsetAndUnset() throws {
        // given
        let params = [
            Feeder.Parameter(name: "field_set_other", value: .string("is not set"))
        ]
        let testString = "This string $ifNotSet(field_set; \"should be set\"; \"$field_set_other\")."
        
        // when
        let result = try sut.feed(parameters: params, into: testString)
        
        // then
        XCTAssertEqual(result, "This string should be set.")
    }
    
    func testIfSetAndSet_withNestingBool() throws {
        // given
        let params = [
            Feeder.Parameter(name: "field_set", value: .string("is set")),
            Feeder.Parameter(name: "bool_if_true", value: .boolean(true))
        ]
        let testString = "This string $ifSet(field_set; \"$bool_if_true(\"is set with nesting bool\";\"this is wrong\")\"; \"should not be set\")."
        
        // when
        let result = try sut.feed(parameters: params, into: testString)
        
        // then
        XCTAssertEqual(result, "This string is set with nesting bool.")
    }
    
    func testIfUnsetAndSet_withNestingBoolButOtherTaken() throws {
        // given
        let params = [
            Feeder.Parameter(name: "field_set", value: .string("is set")),
            Feeder.Parameter(name: "bool_if_true", value: .boolean(true))
        ]
        let testString = "This string $ifNotSet(field_set; \"$bool_if_true(\"is set with nesting bool\";\"this is wrong\")\"; \"should not be set\")."
        
        // when
        let result = try sut.feed(parameters: params, into: testString)
        
        // then
        XCTAssertEqual(result, "This string should not be set.")
    }
    
    func testBooleanIfTrue() throws {
        // given
        let params = [
            Feeder.Parameter(name: "field_set", value: .boolean(true)),
            Feeder.Parameter(name: "true_output", value: .string("is TrueMan")),
            Feeder.Parameter(name: "false_output", value: .string("is FalseMan"))
        ]
        let testString = "This string $if(field_set; \"$true_output\"; \"$false_output\")."
        
        // when
        let result = try sut.feed(parameters: params, into: testString)
        
        // then
        XCTAssertEqual(result, "This string is TrueMan.")
    }
    
    func testBooleanIfFalse() throws {
        // given
        let params = [
            Feeder.Parameter(name: "field_set", value: .boolean(false)),
            Feeder.Parameter(name: "true_output", value: .string("is TrueMan")),
            Feeder.Parameter(name: "false_output", value: .string("is FalseMan"))
        ]
        let testString = "This string $if(field_set; \"$true_output\"; \"$false_output\")."
        
        // when
        let result = try sut.feed(parameters: params, into: testString)
        
        // then
        XCTAssertEqual(result, "This string is FalseMan.")
    }
    
    func testBooleanButNoBoolean() throws {
        // given
        let params = [
            Feeder.Parameter(name: "field_set", value: .string("false")),
            Feeder.Parameter(name: "true_output", value: .string("is TrueMan")),
            Feeder.Parameter(name: "false_output", value: .string("is FalseMan"))
        ]
        let testString = "This string $if(field_set; \"$true_output\"; \"$false_output\")."
        
        // when
        let result = try sut.feed(parameters: params, into: testString)
        
        // then
        XCTAssertEqual(result, "This string is FalseMan.")
    }

}
