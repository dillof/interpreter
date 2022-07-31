//
//  Token.swift
//  interpreter
//
//  Created by Dieter Baron on 22/07/30.
//

import Foundation

enum TokenData {
    case Keyword
    case Number(Int)
    case Word(String)
    
    var word: String? {
        switch self {
        case .Word(let s):
            return s
        default:
            return nil
        }
    }
    
    var number: Int? {
        switch self {
        case .Number(let i):
            return i
        default:
            return nil
        }
    }
}
