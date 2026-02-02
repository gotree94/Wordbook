//
//  Word.swift
//  Wordbook
//
//  Created by gotree94 on 2/2/26.
//

import Foundation
import SwiftData

@Model
final class Word {
    var english: String
    var korean: String
    var wordSet: WordSet?
    
    init(english: String, korean: String) {
        self.english = english
        self.korean = korean
    }
}
