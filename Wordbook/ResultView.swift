//
//  ResultView.swift
//  Wordbook
//
//  Created by gotree94 on 2/2/26.
//

import SwiftUI

struct ResultView: View {
    let session: StudySession
    let wordSetName: String
    let onDismiss: () -> Void
    
    var scorePercentage: Double {
        guard session.totalWords > 0 else { return 0 }
        return Double(session.correctCount) / Double(session.totalWords) * 100
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // 헤더
                VStack(spacing: 16) {
                    Image(systemName: scorePercentage >= 80 ? "trophy.fill" : scorePercentage >= 60 ? "star.fill" : "hand.thumbsup.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(scorePercentage >= 80 ? .yellow : scorePercentage >= 60 ? .blue : .orange)
                    
                    Text("학습 완료!")
                        .font(.largeTitle)
                        .bold()
                    
                    Text(wordSetName)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)
                
                // 점수 카드
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                        
                        Circle()
                            .trim(from: 0, to: scorePercentage / 100)
                            .stroke(
                                scorePercentage >= 80 ? Color.green : scorePercentage >= 60 ? Color.blue : Color.orange,
                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                        
                        VStack(spacing: 8) {
                            Text("\(Int(scorePercentage))%")
                                .font(.system(size: 56, weight: .bold))
                            Text("정답률")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(width: 220, height: 220)
                    .padding()
                    
                    // 통계
                    HStack(spacing: 40) {
                        VStack(spacing: 8) {
                            Text("\(session.totalWords)")
                                .font(.system(size: 36, weight: .bold))
                            Text("전체")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        VStack(spacing: 8) {
                            Text("\(session.correctCount)")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(.green)
                            Text("정답")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        VStack(spacing: 8) {
                            Text("\(session.wrongCount)")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(.red)
                            Text("오답")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal)
                
                // 오답 목록
                if session.wrongCount > 0 {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("오답 노트")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(Array(session.wrongAnswers).sorted(), id: \.self) { index in
                                if index < session.words.count {
                                    let word = session.words[index]
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(word.english)
                                                .font(.headline)
                                            Text(word.korean)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.red)
                                    }
                                    .padding()
                                    .background(Color(uiColor: .tertiarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // 버튼
                VStack(spacing: 12) {
                    Button {
                        session.reset()
                    } label: {
                        Text("다시 학습하기")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button {
                        onDismiss()
                    } label: {
                        Text("완료")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(uiColor: .secondarySystemBackground))
                            .foregroundStyle(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    let session = StudySession(words: [
        Word(english: "apple", korean: "사과"),
        Word(english: "banana", korean: "바나나"),
        Word(english: "cat", korean: "고양이")
    ])
    session.correctAnswers = [0, 1]
    session.wrongAnswers = [2]
    session.showingResult = true
    
    return ResultView(session: session, wordSetName: "테스트 단어장") {
        print("Dismissed")
    }
}
