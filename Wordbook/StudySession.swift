//
//  StudySession.swift
//  Wordbook
//
//  Created by gotree94 on 2/2/26.
//

import Foundation

enum StudyMode {
    case englishToKorean  // 영어 -> 한글
    case koreanToEnglish  // 한글 -> 영어
}

@Observable
class StudySession {
    var words: [Word]
    var mode: StudyMode
    var currentIndex: Int = 0
    var correctAnswers: Set<Int> = []
    var wrongAnswers: Set<Int> = []
    var userAnswer: String = ""
    var showingResult: Bool = false
    var answerChecked: Bool = false
    
    var currentWord: Word? {
        guard currentIndex < words.count else { return nil }
        return words[currentIndex]
    }
    
    var totalWords: Int {
        words.count
    }
    
    var correctCount: Int {
        correctAnswers.count
    }
    
    var wrongCount: Int {
        wrongAnswers.count
    }
    
    var progress: Double {
        guard totalWords > 0 else { return 0 }
        return Double(correctAnswers.count + wrongAnswers.count) / Double(totalWords)
    }
    
    init(words: [Word], mode: StudyMode = .englishToKorean) {
        // 최대 100개로 제한
        self.words = Array(words.prefix(100))
        self.mode = mode
    }
    
    func checkAnswer() -> Bool {
        guard let currentWord = currentWord else { return false }
        
        let normalizedAnswer = userAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedCorrectAnswer: String
        
        switch mode {
        case .englishToKorean:
            normalizedCorrectAnswer = currentWord.korean.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        case .koreanToEnglish:
            normalizedCorrectAnswer = currentWord.english.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        }
        
        let isCorrect = normalizedAnswer == normalizedCorrectAnswer
        
        if isCorrect {
            correctAnswers.insert(currentIndex)
            wrongAnswers.remove(currentIndex)
        } else {
            wrongAnswers.insert(currentIndex)
            correctAnswers.remove(currentIndex)
        }
        
        answerChecked = true
        return isCorrect
    }
    
    func nextWord() {
        if currentIndex < words.count - 1 {
            currentIndex += 1
            userAnswer = ""
            answerChecked = false
        } else {
            showingResult = true
        }
    }
    
    func previousWord() {
        if currentIndex > 0 {
            currentIndex -= 1
            userAnswer = ""
            answerChecked = false
        }
    }
    
    func reset() {
        currentIndex = 0
        correctAnswers.removeAll()
        wrongAnswers.removeAll()
        userAnswer = ""
        showingResult = false
        answerChecked = false
    }
}
