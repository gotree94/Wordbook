//
//  WordSetListView.swift
//  Wordbook
//
//  Created by gotree94 on 2/2/26.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct WordSetListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var wordSets: [WordSet]
    @State private var showingImporter = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(wordSets) { wordSet in
                    NavigationLink {
                        StudyCardView(wordSet: wordSet)
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(wordSet.name)
                                .font(.headline)
                            Text("\(wordSet.words.count)개의 단어")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(wordSet.createdAt, format: .dateTime)
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deleteWordSets)
            }
            .navigationTitle("단어장")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingImporter = true
                    } label: {
                        Label("단어장 추가", systemImage: "plus.circle.fill")
                    }
                }
            }
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [.plainText, .text],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result: result)
            }
            .alert("오류", isPresented: $showingError) {
                Button("확인", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .overlay {
                if wordSets.isEmpty {
                    ContentUnavailableView {
                        Label("단어장이 없습니다", systemImage: "book.closed")
                    } description: {
                        Text("+ 버튼을 눌러 텍스트 파일을 추가하세요")
                    }
                }
            }
        }
    }
    
    private func handleFileImport(result: Result<[URL], Error>) {
        do {
            guard let selectedFile = try result.get().first else { return }
            
            // 파일 접근 권한 획득
            guard selectedFile.startAccessingSecurityScopedResource() else {
                errorMessage = "파일에 접근할 수 없습니다."
                showingError = true
                return
            }
            
            defer { selectedFile.stopAccessingSecurityScopedResource() }
            
            let content = try String(contentsOf: selectedFile, encoding: .utf8)
            let fileName = selectedFile.deletingPathExtension().lastPathComponent
            
            parseAndSaveWordSet(content: content, name: fileName)
            
        } catch {
            errorMessage = "파일을 읽을 수 없습니다: \(error.localizedDescription)"
            showingError = true
        }
    }
    
    private func parseAndSaveWordSet(content: String, name: String) {
        let lines = content.components(separatedBy: .newlines)
        var words: [Word] = []
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            guard !trimmedLine.isEmpty else { continue }
            
            // "/" 로 구분
            let components = trimmedLine.components(separatedBy: "/")
            guard components.count >= 2 else { continue }
            
            let english = components[0].trimmingCharacters(in: .whitespaces)
            let korean = components[1].trimmingCharacters(in: .whitespaces)
            
            guard !english.isEmpty && !korean.isEmpty else { continue }
            
            let word = Word(english: english, korean: korean)
            words.append(word)
        }
        
        if words.isEmpty {
            errorMessage = "파일에서 유효한 단어를 찾을 수 없습니다.\n형식: 영어단어 / 한국어뜻"
            showingError = true
            return
        }
        
        let wordSet = WordSet(name: name, words: words)
        modelContext.insert(wordSet)
        
        do {
            try modelContext.save()
        } catch {
            errorMessage = "저장에 실패했습니다: \(error.localizedDescription)"
            showingError = true
        }
    }
    
    private func deleteWordSets(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(wordSets[index])
            }
        }
    }
}

#Preview {
    WordSetListView()
        .modelContainer(for: WordSet.self, inMemory: true)
}
