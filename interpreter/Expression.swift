/*
  Expression.swift -- An Expression, Which Can Be Evaluated to Yield a Value
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

indirect enum Expression {
    case Add(left: Expression, right: Expression)
    case Multiply(left: Expression, right: Expression)
    case Subtract(left: Expression, right: Expression)
    case Divide(left: Expression, right: Expression)
    case Value(Value)
    case Name(String)
    case Condition(Condition)
    case FunctionCall(name: String, arguments: [String:Expression])
    
    func evaluate(environment: Environment) throws -> Value {
        switch self {
        case .Add(left: let left, right: let right):
            let leftValue = try left.evaluate(environment: environment)
            let rightValue = try right.evaluate(environment: environment)

            switch (leftValue, rightValue) {
            case (.Integer(let l), .Integer(let r)):
                return .Integer(l + r)
            case (.Integer(let l), .Real(let r)):
                return .Real(Double(l) + r)
            case (.Real(let l), .Integer(let r)):
                return .Real(l + Double(r))
            case (.Real(let l), .Real(let r)):
                return .Real(l + r)
            default:
                throw RuntimeError.InvalidTypeForOperation
            }
        case .Multiply(left: let left, right: let right):
            let leftValue = try left.evaluate(environment: environment)
            let rightValue = try right.evaluate(environment: environment)

            switch (leftValue, rightValue) {
            case (.Integer(let l), .Integer(let r)):
                return .Integer(l * r)
            case (.Integer(let l), .Real(let r)):
                return .Real(Double(l) * r)
            case (.Real(let l), .Integer(let r)):
                return .Real(l * Double(r))
            case (.Real(let l), .Real(let r)):
                return .Real(l * r)
            default:
                throw RuntimeError.InvalidTypeForOperation
            }
        case .Subtract(left: let left, right: let right):
            let leftValue = try left.evaluate(environment: environment)
            let rightValue = try right.evaluate(environment: environment)

            switch (leftValue, rightValue) {
            case (.Integer(let l), .Integer(let r)):
                return .Integer(r - l)
            case (.Integer(let l), .Real(let r)):
                return .Real(r - Double(l))
            case (.Real(let l), .Integer(let r)):
                return .Real(Double(r) - l)
            case (.Real(let l), .Real(let r)):
                return .Real(r - l)
            default:
                throw RuntimeError.InvalidTypeForOperation
            }
        case .Divide(left: let left, right: let right):
            let leftValue = try left.evaluate(environment: environment)
            let rightValue = try right.evaluate(environment: environment)
            
            if rightValue == .Integer(0) {
                throw RuntimeError.DivisionByZero
            }

            switch (leftValue, rightValue) {
            case (.Integer(let l), .Integer(let r)):
                if l % r == 0 {
                    return .Integer(l / r)
                }
                else {
                    return .Real(Double(l) / Double(r))
                }
            case (.Integer(let l), .Real(let r)):
                return .Real(Double(l) / r)
            case (.Real(let l), .Integer(let r)):
                return .Real(l / Double(r))
            case (.Real(let l), .Real(let r)):
                return .Real(l / r)
            default:
                throw RuntimeError.InvalidTypeForOperation
            }
        case .Value(let v):
            return v
            
        case .Name(let name):
            return try environment.get(variable: name)
            
        case .Condition(let c):
            let value = try c.evaluate(environment: environment)
            return .Boolean(value)
            
        case .FunctionCall(name: let name, arguments: let arguments):
            let function = try environment.get(function: name)
            return try function.execute(arguments: arguments, environment: environment)
        }
    }
}
