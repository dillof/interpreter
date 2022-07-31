//
//  Block.swift
//  interpreter
//
//  Created by Dieter Baron on 22/07/31.
//

import Foundation

struct Block {
    init(_ body: [Statement] = []) {
        self.body = body
    }
    
    func execute(environment: Environment) throws -> Value? {
        for statement in body {
            if let value = try statement.execute(environment: environment) {
                return value
            }
        }
        return nil
    }
    
    var body: [Statement]
}
