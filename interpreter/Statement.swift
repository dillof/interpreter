//
//  Unit.swift
//  interpreter
//
//  Created by Dieter Baron on 22/07/30.
//

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
