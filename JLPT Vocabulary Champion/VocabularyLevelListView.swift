//
//  VocabularyLevelListView.swift
//  JLPT Vocabulary Champion
//

import SwiftUI

struct VocabularyLevelListView: View {
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Binding var currentView: String
    let level: JLPTLevel
    @Binding var selectedLevel: JLPTLevel?
    @State private var selectedWord: VocabularyWord?

    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }

    private var words: [VocabularyWord] {
        VocabularyDatabase.shared.getVocabulary(forLevels: [level])
    }

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
                ScrollView {
                    VStack(spacing: 0) {
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
                                .foregroundColor(Color.primaryGold)
                            }

                            Spacer()

                            Text("JLPT \(level.displayName)")
                                .font(.system(size: isRegularWidth ? 22 : 18, weight: .bold))
                                .foregroundColor(appSettings.isDarkMode ? .white : Color.backgroundDark)

                            Spacer()

                            Color.clear.frame(width: isRegularWidth ? 90 : 70)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 20)

                        // Word count badge
                        HStack(spacing: 8) {
                            Circle()
                                .fill(levelColors[level] ?? .primaryGold)
                                .frame(width: 8, height: 8)

                            Text("\(words.count) words")
                                .font(.system(size: isRegularWidth ? 16 : 14))
                                .foregroundColor(isDarkMode ? .white.opacity(0.7) : .gray)
                        }
                        .padding(.bottom, 16)

                        // Word list
                        VStack(spacing: 12) {
                            ForEach(words) { word in
                                VocabularyWordRow(
                                    word: word,
                                    isDarkMode: appSettings.isDarkMode,
                                    isRegularWidth: isRegularWidth,
                                    onTap: {
                                        selectedWord = word
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .onAppear {
            updateIsDarkMode()
        }
        .onChange(of: appSettings.isDarkMode) { _, _ in
            updateIsDarkMode()
        }

        // Navigation overlay for detail view
        if let word = selectedWord {
            VocabularyDetailView(
                currentView: $currentView,
                selectedLevel: $selectedLevel,
                word: word,
                selectedWord: $selectedWord
            )
            .transition(.move(edge: .trailing))
            .zIndex(4)
        }
    }

    private var isDarkMode: Bool {
        appSettings.isDarkMode
    }

    private func updateIsDarkMode() {
        // Force update when theme changes
        _ = isDarkMode
    }
}

#Preview {
    VocabularyLevelListView(
        currentView: .constant("levelList"),
        level: .n5,
        selectedLevel: .constant(.n5)
    )
    .environmentObject(AppSettings.shared)
}
