//
//  parse.swift
//  interpreter
//
//  Created by Dieter Baron on 22/07/30.
//

import Foundation

func parse(input_file: String) -> Block? {
    do {
        let input = try String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))

        // Create parser
        let parser = Parser()
        // parser.isTracingEnabled = true
       
        // Enable error capturing
        let errorReporter = ErrorReporter(input: input)
        parser.errorCaptureDelegate = errorReporter

        // TODO: fix lexer
        // - make case insensitive
        // - only accept words
        // - don't accept prefix
        
        let lexer = MyLexer(text: input)
        
        for token in lexer {
            try parser.consume(token: (token: token.token, position: token.position), code: token.code)
            // try parser.consume(lexerError: e)
        }
        
        //errorReporter.endOfInputPosition = lexer.currentPosition
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
