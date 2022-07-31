//
//  Expression.swift
//  interpreter
//
//  Created by Dieter Baron on 22/07/30.
//

import Foundation

indirect enum Expression {
    case Add(left: Expression, right: Expression)
    case Multiply(left: Expression, right: Expression)
    case Subtract(left: Expression, right: Expression)
    case Divide(left: Expression, right: Expression)
    case Value(Value)
    case Name(String)
    case Condition(Condition)
    case FunctionCall(name: String, arguments: [Expression])
    
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
