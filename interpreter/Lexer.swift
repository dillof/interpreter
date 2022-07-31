//
//  Lexer.swift
//  interpreter
//
//  Created by Dieter Baron on 22/07/31.
//

import Foundation

class MyLexer: Sequence {
    struct Position {
        var lineNumber = 1
        var startPosition = 1
        var endPosition = 1
        
        mutating func stepLine() {
            lineNumber += 1
            startPosition = 1
        }
        
        mutating func stepStart() {
            startPosition += 1
        }
        
        mutating func start() {
            endPosition = startPosition
        }
        
        mutating func stepEnd() {
            endPosition += 1
        }
    }
    struct Result {
        init(token: TokenData, code: Parser.CitronTokenCode, position: Position = Position()) {
            self.token = token
            self.code = code
            self.position = position
        }
        var token: TokenData
        var code: Parser.CitronTokenCode
        var position: Position
    }
    struct Iterator: IteratorProtocol {
        typealias Element = Result
        
        init(_ source: MyLexer) {
            self.source = source
            self.sourceIterator = source.text.makeIterator()
        }
        
        mutating func next() -> Element? {
            // skip whitespace
            while let c = nextCharacter() {
                if c == "\n" {
                    currentPosition.stepLine()
                }
                if isWhitespace(c) {
                    currentPosition.stepStart()
                }
                else if isLetter(c) {
                    break
                }
                else {
                    // TODO: handle illegal character
                    currentPosition.stepStart()
                }
            }
            
            var word = ""
            
            currentPosition.start()
            
            while let c = nextCharacter(), isLetter(c) {
                word += String(c)
                currentPosition.stepEnd()
            }
            
            if word.isEmpty {
                return nil
            }
            
            word = word.lowercased()
            
            return source.result(from: word, position: currentPosition)
        }
        
        private mutating func nextCharacter() -> Character? {
            if let c = putBack {
                return c
            }
            else {
                return sourceIterator.next()
            }
        }
        
        private mutating func putBack(_ c: Character) {
            putBack = c
        }
        
        private func isWhitespace(_ c: Character) -> Bool {
            return c == " " || c == "\n" || c == "\r" || c == "\t" // TODO: include form feed (others?)
        }
        
        private func isLetter(_ c: Character) -> Bool {
            return (c >= "a" && c <= "z") || (c >= "A" && c <= "Z")
        }

        private var currentPosition = Position()

        private var source: MyLexer
        private var sourceIterator: String.Iterator
        private var putBack: Character?
    }
    
    init(text: String) {
        self.text = text
    }
    
    func makeIterator() -> Iterator {
        return Iterator(self)
    }
    
    private func result(from word: String, position: Position) -> Result {
        if var result = MyLexer.keywords[word] {
            result.position = position
            return result
        }
        // TODO: check for known word
        return Result(token: .Word(word), code: .WORD, position: position)
    }
    
    var text: String
    
    static let keywords = [
        "add": Result(token: .Keyword, code: .ADD),
        "and":  Result(token: .Keyword, code: .AND),
        "by": Result(token: .Keyword, code: .BY),
        "call": Result(token: .Keyword, code: .CALL),
        "divide": Result(token: .Keyword, code: .DIVIDE),
        "done": Result(token: .Keyword, code: .DONE),
        "do": Result(token: .Keyword, code: .DO),
        "dot": Result(token: .Keyword, code: .DOT),
        "else": Result(token: .Keyword, code: .ELSE),
        "equal": Result(token: .Keyword, code: .EQUAL),
        "false": Result(token: .Keyword, code: .FALSE),
        "from": Result(token: .Keyword, code: .FROM),
        "function": Result(token: .Keyword, code: .FUNCTION),
        "greater": Result(token: .Keyword, code: .GREATER),
        "hundred": Result(token: .Keyword, code: .HUNDRED),
        "if": Result(token: .Keyword, code: .IF),
        "is": Result(token: .Keyword, code: .IS),
        "less": Result(token: .Keyword, code: .LESS),
        "millon": Result(token: .Keyword, code: .MILLON),
        "minus": Result(token: .Keyword, code: .MINUS),
        "multiply": Result(token: .Keyword, code: .MULTIPLY),
        "nothing": Result(token: .Keyword, code: .NOTHING),
        "not": Result(token: .Keyword, code: .NOT),
        "of": Result(token: .Keyword, code: .OF),
        "or": Result(token: .Keyword, code: .OR),
        "print": Result(token: .Keyword, code: .PRINT),
        "return": Result(token: .Keyword, code: .RETURN),
        "set": Result(token: .Keyword, code: .SET),
        "subtract": Result(token: .Keyword, code: .SUBTRACT),
        "than": Result(token: .Keyword, code: .THAN),
        "then": Result(token: .Keyword, code: .THEN),
        "thousand": Result(token: .Keyword, code: .THOUSAND),
        "to": Result(token: .Keyword, code: .TO),
        "true": Result(token: .Keyword, code: .TRUE),
        "value": Result(token: .Keyword, code: .VALUE),
        "with": Result(token: .Keyword, code: .WITH),
        "word": Result(token: .Keyword, code: .WORD),
        
        "zero": Result(token: .Number(0), code: .ONES),
        "one": Result(token: .Number(1), code: .ONES),
        "two": Result(token: .Number(2), code: .ONES),
        "three": Result(token: .Number(3), code: .ONES),
        "four": Result(token: .Number(4), code: .ONES),
        "five": Result(token: .Number(5), code: .ONES),
        "six": Result(token: .Number(6), code: .ONES),
        "seven": Result(token: .Number(7), code: .ONES),
        "eight": Result(token: .Number(8), code: .ONES),
        "nine": Result(token: .Number(9), code: .ONES),
        
        "ten": Result(token: .Number(10), code: .TEENS),
        "eleven": Result(token: .Number(11), code: .TEENS),
        "twelve": Result(token: .Number(12), code: .TEENS),
        "thirteen": Result(token: .Number(13), code: .TEENS),
        "fourteen": Result(token: .Number(14), code: .TEENS),
        "fifteen": Result(token: .Number(15), code: .TEENS),
        "sixteen": Result(token: .Number(16), code: .TEENS),
        "seventeen": Result(token: .Number(17), code: .TEENS),
        "eighteen": Result(token: .Number(18), code: .TEENS),
        "nineteen": Result(token: .Number(19), code: .TEENS),
        
        "twenty": Result(token: .Number(20), code: .TENS),
        "thirty": Result(token: .Number(30), code: .TENS),
        "fourty": Result(token: .Number(40), code: .TENS),
        "fifty": Result(token: .Number(50), code: .TENS),
        "sixty": Result(token: .Number(60), code: .TENS),
        "seventy": Result(token: .Number(70), code: .TENS),
        "eighty": Result(token: .Number(80), code: .TENS),
        "ninety": Result(token: .Number(90), code: .TENS)
    ]
}
