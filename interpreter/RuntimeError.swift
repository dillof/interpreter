/*
  RuntimeError.swift -- All the Things That Can Go Wrong During Execution
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

enum RuntimeError: LocalizedError {
    case CallStackOverflow
    case DivisionByZero
    case InvalidTypeForOperation
    case MissingArgument(function: String, argument: String)
    case NestedFunction
    case InternalError
    case RedefineFunction(String)
    case UndefinedFunction(String)
    case UndefinedVariable(String)
    case UnexpectedArgument(function: String, argument: String)
    
    var errorDescription: String? {
        switch self {
        case .CallStackOverflow:
            return "Function calls are nested too deeply, probably due to a runaway recursion."
        case .DivisionByZero:
            return "Dividing by zero is undefined."
        case .InternalError:
            return "A situation arose that should not be possible; this is probably a bug in the interpreter."
        case .InvalidTypeForOperation:
            return "The operation cannot be performed on these types of values."
        case .MissingArgument(let function, let argument):
            return "The call to the function \(function) is missing the required argument \(argument)."
        case .NestedFunction:
            return "Functions can only be defined at the top level of the program."
        case .RedefineFunction(let name):
            return "Function \(name) is already defined."
        case .UndefinedFunction(let name):
            return "The function \(name) has not been defined."
        case .UndefinedVariable(let name):
            return "The variable \(name) was not set before being used."
        case .UnexpectedArgument(let function, let argument):
            return "The call to the function \(function) passed the unexpected argument \(argument)."
        }
    }
}
