/*
  Function.swift -- A Function, Ready to Be Called
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

struct Function {
    func execute(arguments actualArguments: [String:Expression], environment: Environment) throws -> Value {
        for argumentName in actualArguments.keys {
            if !arguments.keys.contains(argumentName) {
                throw RuntimeError.UnexpectedArgument(function: name, argument: argumentName)
            }
        }

        let innerEnvironment = try environment.addingScope()
        for (argumentName, required) in arguments {
            if let expression = actualArguments[argumentName] {
                innerEnvironment.set(variable: argumentName, to: try expression.evaluate(environment: environment), locally: true)
            }
            else {
                if required {
                    throw RuntimeError.MissingArgument(function: name, argument: argumentName)
                }
                else {
                    innerEnvironment.set(variable: argumentName, to: .Nothing, locally: true)
                }
            }
        }

        if let value = try body.execute(environment: innerEnvironment) {
            return value
        }
        else {
            return .Nothing
        }
    }
    
    var name: String
    var arguments = [String:Bool]()
    var body = Block()
}
