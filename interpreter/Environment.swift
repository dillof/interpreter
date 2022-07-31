//
//  Context.swift
//  interpreter
//
//  Created by Dieter Baron on 22/07/30.
//

import Foundation

class Environment {
    static let MaximumStackDepth = 5000
    
    init() { }
    
    private init(parent: Environment) throws {
        self.stackDepth = parent.stackDepth + 1
        if stackDepth > Environment.MaximumStackDepth {
            throw RuntimeError.CallStackOverflow
        }
        self.parent = parent
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
            parent?.set(variable: variable, to: value, locally: locally)
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
            throw RuntimeError.RedefineFunction
        }
        functions[name] = definition
    }
    
    private var variables = [String: Value]()
    private var functions = [String: Function]()
    
    var parent: Environment?
    var stackDepth = 0
}
