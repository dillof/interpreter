/*
  Condition.swift -- A Condition, Which Is Either True or False
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

indirect enum Condition {
    case And(left: Condition, right: Condition)
    case Or(left: Condition, right: Condition)
    case Not(Condition)
    case Less(left: Expression, right: Expression)
    case Greater(left: Expression, right: Expression)
    case Equal(left: Expression, right: Expression)
    
    init(left: Expression, rightHalf: HalfComparison) {
        switch rightHalf {
        case .Equal(let right):
            self = .Equal(left: left, right: right)
        case .Greater(let right):
            self = .Greater(left: left, right: right)
        case .Less(let right):
            self = .Less(left: left, right: right)
        }
    }
    
    func evaluate(environment: Environment) throws -> Bool {
        switch self {
        case .And(left: let left, right: let right):
            return try left.evaluate(environment: environment) && right.evaluate(environment: environment)

        case .Or(left: let left, right: let right):
            return try left.evaluate(environment: environment) || right.evaluate(environment: environment)
            
        case .Not(let c):
            return try !c.evaluate(environment: environment)
            
        case .Less(left: let left, right: let right):
            return try left.evaluate(environment: environment) < right.evaluate(environment: environment)
            
        case .Greater(left: let left, right: let right):
            return try left.evaluate(environment: environment) > right.evaluate(environment: environment)
            
        case .Equal(left: let left, right: let right):
            return try left.evaluate(environment: environment) == right.evaluate(environment: environment)
        }
    }
}
