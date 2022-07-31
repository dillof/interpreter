/*
  Statement.swift -- A Statement, or a Function Definition
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

enum Statement {
    case Set(name: String, value: Expression)
    case FunctionCall(Expression)
    case Return(Expression)
    case If(condition: Condition, then_part: Block, else_part: Block)
    case FunctionDefinition(name: String, arguments: [String], body: Block)
    case Print(Expression)
    
    func execute(environment: Environment) throws -> Value? {
        switch self {
        case .Set(name: let name, value: let value):
            environment.set(variable: name, to: try value.evaluate(environment: environment))
            
        case .FunctionCall(let e):
            switch e {
            case .FunctionCall(_, _):
                let _ = try e.evaluate(environment: environment)
            default:
                throw RuntimeError.NotAFunction
            }
            
        case .Return(let value):
            return try value.evaluate(environment: environment)
            
        case .If(condition: let condition, then_part: let then_part, else_part: let else_part):
            if try condition.evaluate(environment: environment) {
                return try then_part.execute(environment: environment)
            }
            else {
                return try else_part.execute(environment: environment)
            }
            
        case .FunctionDefinition(name: let name, arguments: let arguments, body: let body):
            try environment.define(function: name, definition: Function(arguments: arguments, body: body))
            
        case .Print(let value):
            print(try value.evaluate(environment: environment))
        }
        
        return nil
    }
}
