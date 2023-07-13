import XCTest
@testable import StringFeeder

final class StringFeederTests: XCTestCase {
    var sut: Feeder!
    
    override func setUpWithError() throws {
        sut = Feeder()
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testShouldThrowForbiddenCharsError() throws {
        // given:
        let parameters = [
            "string value": Feeder.Value.string("very cool string")
        ]
        
        // when:
        do {
            _ = try sut.feed(parameters: parameters, into: "")
        } catch {
            // then
            guard let error = error as? Feeder.FeedingError else {
                XCTFail("Should have thrown Feeding Error.")
                return
            }
            switch error {
            case let .containsForbiddenCharacter(field):
                XCTAssertEqual(field, "string value")
            default: XCTFail("Wrong error thrown.")
            }
            return
        }
        
        XCTFail("Should have thrown an error.")
    }
    
    func testShouldThrowForbiddenKeyError() throws {
        // given:
        let parameters = [
            "ifSet": Feeder.Value.string("very cool string")
        ]
        
        // when:
        do {
            _ = try sut.feed(parameters: parameters, into: "")
        } catch {
            // then
            guard let error = error as? Feeder.FeedingError else {
                XCTFail("Should have thrown Feeding Error.")
                return
            }
            switch error {
            case let .keyForbidden(field):
                XCTAssertEqual(field, "ifSet")
            default: XCTFail("Wrong error thrown.")
            }
            return
        }
        
        XCTFail("Should have thrown an error.")
    }
    
    func testShouldThrowForbiddenKeyIfNotSetError() throws {
        // given:
        let parameters = [
            "ifNotSet": Feeder.Value.string("very cool string")
        ]
        
        // when:
        do {
            _ = try sut.feed(parameters: parameters, into: "")
        } catch {
            // then
            guard let error = error as? Feeder.FeedingError else {
                XCTFail("Should have thrown Feeding Error.")
                return
            }
            switch error {
            case let .keyForbidden(field):
                XCTAssertEqual(field, "ifNotSet")
            default: XCTFail("Wrong error thrown.")
            }
            return
        }
        
        XCTFail("Should have thrown an error.")
    }
    
    func testSimpleStringFeed() throws {
        // given:
        let testString = "This is some $string_value."
        let parameters = [
            "string_value": Feeder.Value.string("very cool string")
        ]
        
        // when:
        let result = try sut.feed(parameters: parameters, into: testString)
        
        // then:
        XCTAssertEqual(result, "This is some very cool string.")
    }
    
    func testSimpleIntegerFeed() throws {
        // given:
        let testString = "This is some $int_value."
        let parameters = [
            "int_value": Feeder.Value.integer(5)
        ]
        
        // when:
        let result = try sut.feed(parameters: parameters, into: testString)
        
        // then:
        XCTAssertEqual(result, "This is some 5.")
    }
    
    func testSimpleMultipleFeed() throws {
        // given:
        let testString = "This is some $int_value. It will also be here $int_value. And the string will be \"$string_value\""
        let parameters = [
            "int_value": Feeder.Value.integer(5),
            "string_value": Feeder.Value.string("very cool string")
        ]
        
        // when:
        let result = try sut.feed(parameters: parameters, into: testString)
        
        // then:
        XCTAssertEqual(result, "This is some 5. It will also be here 5. And the string will be \"very cool string\"")
    }
    
    func testEscaping() throws {
        // given:
        let testString = "This is some \\$int_value. It will also be here $int_value. And the string will be \"$string_value\""
        let parameters = [
            "int_value": Feeder.Value.integer(5),
            "string_value": Feeder.Value.string("very cool string")
        ]
        
        // when:
        let result = try sut.feed(parameters: parameters, into: testString)
        
        // then:
        XCTAssertEqual(result, "This is some $int_value. It will also be here 5. And the string will be \"very cool string\"")
    }
    
    func testDifferentIndicator() throws {
        // given:
        sut = Feeder(parameterIndicator: "%")
        let testString = "This is some \\%int_value. It will also be here %int_value. And the string will be \"%string_value\""
        let parameters = [
            "int_value": Feeder.Value.integer(5),
            "string_value": Feeder.Value.string("very cool string")
        ]
        
        // when:
        let result = try sut.feed(parameters: parameters, into: testString)
        
        // then:
        XCTAssertEqual(result, "This is some %int_value. It will also be here 5. And the string will be \"very cool string\"")
    }
    
    func testSimpleStringWithBrackets_ShouldNotReplace() throws {
        // given:
        let testString = "This is some $string_value(\"with some\",\"nichts\"."
        let parameters = [
            "string_value": Feeder.Value.string("very cool string")
        ]
        
        // when:
        let result = try sut.feed(parameters: parameters, into: testString)
        
        // then:
        XCTAssertEqual(result, "This is some very cool string(\"with some\",\"nichts\".")
    }
    
}

