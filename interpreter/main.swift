//
//  main.swift
//  interpreter
//
//  Created by Dieter Baron on 22/07/30.
//

import Foundation

if CommandLine.argc != 2 {
    print("Usage: \(CommandLine.arguments[0]) file\n")
} else {
    if let program = parse(input_file: CommandLine.arguments[1]) {
        do {
            let _ = try program.execute(environment: Environment())
        }
        catch (let error) {
            print("Runtime error \(error)")
        }
    }
}


extension Array {
    func appending(_ element: Element) -> [Element] {
        var newArray = self
        newArray.append(element)
        return newArray
    }
}
