//
//  Function.swift
//  interpreter
//
//  Created by Dieter Baron on 22/07/31.
//

import Foundation

struct Function {
    func execute(arguments argumentExpressions: [Expression], environment: Environment) throws -> Value {
        let argumentValues = try argumentExpressions.map({ try $0.evaluate(environment: environment) })
        let innerEnvironment = try environment.addingScope()
        
        for (name, value) in zip(arguments, argumentValues) {
            innerEnvironment.set(variable: name, to: value, locally: true)
        }

        if let value = try body.execute(environment: innerEnvironment) {
            return value
        }
        else {
            return .Nothing
        }
    }
    
    var arguments = [String]()
    var body = Block()
}
