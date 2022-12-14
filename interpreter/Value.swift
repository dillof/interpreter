/*
  Value.swift -- The Result of an Expression, the Contents of a Variable
  Copyright (C) Dieter Baron

  This file is part of the interpreter for a rather verbose
  programming language (made up entierly of english words)
  The authors can be contacted at <dillo@nih.at>

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions
  are met:
  1. Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.
  2. The names of the authors may not be used to endorse or promote
     products derived from this software without specific prior
     written permission.

  THIS SOFTWARE IS PROVIDED BY THE AUTHORS ``AS IS'' AND ANY EXPRESS
  OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY
  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
  IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
  IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import Foundation

enum Value : Equatable, CustomStringConvertible {
    case Integer(Int)
    case Real(Double)
    case Boolean(Bool)
    case Nothing

    var description: String {
        switch self {
        case .Integer(let v):
            return format(v).joined(separator: " ")
        case .Real(let v):
            return format(v).joined(separator: " ")
        case .Boolean(let v):
            return v ? "true" : "false"
        case .Nothing:
            return "nothing"
        }
    }
    
    static func == (left: Value, right: Value) -> Bool {
        switch (left, right) {
        case (.Integer(let l), .Integer(let r)):
            return l == r
        case (.Integer(let l), .Real(let r)):
            return Double(l) == r
        case (.Real(let l), .Integer(let r)):
            return l == Double(r)
        case (.Real(let l), .Real(let r)):
            return l == r
        case (.Boolean(let l), .Boolean(let r)):
            return l == r
        case (.Nothing, .Nothing):
            return true
        default:
            return false
        }
    }
    
    static func < (left: Value, right: Value) throws -> Bool {
        switch (left, right) {
        case (.Integer(let l), .Integer(let r)):
            return l < r
        case (.Integer(let l), .Real(let r)):
            return Double(l) < r
        case (.Real(let l), .Integer(let r)):
            return l < Double(r)
        case (.Real(let l), .Real(let r)):
            return l < r
        default:
            throw RuntimeError.InvalidTypeForOperation
        }
    }
    
    static func <= (left: Value, right: Value) throws -> Bool {
        return try left < right || left == right
    }
    
    static func > (left: Value, right: Value) throws -> Bool {
        return try !(left <= right)
    }

    static func >= (left: Value, right: Value) throws -> Bool {
        return try !(left < right)
    }
    
    private func format(_ integer: Int) -> [String] {
        var words = [String]()
        
        var v = integer
        
        if v < 0 {
            words.append("minus")
            v = -v
        }

        for magnitude in Value.magnitudes {
            if v > magnitude.value {
                words.append(contentsOf: format(v / magnitude.value))
                words.append(magnitude.name)
                v = v % magnitude.value
            }
        }
        if (v >= 20) {
            words.append(Value.tensWords[v / 10 - 2])
            v = v % 10
        }
        if (v > 0 || words.isEmpty) {
            words.append(Value.onesWords[v])
        }
        
        return words
    }
    
    private func format(_ real: Double) -> [String] {
        var words = [String]()
        
        var v = real
        
        if v < 0 {
            words.append("minus")
            v = -v
        }
        let integer = Int(v)
        var fraction = abs(v - Double(integer))
        words.append(contentsOf: format(integer))
        if fraction != 0 {
            words.append("dot")
            
            while fraction != 0 {
                fraction *= 10
                let digit = Int(fraction)
                words.append(Value.onesWords[digit])
                fraction -= Double(digit)
            }
        }
        
        return words
    }
    
    
    private static let magnitudes = [
        (name: "quintillion", value: 1000000000000000000),
        (name: "quadrillion", value: 1000000000000000),
        (name: "trillion", value: 1000000000000),
        (name: "billion", value: 1000000000),
        (name: "million", value: 1000000),
        (name: "thousand", value: 1000),
        (name: "hundred", value: 100)
    ]

    private static let tensWords = [
        "twenty", "thirty", "fourty", "fifty", "sixty", "seventy", "eighty", "ninety"
    ]

    private static let onesWords = [
        "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
        "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"
    ]
}
