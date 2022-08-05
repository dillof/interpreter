//
//  KnownWords.swift
//  interpreter
//
//  Created by Dieter Baron on 22/08/03.
//

import Foundation

struct KnownWords {
    init?() {
        do {
            let wordlist = try String(contentsOf: URL(fileURLWithPath: "/usr/share/dict/web2"))
            let words = wordlist.split(separator: "\n").map { $0.lowercased() }
            known_words = Set<String>(words)
        }
        catch {
            return nil
        }
    }
    
    func contains(_ word: String) -> Bool {
        return known_words.contains(word)
    }
    
    private var known_words = Set<String>()
}
