//
//  StudyCardView.swift
//  Wordbook
//
//  Created by gotree94 on 2/2/26.
//

import SwiftUI
import SwiftData

struct StudyCardView: View {
    let wordSet: WordSet
    @State private var session: StudySession?
    @State private var showingResult = false
    @State private var isEditingAnswer = false
    @State private var selectedMode: StudyMode = .englishToKorean
    @FocusState private var isInputFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Group {
            if let session = session {
                if session.showingResult {
                    ResultView(session: session, wordSetName: wordSet.name) {
                        self.session = nil
                        dismiss()
                    }
                } else {
                    studyView(session: session)
                }
            } else {
                startView
            }
        }
        .navigationTitle(wordSet.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var startView: some View {
        VStack(spacing: 24) {
            Image(systemName: "book.pages")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            
            Text(wordSet.name)
                .font(.title)
                .bold()
            
            Text("\(wordSet.words.count)개의 단어")
                .font(.title3)
                .foregroundStyle(.secondary)
            
            Text("최대 100개의 단어로 학습합니다")
                .font(.caption)
                .foregroundStyle(.tertiary)
            
            // 학습 모드 선택
            VStack(spacing: 16) {
                Text("학습 모드")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                VStack(spacing: 12) {
                    Button {
                        selectedMode = .englishToKorean
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("영어 → 한글")
                                    .font(.headline)
                                Text("영어 단어를 보고 한글 뜻 맞추기")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if selectedMode == .englishToKorean {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.blue)
                            }
                        }
                        .padding()
                        .background(selectedMode == .englishToKorean ? Color.blue.opacity(0.1) : Color(uiColor: .secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .foregroundStyle(.primary)
                    
                    Button {
                        selectedMode = .koreanToEnglish
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("한글 → 영어")
                                    .font(.headline)
                                Text("한글 뜻을 보고 영어 단어 맞추기")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if selectedMode == .koreanToEnglish {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.blue)
                            }
                        }
                        .padding()
                        .background(selectedMode == .koreanToEnglish ? Color.blue.opacity(0.1) : Color(uiColor: .secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .foregroundStyle(.primary)
                }
                .padding(.horizontal)
            }
            .padding(.top, 8)
            
            Button {
                startStudy()
            } label: {
                Text("학습 시작")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
            .padding(.top, 12)
        }
        .padding()
    }
    
    private func studyView(session: StudySession) -> some View {
        VStack(spacing: 0) {
            // 진행 상태
            VStack(spacing: 8) {
                ProgressView(value: session.progress)
                    .tint(.blue)
                
                HStack {
                    Text("\(session.currentIndex + 1) / \(session.totalWords)")
                        .font(.caption)
                    Spacer()
                    Label("\(session.correctCount)", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.caption)
                    Label("\(session.wrongCount)", systemImage: "xmark.circle.fill")
                        .foregroundStyle(.red)
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(uiColor: .systemBackground))
            
            if let word = session.currentWord {
                // 카드 영역
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        // 질문 단어 (상단)
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.blue.gradient)
                            
                            VStack {
                                Spacer()
                                Text(session.mode == .englishToKorean ? word.english : word.korean)
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.center)
                                Spacer()
                            }
                            .padding()
                        }
                        .frame(height: geometry.size.height * 0.45)
                        
                        // 답변 입력 영역 (하단)
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(uiColor: .secondarySystemBackground))
                            
                            VStack(spacing: 20) {
                                Spacer()
                                
                                if session.answerChecked {
                                    // 정답 표시
                                    VStack(spacing: 12) {
                                        Image(systemName: session.correctAnswers.contains(session.currentIndex) ? "checkmark.circle.fill" : "xmark.circle.fill")
                                            .font(.system(size: 60))
                                            .foregroundStyle(session.correctAnswers.contains(session.currentIndex) ? .green : .red)
                                        
                                        Text("정답: \(session.mode == .englishToKorean ? word.korean : word.english)")
                                            .font(.title2)
                                            .bold()
                                        
                                        if !session.correctAnswers.contains(session.currentIndex) {
                                            Text("입력: \(session.userAnswer)")
                                                .font(.title3)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                } else {
                                    // 답변 입력
                                    VStack(spacing: 16) {
                                        TextField(session.mode == .englishToKorean ? "한글 뜻을 입력하세요" : "영어 단어를 입력하세요", text: Binding(
                                            get: { session.userAnswer },
                                            set: { session.userAnswer = $0 }
                                        ))
                                        .font(.system(size: 36, weight: .semibold))
                                        .multilineTextAlignment(.center)
                                        .textFieldStyle(.plain)
                                        .focused($isInputFocused)
                                        .padding()
                                        .background(Color(uiColor: .tertiarySystemBackground))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        
                                        Text("키보드로 입력하세요")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.horizontal)
                                }
                                
                                Spacer()
                            }
                            .padding()
                        }
                        .frame(height: geometry.size.height * 0.45)
                    }
                }
                .padding()
                .gesture(
                    DragGesture(minimumDistance: 50)
                        .onEnded { value in
                            if value.translation.width < 0 {
                                // 왼쪽 스와이프 - 다음
                                if session.answerChecked {
                                    withAnimation {
                                        session.nextWord()
                                    }
                                }
                            } else if value.translation.width > 0 {
                                // 오른쪽 스와이프 - 이전
                                withAnimation {
                                    session.previousWord()
                                }
                            }
                        }
                )
                
                // 버튼 영역
                VStack(spacing: 12) {
                    if session.answerChecked {
                        Button {
                            withAnimation {
                                session.nextWord()
                            }
                        } label: {
                            Text(session.currentIndex < session.totalWords - 1 ? "다음 단어" : "결과 보기")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    } else {
                        Button {
                            withAnimation {
                                _ = session.checkAnswer()
                            }
                        } label: {
                            Text("확인")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(session.userAnswer.isEmpty ? Color.gray : Color.green)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(session.userAnswer.isEmpty)
                    }
                }
                .padding()
                .background(Color(uiColor: .systemBackground))
            }
        }
        .navigationBarBackButtonHidden(session != nil)
        .toolbar {
            if session != nil {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("종료") {
                        self.session = nil
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .keyboard) {
                    Button("완료") {
                        isInputFocused = false
                    }
                }
            }
        }
    }
    
    private func startStudy() {
        session = StudySession(words: wordSet.words, mode: selectedMode)
        // 첫 단어에서 자동으로 키보드 포커스
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isInputFocused = true
        }
    }
}

#Preview {
    NavigationStack {
        StudyCardView(wordSet: WordSet(name: "테스트", words: [
            Word(english: "apple", korean: "사과"),
            Word(english: "banana", korean: "바나나")
        ]))
    }
    .modelContainer(for: WordSet.self, inMemory: true)
}
