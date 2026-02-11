//
//  VocabularyLibraryView.swift
//  JLPT Vocabulary Champion
//

import SwiftUI

struct VocabularyLibraryView: View {
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Binding var currentView: String

    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }

    @State private var selectedLevel: JLPTLevel?
    @State private var searchText: String = ""
    @State private var searchResults: [VocabularyWord] = []

    @FocusState private var searchFieldFocused: Bool

    var body: some View {
        ZStack {
            (appSettings.isDarkMode ? Color.backgroundDark : Color.backgroundLight)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        // Header with title
                        Text("Library")
                            .font(.system(size: isRegularWidth ? 22 : 18, weight: .bold))
                            .foregroundColor(appSettings.isDarkMode ? .white : Color.backgroundDark)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 16)
                            .padding(.bottom, 20)

                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color.gray)
                                .font(.system(size: isRegularWidth ? 18 : 16))

                            TextField("Search words, readings, or meanings", text: $searchText)
                                .font(.system(size: isRegularWidth ? 18 : 16))
                                .foregroundColor(appSettings.isDarkMode ? .white : Color.backgroundDark)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .focused($searchFieldFocused)
                                .onChange(of: searchText) { oldValue, newValue in
                                    performSearch()
                                }
                                .onSubmit {
                                    searchFieldFocused = false
                                }

                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                    searchResults = []
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Color.gray)
                                        .font(.system(size: 16))
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

                        if searchText.isEmpty {
                            // Show level categories
                            levelCategoriesView
                        } else {
                            // Show search results
                            searchResultsView
                        }
                    }
                    .padding(.bottom, 40)
                }
            }

            // Absolutely positioned back button
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
                        .foregroundColor(Color.primaryGold)
                        .padding(.horizontal, isRegularWidth ? 16 : 12)
                        .padding(.vertical, isRegularWidth ? 10 : 8)
                        .background(
                            Capsule()
                                .fill(appSettings.isDarkMode ? Color.backgroundDark : Color.backgroundLight)
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                    }
                    .padding(.leading, 16)
                    .padding(.top, 16)

                    Spacer()
                }

                Spacer()
            }
            .zIndex(2)

            // Navigation overlay for level detail view
            if let level = selectedLevel {
                VocabularyLevelListView(
                    currentView: $currentView,
                    level: level,
                    selectedLevel: $selectedLevel
                )
                .transition(.move(edge: .trailing))
                .zIndex(3)
            }
        }
    }

    private var levelCategoriesView: some View {
        VStack(spacing: 16) {
            ForEach(JLPTLevel.allCases.reversed()) { level in
                LevelCard(
                    level: level,
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

    private var searchResultsView: some View {
        Group {
            if searchResults.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(Color.gray)

                    Text("No results found")
                        .font(.system(size: isRegularWidth ? 18 : 16))
                        .foregroundColor(Color.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            } else {
                VStack(spacing: 12) {
                    ForEach(searchResults) { word in
                        VocabularyWordRow(
                            word: word,
                            isDarkMode: appSettings.isDarkMode,
                            isRegularWidth: isRegularWidth,
                            onTap: {
                                // Show word detail
                                selectedLevel = word.level
                            }
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
        searchResults = VocabularyDatabase.shared.searchVocabulary(query: searchText)
    }
}

struct LevelCard: View {
    let level: JLPTLevel
    let isDarkMode: Bool
    let isRegularWidth: Bool
    let onTap: () -> Void

    private let levelColors: [JLPTLevel: Color] = [
        .n5: Color(hex: "#4CAF50"),
        .n4: Color(hex: "#2196F3"),
        .n3: Color(hex: "#FF9800"),
        .n2: Color(hex: "#9C27B0"),
        .n1: Color(hex: "#F44336")
    ]

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Level badge
                ZStack {
                    Circle()
                        .fill(levelColors[level] ?? .primaryGold)
                        .frame(width: isRegularWidth ? 60 : 50, height: isRegularWidth ? 60 : 50)

                    Text(level.displayName)
                        .font(.system(size: isRegularWidth ? 18 : 14, weight: .bold))
                        .foregroundColor(Color.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("JLPT \(level.displayName)")
                        .font(.system(size: isRegularWidth ? 20 : 18, weight: .bold))
                        .foregroundColor(isDarkMode ? .white : Color.backgroundDark)

                    Text(wordCountText)
                        .font(.system(size: isRegularWidth ? 16 : 14))
                        .foregroundColor(isDarkMode ? .white.opacity(0.7) : Color.gray)
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

    private var wordCountText: String {
        let count = VocabularyDatabase.shared.getVocabulary(forLevels: [level]).count
        return "\(count) words"
    }
}

struct VocabularyWordRow: View {
    let word: VocabularyWord
    let isDarkMode: Bool
    let isRegularWidth: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(word.word)
                        .font(.system(size: isRegularWidth ? 20 : 18, weight: .bold))
                        .foregroundColor(isDarkMode ? .white : Color.backgroundDark)

                    Text(word.reading)
                        .font(.system(size: isRegularWidth ? 16 : 14))
                        .foregroundColor(isDarkMode ? .white.opacity(0.7) : Color.gray)
                }

                Spacer()

                Text(word.meaning)
                    .font(.system(size: isRegularWidth ? 14 : 12))
                    .foregroundColor(isDarkMode ? .white.opacity(0.6) : Color.gray)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: isRegularWidth ? 200 : 120, alignment: .trailing)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.primaryGold)
            }
            .padding(.horizontal, isRegularWidth ? 16 : 12)
            .padding(.vertical, isRegularWidth ? 14 : 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isDarkMode ? Color.cardDark.opacity(0.5) : Color.gray.opacity(0.05))
            )
        }
    }
}

#Preview {
    VocabularyLibraryView(currentView: .constant("library"))
        .environmentObject(AppSettings.shared)
}
