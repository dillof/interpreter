//
//  DoubleAssembler.swift
//  interpreter
//
//  Created by Dieter Baron on 22/07/30.
//

import Foundation

struct RealAssembler {
    init(_ i: Int) {
        self.value = Double(i)
    }
    
    private init(value: Double, nextDecimal: Double) {
        self.value = value
        self.nextDecimal = nextDecimal
    }
    
    func appending(_ i: Int) -> RealAssembler {
        return RealAssembler(value: value + Double(i) * nextDecimal, nextDecimal: nextDecimal * 0.1)
    }
    
    var value: Double
    
    private var nextDecimal = 0.1
}
