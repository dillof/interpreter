/*
  Lexer.swift -- Converting the Program Text into a Series of Tokens
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

class Lexer: Sequence {
    enum LexerError : LocalizedError {
        case InvalidCharacter(Character)
        case UnknownWord(String)
    }

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
    
    struct ResultOk {
        init(token: TokenData, code: Parser.CitronTokenCode, position: Position = Position()) {
            self.token = token
            self.code = code
            self.position = position
        }
        var token: TokenData
        var code: Parser.CitronTokenCode
        var position: Position
    }
    
    struct ResultError {
        init (error: LexerError, position: Position = Position()) {
            self.error = error
            self.position = position
        }
        
        var error: LexerError
        var position: Position
    }
    
    enum Result {
        case Ok(ResultOk)
        case Error(ResultError)
    }
    
    struct Iterator: IteratorProtocol {
        typealias Element = Result
        
        init(_ source: Lexer) {
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
                    putBack(c)
                    break
                }
                else {
                    currentPosition.stepEnd()
                    return source.result(from: .InvalidCharacter(c), position: currentPosition)
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
                putBack = nil
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

        private var source: Lexer
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
        if var result = Lexer.keywords[word] {
            result.position = position
            return .Ok(result)
        }
        if Lexer.known_words?.contains(word) ?? true {
            return .Ok(ResultOk(token: .Word(word), code: .WORD, position: position))
        }
        else {
            return result(from: .UnknownWord(word), position: position)
        }
    }
    
    private func result(from error: LexerError, position: Position) -> Result {
        return .Error(ResultError(error: error, position: position))
    }
    
    var text: String
    
    static let keywords = [
        "and":  ResultOk(token: .Keyword, code: .AND),
        "as": ResultOk(token: .Keyword, code: .AS),
        "billion": ResultOk(token: .Keyword, code: .BILLION),
        "by": ResultOk(token: .Keyword, code: .BY),
        "call": ResultOk(token: .Keyword, code: .CALL),
        "define": ResultOk(token: .Keyword, code: .DEFINE),
        "divided": ResultOk(token: .Keyword, code: .DIVIDED),
        "do": ResultOk(token: .Keyword, code: .DO),
        "done": ResultOk(token: .Keyword, code: .DONE),
        "dot": ResultOk(token: .Keyword, code: .DOT),
        "else": ResultOk(token: .Keyword, code: .ELSE),
        "equal": ResultOk(token: .Keyword, code: .EQUAL),
        "false": ResultOk(token: .Keyword, code: .FALSE),
        "function": ResultOk(token: .Keyword, code: .FUNCTION),
        "greater": ResultOk(token: .Keyword, code: .GREATER),
        "hundred": ResultOk(token: .Keyword, code: .HUNDRED),
        "if": ResultOk(token: .Keyword, code: .IF),
        "is": ResultOk(token: .Keyword, code: .IS),
        "less": ResultOk(token: .Keyword, code: .LESS),
        "locally": ResultOk(token: .Keyword, code: .LOCALLY),
        "million": ResultOk(token: .Keyword, code: .MILLION),
        "minus": ResultOk(token: .Keyword, code: .MINUS),
        "not": ResultOk(token: .Keyword, code: .NOT),
        "nothing": ResultOk(token: .Keyword, code: .NOTHING),
        "of": ResultOk(token: .Keyword, code: .OF),
        "optional": ResultOk(token: .Keyword, code: .OPTIONAL),
        "or": ResultOk(token: .Keyword, code: .OR),
        "plus": ResultOk(token: .Keyword, code: .PLUS),
        "print": ResultOk(token: .Keyword, code: .PRINT),
        "quadrillion": ResultOk(token: .Keyword, code: .QUADRILLION),
        "quintillion": ResultOk(token: .Keyword, code: .QUINTILLION),
        "return": ResultOk(token: .Keyword, code: .RETURN),
        "set": ResultOk(token: .Keyword, code: .SET),
        "than": ResultOk(token: .Keyword, code: .THAN),
        "then": ResultOk(token: .Keyword, code: .THEN),
        "thousand": ResultOk(token: .Keyword, code: .THOUSAND),
        "times": ResultOk(token: .Keyword, code: .TIMES),
        "to": ResultOk(token: .Keyword, code: .TO),
        "trillion": ResultOk(token: .Keyword, code: .TRILLION),
        "true": ResultOk(token: .Keyword, code: .TRUE),
        "value": ResultOk(token: .Keyword, code: .VALUE),
        "with": ResultOk(token: .Keyword, code: .WITH),
        
        "zero": ResultOk(token: .Number(0), code: .ONES),
        "one": ResultOk(token: .Number(1), code: .ONES),
        "two": ResultOk(token: .Number(2), code: .ONES),
        "three": ResultOk(token: .Number(3), code: .ONES),
        "four": ResultOk(token: .Number(4), code: .ONES),
        "five": ResultOk(token: .Number(5), code: .ONES),
        "six": ResultOk(token: .Number(6), code: .ONES),
        "seven": ResultOk(token: .Number(7), code: .ONES),
        "eight": ResultOk(token: .Number(8), code: .ONES),
        "nine": ResultOk(token: .Number(9), code: .ONES),
        
        "ten": ResultOk(token: .Number(10), code: .TEENS),
        "eleven": ResultOk(token: .Number(11), code: .TEENS),
        "twelve": ResultOk(token: .Number(12), code: .TEENS),
        "thirteen": ResultOk(token: .Number(13), code: .TEENS),
        "fourteen": ResultOk(token: .Number(14), code: .TEENS),
        "fifteen": ResultOk(token: .Number(15), code: .TEENS),
        "sixteen": ResultOk(token: .Number(16), code: .TEENS),
        "seventeen": ResultOk(token: .Number(17), code: .TEENS),
        "eighteen": ResultOk(token: .Number(18), code: .TEENS),
        "nineteen": ResultOk(token: .Number(19), code: .TEENS),
        
        "twenty": ResultOk(token: .Number(20), code: .TENS),
        "thirty": ResultOk(token: .Number(30), code: .TENS),
        "fourty": ResultOk(token: .Number(40), code: .TENS),
        "fifty": ResultOk(token: .Number(50), code: .TENS),
        "sixty": ResultOk(token: .Number(60), code: .TENS),
        "seventy": ResultOk(token: .Number(70), code: .TENS),
        "eighty": ResultOk(token: .Number(80), code: .TENS),
        "ninety": ResultOk(token: .Number(90), code: .TENS)
    ]
    
    private static var known_words = KnownWords()
}
