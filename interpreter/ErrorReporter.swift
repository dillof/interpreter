/*
  ErrorReporter.swift -- For Reporting Parsing Errors
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

import CitronLexerModule
import CitronParserModule

class ErrorReporter {
    let inputString: String
    var endOfInputPosition: CitronLexerPosition?
    var isErrorReportedAtEnd: Bool = false
    init(input: String) {
        inputString = input
    }
}

extension ErrorReporter : Parser.CitronErrorCaptureDelegate {
    typealias ECState = Parser.CitronErrorCaptureState
    typealias ECResponse = CitronErrorCaptureResponse

    #if false
    /* func_header */
    func shouldCaptureErrorOnFunc_header(state: ECState, error: Error) -> ECResponse<[Statement]?> {
        reportError(error: error, on: .func_header, state: state)
        return .captureAs(nil)
    }
    /* func_signature */
    func shouldCaptureErrorOnFunc_signature(state: ECState, error: Error) -> ECResponse<([FunctionParameter?]?, [Statement], TypeIdentifier)?> {
        reportError(error: error, on: .func_signature, state: state)
        return .captureAs(nil)
    }

    /* func_keyword_name */
    func shouldCaptureErrorOnFunc_keyword_name(state: ECState, error: Error) -> ECResponse<TypeIdentifier?> {
        reportError(error: error, on: .func_keyword_name, state: state)
        return .captureAs(nil)
    }

    /* param_clause */
    func shouldCaptureErrorOnParam_clause(state: ECState, error: Error) -> ECResponse<[FunctionParameter?]?> {
        reportError(error: error, on: .param_clause, state: state)
        return .captureAs(nil)
    }

    /* param */
    func shouldCaptureErrorOnParam(state: ECState, error: Error) -> ECResponse<FunctionParameter?> {
        reportError(error: error, on: .param, state: state)
        return .captureAs(nil)
    }
    #endif
}

extension ErrorReporter {
    func reportError(error: Error, on errorCapturingSymbol: Parser.CitronNonTerminalCode, state: ECState) {
        if (state.nextToken == nil) {
            // Report only one error while at the end of input
            if (isErrorReportedAtEnd) {
                return
            } else {
                isErrorReportedAtEnd = true
            }
        }

        let lastResolvedSymbolCode = state.lastResolvedSymbol?.symbolCode
        let errorPosition: CitronLexerPosition
        if case CitronLexerError.noMatchingRuleAt(let pos) = error {
            errorPosition = pos
        } else {
            errorPosition = state.erroringToken?.token.position ?? endOfInputPosition!
        }
        
        switch (errorCapturingSymbol, lastResolvedSymbolCode) {
        case (.integer_tens, .some(.integer)),
            (.integer_hundreds, .some(.integer)),
            (.integer_thousands, .some(.integer)),
            (.integer_millions, .some(.integer)):
            croak("invalid number", at: errorPosition)
        case (.integer_tens, _),
            (.integer_hundreds, _),
            (.integer_thousands, _),
            (.integer_millions, _):
            croak("unexpected number", at: errorPosition)
        default:
            croak("unexpected token", at:errorPosition)
        }
    }

    func croak(_ message: String, at position: CitronLexerPosition) {
        print("\(position.lineNumber): error: \(message).")
        let endOfLine = inputString.endOfLine(from: position.linePosition)
        let column = inputString.distance(from: position.linePosition, to: position.tokenPosition)
        let line = inputString[position.linePosition ..< endOfLine]
        let padding = String(repeating: " ", count: column)
        print(line)
        print("\(padding)^")
    }
}

private extension String {
    func endOfLine(from: String.Index) -> String.Index {
        var index = from
        while (index < self.endIndex && self[index] != "\n") {
            index = self.index(after: index)
        }
        return index
    }

    func startOfLastLine() -> String.Index {
        var index = self.endIndex
        while (index > self.startIndex && self[self.index(before: index)] != "\n") {
            index = self.index(before: index)
        }
        return index
    }
}
