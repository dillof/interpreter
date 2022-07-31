//
//  parse.swift
//  interpreter
//
//  Created by Dieter Baron on 22/07/30.
//

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
            .string("add", (.Keyword, .ADD)),
            .string("and", (.Keyword, .AND)),
            .string("by", (.Keyword, .BY)),
            .string("call", (.Keyword, .CALL)),
            .string("divide", (.Keyword, .DIVIDE)),
            .string("done", (.Keyword, .DONE)),
            .string("do", (.Keyword, .DO)),
            .string("dot", (.Keyword, .DOT)),
            .string("else", (.Keyword, .ELSE)),
            .string("equal", (.Keyword, .EQUAL)),
            .string("false", (.Keyword, .FALSE)),
            .string("from", (.Keyword, .FROM)),
            .string("function", (.Keyword, .FUNCTION)),
            .string("greater", (.Keyword, .GREATER)),
            .string("hundred", (.Keyword, .HUNDRED)),
            .string("if", (.Keyword, .IF)),
            .string("is", (.Keyword, .IS)),
            .string("less", (.Keyword, .LESS)),
            .string("millon", (.Keyword, .MILLON)),
            .string("minus", (.Keyword, .MINUS)),
            .string("multiply", (.Keyword, .MULTIPLY)),
            .string("nothing", (.Keyword, .NOTHING)),
            .string("not", (.Keyword, .NOT)),
            .string("of", (.Keyword, .OF)),
            .string("or", (.Keyword, .OR)),
            .string("print", (.Keyword, .PRINT)),
            .string("return", (.Keyword, .RETURN)),
            .string("set", (.Keyword, .SET)),
            .string("subtract", (.Keyword, .SUBTRACT)),
            .string("than", (.Keyword, .THAN)),
            .string("then", (.Keyword, .THEN)),
            .string("thousand", (.Keyword, .THOUSAND)),
            .string("to", (.Keyword, .TO)),
            .string("true", (.Keyword, .TRUE)),
            .string("value", (.Keyword, .VALUE)),
            .string("with", (.Keyword, .WITH)),
            .string("word", (.Keyword, .WORD)),
            
            .string("zero", (.Number(0), .ONES)),
            .string("one", (.Number(1), .ONES)),
            .string("two", (.Number(2), .ONES)),
            .string("three", (.Number(3), .ONES)),
            .string("four", (.Number(4), .ONES)),
            .string("five", (.Number(5), .ONES)),
            .string("six", (.Number(6), .ONES)),
            .string("seven", (.Number(7), .ONES)),
            .string("eight", (.Number(8), .ONES)),
            .string("nine", (.Number(9), .ONES)),
            
            .string("ten", (.Number(10), .TEENS)),
            .string("eleven", (.Number(11), .TEENS)),
            .string("twelve", (.Number(12), .TEENS)),
            .string("thirteen", (.Number(13), .TEENS)),
            .string("fourteen", (.Number(14), .TEENS)),
            .string("fifteen", (.Number(15), .TEENS)),
            .string("sixteen", (.Number(16), .TEENS)),
            .string("seventeen", (.Number(17), .TEENS)),
            .string("eighteen", (.Number(18), .TEENS)),
            .string("nineteen", (.Number(19), .TEENS)),
            
            .string("twenty", (.Number(20), .TENS)),
            .string("thirty", (.Number(30), .TENS)),
            .string("fourty", (.Number(40), .TENS)),
            .string("fifty", (.Number(50), .TENS)),
            .string("sixty", (.Number(60), .TENS)),
            .string("seventy", (.Number(70), .TENS)),
            .string("eighty", (.Number(80), .TENS)),
            .string("ninety", (.Number(90), .TENS)),
            
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
