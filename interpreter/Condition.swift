//
//  Condition.swift
//  interpreter
//
//  Created by Dieter Baron on 22/07/30.
//

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
