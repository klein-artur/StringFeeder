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
            "some_bool": Feeder.Value.boolean(true)
        ]
        
        // when
        let result = try sut.feed(parameters: parameters, into: string)
        
        // then
        XCTAssertEqual(result, "This boolean should be true.")
    }

}
