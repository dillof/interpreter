//
//  Value.swift
//  interpreter-tests
//
//  Created by Dieter Baron on 22/08/05.
//

import XCTest

class ValueTests: XCTestCase {
    enum ComparisionResult: Equatable {
        case Error(RuntimeError)
        case Result(Bool)
    }


    func testComparisonEqual() throws {
        let tests: [(left: Value, right: Value, result: Bool)] = [
            (left: .Integer(5), right: .Integer(5), result: true),
            (left: .Integer(0), right: .Integer(1), result: false),
            
            (left: .Real(-7.5), right: .Real(-7.5), result: true),
            (left: .Real(0), right: .Real(2.5), result: false),
            
            (left: .Integer(3), right: .Real(3), result: true),
            (left: .Real(4), right: .Integer(4), result: true),
            
            (left: .Integer(5), right: .Real(-5), result: false),
            (left: .Real(1.5), right: .Integer(1), result: false),
            
            (left: .Boolean(true), right: .Boolean(true), result: true),
            (left: .Boolean(false), right: .Boolean(true), result: false),
            
            (left: .Nothing, right: .Nothing, result: true),
            
            (left: .Boolean(false), right: .Integer(0), result: false)
        ]
            
        for test in tests {
            let actual_result = test.left == test.right
            XCTAssert(actual_result == test.result, "'\(test.left)' == '\(test.right)' resulted in \(actual_result), expected \(test.result)")
        }
    }
    
    func testComparisonLess() throws {
        let tests: [(left: Value, right: Value, result: ComparisionResult)] = [
            (left: .Integer(-1), right: .Integer(5), result: .Result(true)),
            (left: .Integer(17), right: .Integer(17), result: .Result(false)),

            (left: .Boolean(false), right: .Boolean(true), result: .Error(.InvalidTypeForOperation)),
            (left: .Nothing, right: .Nothing, result: .Error(.InvalidTypeForOperation))
        ]

        for test in tests {
            var actual_result: ComparisionResult
            do {
                actual_result = .Result(try test.left < test.right)
            }
            catch let error as RuntimeError {
                actual_result = .Error(error)
            }

            XCTAssert(actual_result == test.result, "'\(test.left)' < '\(test.right)' resulted in \(actual_result), expected \(test.result)")
        }
    }
    
    
    func testOutputBool() throws {
        let tests = [
            (value: true, description: "true"),
            (value: false, description: "false")
        ]

        for test in tests {
            let actual_description = Value.Boolean(test.value).description
            XCTAssert(actual_description == test.description, "formatting \(test.value) resulted in '\(actual_description)', expected '\(test.description)'")
        }
    }
    
    
    func testOutputInteger() throws {
        let tests = [
            (value: -1, description: "minus one"),
            (value: 0, description: "zero"),
            (value: 1, description: "one"),
            (value: 2, description: "two"),
            (value: 3, description: "three"),
            (value: 4, description: "four"),
            (value: 5, description: "five"),
            (value: 6, description: "six"),
            (value: 7, description: "seven"),
            (value: 8, description: "eight"),
            (value: 9, description: "nine"),
            (value: 10, description: "ten"),
            (value: 11, description: "eleven"),
            (value: 12, description: "twelve"),
            (value: 13, description: "thirteen"),
            (value: 14, description: "fourteen"),
            (value: 15, description: "fifteen"),
            (value: 16, description: "sixteen"),
            (value: 17, description: "seventeen"),
            (value: 18, description: "eighteen"),
            (value: 19, description: "nineteen"),
            (value: 20, description: "twenty"),
            (value: 30, description: "thirty"),
            (value: 40, description: "fourty"),
            (value: 50, description: "fifty"),
            (value: 60, description: "sixty"),
            (value: 70, description: "seventy"),
            (value: 80, description: "eighty"),
            (value: 90, description: "ninety"),
            (value: 1234567890123456789, description: "one quintillion two hundred thirty four quadrillion five hundred sixty seven trillion eight hundred ninety billion one hundred twenty three million four hundred fifty six thousand seven hundred eighty nine")
        ]
        
        for test in tests {
            let actual_description = Value.Integer(test.value).description
            XCTAssert(actual_description == test.description, "formatting \(test.value) resulted in '\(actual_description)', expected '\(test.description)'")
        }
    }
    
    
    func testOutputNothing() throws {
        let tests = [
            (value: Value.Nothing, description: "nothing")
        ]

        for test in tests {
            let actual_description = test.value.description
            XCTAssert(actual_description == test.description, "formatting \(test.value) resulted in '\(actual_description)', expected '\(test.description)'")
        }
    }

    
    
    func testOutputReal() throws {
        let tests = [
            (value: 0, description: "zero"),
            (value: 1.5, description: "one dot five"),
            (value: -0.25, description: "minus zero dot two five")
        ]

        for test in tests {
            let actual_description = Value.Real(test.value).description
            XCTAssert(actual_description == test.description, "formatting \(test.value) resulted in '\(actual_description)', expected '\(test.description)'")
        }
    }
}
