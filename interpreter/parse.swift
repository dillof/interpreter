/*
  parse.swift -- The Function to Parse a Program
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
import CitronParserModule

//typealias Lexer = CitronLexer<String>

func read_words() -> Set<String>? {
    do {
        let wordlist = try String(contentsOf: URL(fileURLWithPath: "/usr/share/dict/web2"))
        let words = wordlist.split(separator: "\n").map { $0.lowercased() }
        return Set<String>(words)
    }
    catch {
        return nil
    }
}

let words = read_words()

let keywords: [String: (token: TokenData, code: Parser.CitronTokenCode)] = [
    "and": (.Keyword, .AND),
    "as": (.Keyword, .AS),
    "by": (.Keyword, .BY),
    "call": (.Keyword, .CALL),
    "define": (.Keyword, .DEFINE),
    "divided": (.Keyword, .DIVIDED),
    "do": (.Keyword, .DO),
    "done": (.Keyword, .DONE),
    "dot": (.Keyword, .DOT),
    "eight": (.Number(8), .ONES),
    "eighteen": (.Number(18), .TEENS),
    "eighty": (.Number(80), .TENS),
    "eleven": (.Number(11), .TEENS),
    "else": (.Keyword, .ELSE),
    "equal": (.Keyword, .EQUAL),
    "false": (.Keyword, .FALSE),
    "fifteen": (.Number(15), .TEENS),
    "fifty": (.Number(50), .TENS),
    "five": (.Number(5), .ONES),
    "four": (.Number(4), .ONES),
    "fourteen": (.Number(14), .TEENS),
    "fourty": (.Number(40), .TENS),
    "function": (.Keyword, .FUNCTION),
    "greater": (.Keyword, .GREATER),
    "hundred": (.Keyword, .HUNDRED),
    "if": (.Keyword, .IF),
    "is": (.Keyword, .IS),
    "less": (.Keyword, .LESS),
    "locally": (.Keyword, .LOCALLY),
    "million": (.Keyword, .MILLION),
    "minus": (.Keyword, .MINUS),
    "nine": (.Number(9), .ONES),
    "nineteen": (.Number(19), .TEENS),
    "ninety": (.Number(90), .TENS),
    "not": (.Keyword, .NOT),
    "nothing": (.Keyword, .NOTHING),
    "of": (.Keyword, .OF),
    "one": (.Number(1), .ONES),
    "optional": (.Keyword, .OPTIONAL),
    "or": (.Keyword, .OR),
    "plus": (.Keyword, .PLUS),
    "print": (.Keyword, .PRINT),
    "return": (.Keyword, .RETURN),
    "set": (.Keyword, .SET),
    "seven": (.Number(7), .ONES),
    "seventeen": (.Number(17), .TEENS),
    "seventy": (.Number(70), .TENS),
    "six": (.Number(6), .ONES),
    "sixteen": (.Number(16), .TEENS),
    "sixty": (.Number(60), .TENS),
    "ten": (.Number(10), .TEENS),
    "than": (.Keyword, .THAN),
    "then": (.Keyword, .THEN),
    "thirteen": (.Number(13), .TEENS),
    "thirty": (.Number(30), .TENS),
    "thousand": (.Keyword, .THOUSAND),
    "three": (.Number(3), .ONES),
    "times": (.Keyword, .TIMES),
    "to": (.Keyword, .TO),
    "true": (.Keyword, .TRUE),
    "twelve": (.Number(12), .TEENS),
    "twenty": (.Number(20), .TENS),
    "two": (.Number(2), .ONES),
    "value": (.Keyword, .VALUE),
    "with": (.Keyword, .WITH),
    "word": (.Keyword, .WORD),
    "zero": (.Number(0), .ONES)
]

func parse(input_file: String) -> Block? {
    do {
        let input = try String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))

        // Create parser
        let parser = Parser()
        //parser.isTracingEnabled = true
        
        // Create lexer
        
        let lexer = Lexer(text: input)
        
        // Enable error capturing.
        // let errorReporter = ErrorReporter(input: input)
        // parser.errorCaptureDelegate = errorReporter
        
        for result in lexer {
            switch result {
            case .Ok(let token):
                try parser.consume(token: (token.token, token.position), code: token.code)
            case .Error(let error):
                try parser.consume(lexerError: error.error)
            }
        }
        
        // errorReporter.endOfInputPosition = lexer.currentPosition
        let program = try parser.endParsing()
        if (parser.numberOfCapturedErrors > 0) {
            return nil
        }
        return program
    } catch (let error) {
        print("Error during parsing: \(error)")
    }
    
    return nil
}
