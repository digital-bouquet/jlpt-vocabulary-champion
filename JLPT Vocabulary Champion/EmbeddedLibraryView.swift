//
//  EmbeddedLibraryView.swift
//  JLPT Vocabulary Champion
//

import SwiftUI

struct EmbeddedLibraryView: View {
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Binding var currentView: String
    @State private var selectedLevel: JLPTLevel?
    @State private var searchResults: [VocabularyWord] = []
    @State private var searchText = ""

    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }

    private let allWords: [VocabularyWord] = {
        // Load words from JSON files
        var words: [VocabularyWord] = []
        let levels: [(JLPTLevel, String)] = [
            (.n5, "vocabulary_n5"),
            (.n4, "vocabulary_n4"),
            (.n3, "vocabulary_n3"),
            (.n2, "vocabulary_n2"),
            (.n1, "vocabulary_n1"),
        ]

        for (level, filename) in levels {
            if let url = Bundle.main.url(forResource: filename, withExtension: "json"),
               let data = try? Data(contentsOf: url),
               let decoded = try? JSONDecoder().decode([VocabularyWord].self, from: data) {
                words.append(contentsOf: decoded)
            }
        }
        return words
    }()

    private let levelColors: [JLPTLevel: Color] = [
        .n5: Color(hex: "#4CAF50"),
        .n4: Color(hex: "#2196F3"),
        .n3: Color(hex: "#FF9800"),
        .n2: Color(hex: "#9C27B0"),
        .n1: Color(hex: "#F44336")
    ]

    var body: some View {
        ZStack {
            (appSettings.isDarkMode ? Color.backgroundDark : Color.backgroundLight)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with title
                Text("Library")
                    .font(.system(size: isRegularWidth ? 22 : 18, weight: .bold))
                    .foregroundColor(appSettings.isDarkMode ? .white : Color.backgroundDark)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
                    .padding(.bottom, 20)

                ScrollView {
                    VStack(spacing: 0) {
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))

                            TextField("Search words, readings, or meanings", text: $searchText)
                                .font(.system(size: isRegularWidth ? 18 : 16))
                                .foregroundColor(appSettings.isDarkMode ? .white : Color.backgroundDark)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .onChange(of: searchText) { oldValue, newValue in
                                    performSearch()
                                }

                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                    searchResults = []
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(appSettings.isDarkMode ? Color.secondaryBrownDark.opacity(0.3) : Color.gray.opacity(0.1))
                        )
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)

                        if searchText.isEmpty && selectedLevel == nil {
                            levelCategoriesView
                        } else if !searchText.isEmpty {
                            searchResultsView
                        } else if let level = selectedLevel {
                            wordListView(for: level)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }

            // Back button overlay
            VStack {
                HStack {
                    Button(action: {
                        currentView = "home"
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: isRegularWidth ? 20 : 16, weight: .medium))

                            Text("Back")
                                .font(.system(size: isRegularWidth ? 20 : 17))
                        }
                        .foregroundColor(.primaryGold)
                    }
                    .padding(.leading, 16)
                    .padding(.top, 16)

                    Spacer()
                }

                Spacer()
            }
            .zIndex(2)
        }
        .onAppear {
            updateIsDarkMode()
        }
    }

    private var levelCategoriesView: some View {
        VStack(spacing: 16) {
            ForEach(JLPTLevel.allCases.reversed()) { level in
                LevelCard(
                    level: level,
                    wordCount: allWords.filter { $0.level == level }.count,
                    isDarkMode: appSettings.isDarkMode,
                    isRegularWidth: isRegularWidth,
                    onTap: {
                        selectedLevel = level
                    }
                )
            }
        }
        .padding(.horizontal, 16)
    }

    private func wordListView(for level: JLPTLevel) -> some View {
        let words = allWords.filter { $0.level == level }

        return VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    selectedLevel = nil
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: isRegularWidth ? 20 : 16, weight: .medium))

                        Text("Back")
                            .font(.system(size: isRegularWidth ? 20 : 17))
                    }
                    .foregroundColor(.primaryGold)
                }

                Spacer()

                Text("JLPT \(level.displayName.uppercased())")
                    .font(.system(size: isRegularWidth ? 22 : 18, weight: .bold))
                    .foregroundColor(appSettings.isDarkMode ? .white : Color.backgroundDark)

                Spacer()

                Text("\(words.count) words")
                    .font(.system(size: isRegularWidth ? 16 : 14))
                    .foregroundColor(appSettings.isDarkMode ? Color.white.opacity(0.7) : Color.gray)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 20)

            // Word list
            LazyVStack(spacing: 12) {
                ForEach(words) { word in
                    VocabularyWordRow(
                        word: word,
                        isDarkMode: appSettings.isDarkMode,
                        isRegularWidth: isRegularWidth,
                        onTap: {}
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
    }

    private var searchResultsView: some View {
        Group {
            if searchResults.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)

                    Text("No results found")
                        .font(.system(size: isRegularWidth ? 18 : 16))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(searchResults) { word in
                        VocabularyWordRow(
                            word: word,
                            isDarkMode: appSettings.isDarkMode,
                            isRegularWidth: isRegularWidth,
                            onTap: {}
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func performSearch() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        searchResults = allWords.filter { word in
            word.word.contains(searchText) ||
            word.reading.contains(searchText) ||
            word.meaning.lowercased().contains(searchText.lowercased())
        }
    }

    private func updateIsDarkMode() {
        // Force update when theme changes
        _ = appSettings.isDarkMode
    }
}

struct LevelCard: View {
    let level: JLPTLevel
    let wordCount: Int
    let isDarkMode: Bool
    let isRegularWidth: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
            // Level badge
                ZStack {
                    Circle()
                        .fill(levelColors[level] ?? Color.primaryGold)
                        .frame(width: isRegularWidth ? 60 : 50, height: isRegularWidth ? 60 : 50)

                    Text(level.displayName)
                        .font(.system(size: isRegularWidth ? 18 : 14, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("JLPT \(level.displayName)")
                        .font(.system(size: isRegularWidth ? 20 : 18, weight: .bold))
                        .foregroundColor(isDarkMode ? .white : Color.backgroundDark)

                    Text("\(wordCount) words")
                        .font(.system(size: isRegularWidth ? 16 : 14))
                        .foregroundColor(isDarkMode ? Color.white.opacity(0.7) : Color.gray)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: isRegularWidth ? 18 : 16, weight: .medium))
                    .foregroundColor(Color.primaryGold)
            }
            .padding(.horizontal, isRegularWidth ? 20 : 16)
            .padding(.vertical, isRegularWidth ? 16 : 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isDarkMode ? Color.cardDark : Color.cardLight)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
    }
}

struct VocabularyWordRow: View {
    let word: VocabularyWord
    let isDarkMode: Bool
    let isRegularWidth: Bool
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(word.word)
                    .font(.system(size: isRegularWidth ? 20 : 18, weight: .bold))
                    .foregroundColor(isDarkMode ? .white : Color.backgroundDark)

                Text(word.reading)
                    .font(.system(size: isRegularWidth ? 16 : 14))
                    .foregroundColor(isDarkMode ? Color.white.opacity(0.7) : Color.gray)
            }

            Spacer()

            Text(word.meaning)
                .font(.system(size: isRegularWidth ? 14 : 12))
                .foregroundColor(isDarkMode ? Color.white.opacity(0.6) : Color.gray)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: isRegularWidth ? 200 : 120, alignment: .trailing)
        }
        .padding(.horizontal, isRegularWidth ? 16 : 12)
        .padding(.vertical, isRegularWidth ? 14 : 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isDarkMode ? Color.cardDark.opacity(0.5) : Color.gray.opacity(0.05))
        )
    }
}
