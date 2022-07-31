//
//  RuntimeError.swift
//  interpreter
//
//  Created by Dieter Baron on 22/07/31.
//

import Foundation

enum RuntimeError: Error {
    case CallStackOverflow
    case DivisionByZero
    case InvalidTypeForOperation
    case NestedFunction
    case NotAFunction
    case RedefineFunction
    case UndefinedFunction(String)
    case UndefinedVariable(String)
}
