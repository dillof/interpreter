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

typealias Lexer = CitronLexer<(token: TokenData, code: Parser.CitronTokenCode)>

func parse(input_file: String) -> Block? {
    do {
        let input = try String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))

        // Create parser
        let parser = Parser()
        
        // parser.isTracingEnabled = true
        // Create lexer
        
        let lexer = Lexer(rules: [
            // Keywords
            .string("zero", (.Number(0), .ONES)),
            .string("word", (.Keyword, .WORD)),
            .string("with", (.Keyword, .WITH)),
            .string("value", (.Keyword, .VALUE)),
            .string("two", (.Number(2), .ONES)),
            .string("twenty", (.Number(20), .TENS)),
            .string("twelve", (.Number(12), .TEENS)),
            .string("true", (.Keyword, .TRUE)),
            .string("to", (.Keyword, .TO)),
            .string("times", (.Keyword, .TIMES)),
            .string("three", (.Number(3), .ONES)),
            .string("thousand", (.Keyword, .THOUSAND)),
            .string("thirty", (.Number(30), .TENS)),
            .string("thirteen", (.Number(13), .TEENS)),
            .string("then", (.Keyword, .THEN)),
            .string("than", (.Keyword, .THAN)),
            .string("ten", (.Number(10), .TEENS)),
            .string("sixty", (.Number(60), .TENS)),
            .string("sixteen", (.Number(16), .TEENS)),
            .string("six", (.Number(6), .ONES)),
            .string("seventy", (.Number(70), .TENS)),
            .string("seventeen", (.Number(17), .TEENS)),
            .string("seven", (.Number(7), .ONES)),
            .string("set", (.Keyword, .SET)),
            .string("return", (.Keyword, .RETURN)),
            .string("print", (.Keyword, .PRINT)),
            .string("plus", (.Keyword, .PLUS)),
            .string("or", (.Keyword, .OR)),
            .string("optional", (.Keyword, .OPTIONAL)),
            .string("one", (.Number(1), .ONES)),
            .string("of", (.Keyword, .OF)),
            .string("nothing", (.Keyword, .NOTHING)),
            .string("not", (.Keyword, .NOT)),
            .string("ninety", (.Number(90), .TENS)),
            .string("nineteen", (.Number(19), .TEENS)),
            .string("nine", (.Number(9), .ONES)),
            .string("minus", (.Keyword, .MINUS)),
            .string("millon", (.Keyword, .MILLON)),
            .string("million", (.Keyword, .MILLON)),
            .string("locally", (.Keyword, .LOCALLY)),
            .string("less", (.Keyword, .LESS)),
            .string("is", (.Keyword, .IS)),
            .string("if", (.Keyword, .IF)),
            .string("hundred", (.Keyword, .HUNDRED)),
            .string("greater", (.Keyword, .GREATER)),
            .string("function", (.Keyword, .FUNCTION)),
            .string("fourty", (.Number(40), .TENS)),
            .string("fourteen", (.Number(14), .TEENS)),
            .string("four", (.Number(4), .ONES)),
            .string("five", (.Number(5), .ONES)),
            .string("fifty", (.Number(50), .TENS)),
            .string("fifteen", (.Number(15), .TEENS)),
            .string("false", (.Keyword, .FALSE)),
            .string("equal", (.Keyword, .EQUAL)),
            .string("else", (.Keyword, .ELSE)),
            .string("eleven", (.Number(11), .TEENS)),
            .string("eighty", (.Number(80), .TENS)),
            .string("eighteen", (.Number(18), .TEENS)),
            .string("eight", (.Number(8), .ONES)),
            .string("dot", (.Keyword, .DOT)),
            .string("done", (.Keyword, .DONE)),
            .string("do", (.Keyword, .DO)),
            .string("divided", (.Keyword, .DIVIDED)),
            .string("define", (.Keyword, .DEFINE)),
            .string("call", (.Keyword, .CALL)),
            .string("by", (.Keyword, .BY)),
            .string("as", (.Keyword, .AS)),
            .string("and", (.Keyword, .AND)),



            
            
                .regexPattern("[a-z]+", { str in (.Word(str), .WORD) }),
            
            // Ignore whitespace
            .regexPattern("\\s", { _ in nil })
        ])
        
        
        // Enable error capturing
        let errorReporter = ErrorReporter(input: input)
        parser.errorCaptureDelegate = errorReporter

        // TODO: fix lexer
        // - make case insensitive
        // - only accept words
        // - don't accept prefix
        
        try lexer.tokenize(input,
            onFound: { t in
                try parser.consume(token: (token: t.token, position: lexer.currentPosition), code: t.code)
            },
            onError: { (e) in
                try parser.consume(lexerError: e)
            })
        errorReporter.endOfInputPosition = lexer.currentPosition
        let program = try parser.endParsing()
        if (parser.numberOfCapturedErrors > 0) {
            return nil
        }
        return program
    } catch CitronLexerError.noMatchingRuleAt(let pos) {
        //print("Error during tokenization after '\(input.prefix(upTo: pos.tokenPosition))'.")
    } catch (let e as Parser.UnexpectedTokenError) {
       print("Error during parsing: Unexpected token: \(e.tokenCode) (\(e.token))")
    } catch (is Parser.UnexpectedEndOfInputError) {
        print("Error during parsing: Unexpected end of input")
    } catch (let error) {
        print("Error during parsing: \(error)")
    }
    
    return nil
}
