//
//  WordSet.swift
//  Wordbook
//
//  Created by gotree94 on 2/2/26.
//

import Foundation
import SwiftData

@Model
final class WordSet {
    var name: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade, inverse: \Word.wordSet)
    var words: [Word]
    
    init(name: String, words: [Word] = []) {
        self.name = name
        self.createdAt = Date()
        self.words = words
    }
}
