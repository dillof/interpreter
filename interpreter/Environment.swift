/*
  Environment.swift -- The Environment of Code Execution
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

class Environment {
    static let MaximumStackDepth = 750
    
    init() { }
    
    private init(parent: Environment) throws {
        self.stackDepth = parent.stackDepth + 1
        if stackDepth > Environment.MaximumStackDepth {
            throw RuntimeError.CallStackOverflow
        }
        self.parent = parent
        self.stackDepth = parent.stackDepth + 1
    }
    
    func addingScope() throws -> Environment {
        return try Environment(parent: self)
    }
    
    func get(variable: String) throws -> Value {
        if let value = variables[variable] {
            return value
        }
        else if let parent = parent {
            return try parent.get(variable: variable)
        }
        else {
            throw RuntimeError.UndefinedVariable(variable)
        }
    }
    
    func set(variable: String, to value: Value, locally: Bool = false) {
        if variables.keys.contains(variable) || locally || parent == nil {
            variables[variable] = value
        }
        else {
            parent?.set(variable: variable, to: value)
        }
    }
    
    func get(function: String) throws -> Function {
        if let parent = parent {
            return try parent.get(function: function)
        }
        else if let f = functions[function] {
            return f
        }
        else {
            throw RuntimeError.UndefinedFunction(function)
        }
    }
    
    func define(function name: String, definition: Function) throws {
        if parent != nil {
            throw RuntimeError.NestedFunction
        }
        if functions.keys.contains(name) {
            throw RuntimeError.RedefineFunction(name)
        }
        functions[name] = definition
    }
    
    private var variables = [String: Value]()
    private var functions = [String: Function]()
    
    var parent: Environment?
    var stackDepth = 0
}
