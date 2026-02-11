//
//  VocabularyDetailView.swift
//  JLPT Vocabulary Champion
//

import SwiftUI

struct VocabularyDetailView: View {
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Binding var currentView: String
    @Binding var selectedLevel: JLPTLevel?
    let word: VocabularyWord
    @Binding var selectedWord: VocabularyWord?

    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
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
                                selectedWord = nil
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

                            Text("Word Detail")
                                .font(.system(size: isRegularWidth ? 22 : 18, weight: .bold))
                                .foregroundColor(appSettings.isDarkMode ? .white : Color.backgroundDark)

                            Spacer()

                            Color.clear.frame(width: isRegularWidth ? 90 : 70)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 20)

                        VStack(spacing: 24) {
                            // Large Word Display Card
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                levelColors[word.level] ?? .primaryGold,
                                                levelColors[word.level] ?? .primaryGoldDark
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: (levelColors[word.level] ?? .primaryGold).opacity(0.4), radius: 12, x: 0, y: 6)

                                VStack(spacing: 12) {
                                    Text(word.word)
                                        .font(.system(size: isRegularWidth ? 56 : 44, weight: .heavy))
                                        .foregroundColor(Color.white)

                                    Text(word.reading)
                                        .font(.system(size: isRegularWidth ? 24 : 20, weight: .medium))
                                        .foregroundColor(.white.opacity(0.9))
                                }
                            }
                            .frame(maxWidth: isRegularWidth ? 400 : .infinity)
                            .padding(.horizontal, isRegularWidth ? 40 : 24)
                            .padding(.vertical, isRegularWidth ? 48 : 36)

                            // JLPT Level Badge
                            HStack {
                                Capsule()
                                    .fill(levelColors[word.level] ?? .primaryGold)
                                    .frame(width: 4, height: isRegularWidth ? 20 : 16)

                                Text("JLPT \(word.level.displayName)")
                                    .font(.system(size: isRegularWidth ? 18 : 14, weight: .bold))
                                    .tracking(1.5)
                                    .foregroundColor(appSettings.isDarkMode ? .white : Color.backgroundDark)
                            }

                            // Meaning Card
                            VStack(alignment: .leading, spacing: isRegularWidth ? 14 : 12) {
                                HStack(spacing: 8) {
                                    Capsule()
                                        .fill(Color.primaryGold)
                                        .frame(width: 4, height: isRegularWidth ? 20 : 16)

                                    Text("MEANING")
                                        .font(.system(size: isRegularWidth ? 14 : 12, weight: .bold))
                                        .tracking(2)
                                        .foregroundColor(appSettings.isDarkMode ? Color.white.opacity(0.7) : Color.gray)

                                    Spacer()
                                }

                                Text(word.meaning)
                                    .font(.system(size: isRegularWidth ? 20 : 18, weight: .semibold))
                                    .foregroundColor(appSettings.isDarkMode ? .white : Color.backgroundDark)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, isRegularWidth ? 20 : 16)
                                    .padding(.vertical, isRegularWidth ? 20 : 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(appSettings.isDarkMode ? Color.secondaryBrownDark.opacity(0.3) : Color.gray.opacity(0.1))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.secondaryBrown.opacity(0.2), lineWidth: 1)
                                            )
                                    )
                            }
                            .padding(.horizontal, 16)
                            .frame(maxWidth: isRegularWidth ? 560 : .infinity)

                            // Practice buttons
                            HStack(spacing: 16) {
                                Button(action: {
                                    // Practice meaning
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "text.book.closed")
                                            .font(.system(size: isRegularWidth ? 24 : 20))

                                        Text("Practice\nMeaning")
                                            .font(.system(size: isRegularWidth ? 14 : 12, weight: .medium))
                                            .multilineTextAlignment(.center)
                                    }
                                    .foregroundColor(Color.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, isRegularWidth ? 16 : 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.primaryGold)
                                    )
                                }

                                Button(action: {
                                    // Practice reading
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "text.bubble")
                                            .font(.system(size: isRegularWidth ? 24 : 20))

                                        Text("Practice\nReading")
                                            .font(.system(size: isRegularWidth ? 14 : 12, weight: .medium))
                                            .multilineTextAlignment(.center)
                                    }
                                    .foregroundColor(Color.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, isRegularWidth ? 16 : 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.secondaryBrown)
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                            .frame(maxWidth: isRegularWidth ? 560 : .infinity)
                        }
                        .padding(.bottom, 40)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

#Preview {
    VocabularyDetailView(
        currentView: .constant("detail"),
        selectedLevel: .constant(nil),
        word: VocabularyWord(
            word: "日本",
            reading: "にほん",
            meaning: "Japan",
            level: .n5
        ),
        selectedWord: .constant(nil)
    )
    .environmentObject(AppSettings.shared)
}
