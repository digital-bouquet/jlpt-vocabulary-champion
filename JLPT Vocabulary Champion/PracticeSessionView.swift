//
//  PracticeSessionView.swift
//  JLPT Vocabulary Champion
//

import SwiftUI

struct Answer: Identifiable {
    let id = UUID()
    let text: String
    var isCorrect: Bool = false
    var isSelected: Bool = false
}

struct PracticeSessionView: View {
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var paywallManager: PaywallManager
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Binding var currentView: String
    @ObservedObject var settings: PracticeSettings

    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }

    @State private var currentWord: VocabularyWord?
    @State private var questionType: QuizType = .meaning
    @State private var answers: [Answer] = []
    @State private var hasAnswered = false
    @State private var vocabularyWords: [VocabularyWord] = []
    @State private var shadowSize: CGFloat = 200
    @State private var wordDisplaySize: CGFloat = 120

    init(currentView: Binding<String>, settings: PracticeSettings) {
        self._currentView = currentView
        self.settings = settings
    }

    var questionPrompt: String {
        switch questionType {
        case .meaning:
            return "CHOOSE THE CORRECT MEANING\nTO CONTINUE YOUR PATH."
        case .reading:
            return "CHOOSE THE CORRECT READING\nTO CONTINUE YOUR PATH."
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                (appSettings.isDarkMode ? Color.backgroundDark : Color.backgroundLight)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                // Top Navigation
                HStack {
                    Button(action: {
                        currentView = "home"
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: isRegularWidth ? 22 : 18, weight: .medium))

                            Text("Back")
                                .font(.system(size: isRegularWidth ? 22 : 18))
                        }
                        .foregroundColor(Color.primaryGold)
                    }

                    Spacer()

                    Text("Practice")
                        .font(.system(size: isRegularWidth ? 24 : 20, weight: .bold))
                        .foregroundColor(appSettings.isDarkMode ? .white : Color.backgroundDark)

                    Spacer()

                    Color.clear
                        .frame(width: isRegularWidth ? 90 : 70)
                }
                .padding(.horizontal, 20)
                .padding(.top, max(12, geometry.size.height * 0.018))
                .padding(.bottom, max(12, geometry.size.height * 0.018))

                // Word display area - fixed height so answer grid stays in place
                VStack(spacing: 0) {
                    Spacer()

                    // Word Display - Matching Kanji Champion shadow effect
                    ZStack {
                        // Echo/shadow layer - larger, faded behind main text
                        Text(currentWord?.word ?? "")
                            .font(.system(size: shadowSize, weight: .bold))
                            .foregroundColor((appSettings.isDarkMode ? Color.white : Color.backgroundDark).opacity(0.05))

                        // Main text layer
                        Text(currentWord?.word ?? "")
                            .font(.system(size: wordDisplaySize, weight: .heavy))
                            .foregroundColor(appSettings.isDarkMode ? .white : Color.backgroundDark)
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                            .shadow(color: Color.primaryGold.opacity(0.15), radius: 40)
                            .onAppear {
                                updateWordSize(for: currentWord?.word ?? "", in: geometry.size.width, height: geometry.size.height)
                            }
                            .onChange(of: currentWord?.word ?? "") { _, _ in
                                updateWordSize(for: currentWord?.word ?? "", in: geometry.size.width, height: geometry.size.height)
                            }
                    }

                    Spacer()

                    // Gold divider line
                    HStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.primaryGold.opacity(0.3))
                            .frame(width: 48, height: 4)
                    }
                    .padding(.bottom, max(16, geometry.size.height * 0.024))
                }
                .frame(height: geometry.size.height * 0.30)

                // Answer Grid - Square buttons matching Kanji Champion
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2),
                    spacing: 16
                ) {
                    ForEach($answers) { $answer in
                        Button(action: {
                            if !hasAnswered {
                                hasAnswered = true
                                answer.isSelected = true

                                if let correctIndex = answers.firstIndex(where: { $0.isCorrect }) {
                                    answers[correctIndex].isSelected = true
                                }

                                // Play sound effect
                                if answer.isCorrect {
                                    SoundManager.shared.playCorrect()
                                } else {
                                    SoundManager.shared.playIncorrect()
                                }

                                // Progress to next question after 1 second
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    nextQuestion()
                                }
                            }
                        }) {
                            ZStack {
                                // Background
                                if hasAnswered && answer.isSelected {
                                    if answer.isCorrect {
                                        Color.correctGreen
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
                                            )
                                    } else {
                                        Color.incorrectRed
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.incorrectRed.opacity(0.5), lineWidth: 2)
                                            )
                                    }
                                } else {
                                    Color.primaryGold
                                        .overlay(
                                            VStack {
                                                Spacer()
                                                Rectangle()
                                                    .fill(Color.black.opacity(0.2))
                                                    .frame(height: 4)
                                            }
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }

                                ZStack {
                                    Text(answer.text)
                                        .font(.system(size: isRegularWidth ? 26 : 20, weight: .bold))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .minimumScaleFactor(0.5)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)

                                    if hasAnswered && answer.isSelected {
                                        VStack {
                                            HStack {
                                                Spacer()
                                                Image(systemName: answer.isCorrect ? "checkmark.circle.fill" : "xmark")
                                                    .font(.system(size: 18))
                                                    .foregroundColor(.white)
                                                    .padding(12)
                                            }
                                            Spacer()
                                        }
                                    }
                                }
                            }
                            .aspectRatio(1, contentMode: .fit)
                            .cornerRadius(12)
                            .shadow(
                                color: hasAnswered && answer.isSelected ?
                                (answer.isCorrect ? Color.correctGreen.opacity(0.2) : Color.incorrectRed.opacity(0.2)) :
                                Color.black.opacity(0.15),
                                radius: 8
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(hasAnswered)
                    }
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: isRegularWidth ? 560 : .infinity)

                Spacer()
                    .frame(height: geometry.size.height * 0.08)

                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        Rectangle()
                            .fill((appSettings.isDarkMode ? Color.white : Color.backgroundDark).opacity(0.5))
                            .frame(width: 32, height: 1)

                        Image(systemName: "leaf.fill")
                            .font(.system(size: 14))
                            .foregroundColor((appSettings.isDarkMode ? Color.white : Color.backgroundDark).opacity(0.4))

                        Rectangle()
                            .fill((appSettings.isDarkMode ? Color.white : Color.backgroundDark).opacity(0.5))
                            .frame(width: 32, height: 1)
                    }

                    Text(questionPrompt)
                        .font(.system(size: 11, weight: .medium))
                        .tracking(1.5)
                        .foregroundColor((appSettings.isDarkMode ? Color.white : Color.backgroundDark).opacity(0.4))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.bottom, max(20, geometry.size.height * 0.03))
            }
            }
        }
        .onAppear {
            loadVocabularyData()
        }
    }

    private func nextQuestion() {
        hasAnswered = false
        loadNextQuestion()
    }

    private func loadVocabularyData() {
        var loaded: [VocabularyWord] = []
        let levels: [(JLPTLevel, String)] = [
            (.n5, "vocabulary_n5"),
            (.n4, "vocabulary_n4"),
            (.n3, "vocabulary_n3"),
            (.n2, "vocabulary_n2"),
            (.n1, "vocabulary_n1"),
        ]

        for (level, filename) in levels {
            if settings.selectedLevels.contains(level) {
                if let url = Bundle.main.url(forResource: filename, withExtension: "json"),
                   let data = try? Data(contentsOf: url),
                   let decoded = try? JSONDecoder().decode([VocabularyWord].self, from: data) {
                    loaded.append(contentsOf: decoded)
                }
            }
        }

        // Apply paywall restriction - limit to 25 words per selected level for free users
        if !paywallManager.hasPremium {
            var limitedWords: [VocabularyWord] = []
            for level in settings.selectedLevels {
                let levelWords = loaded.filter { $0.level == level }
                limitedWords.append(contentsOf: Array(levelWords.prefix(25)))
            }
            vocabularyWords = limitedWords
        } else {
            vocabularyWords = loaded
        }

        print("Loaded \(vocabularyWords.count) vocabulary words for practice (premium: \(paywallManager.hasPremium))")
        loadNextQuestion()
    }

    private func loadNextQuestion() {
        // Pick quiz type from selected types each question
        questionType = settings.selectedQuizTypes.randomElement() ?? .meaning

        // Get available words based on quiz type
        let availableWords: [VocabularyWord]

        if questionType == .reading {
            // Filter out kana-only words for reading quiz
            availableWords = vocabularyWords.filter { settings.selectedLevels.contains($0.level) && !isKanaOnly($0.word) }
        } else {
            availableWords = vocabularyWords.filter { settings.selectedLevels.contains($0.level) }
        }

        guard !availableWords.isEmpty else {
            // If no words available for reading quiz, fall back to meaning
            if questionType == .reading {
                questionType = .meaning
                loadNextQuestion()
                return
            }
            currentWord = vocabularyWords.first
            generateAnswers()
            return
        }

        currentWord = availableWords.randomElement()
        generateAnswers()
    }

    private func isKanaOnly(_ text: String) -> Bool {
        return text.allSatisfy { c in
            // Check if character is hiragana or katakana
            let scalars = c.unicodeScalars
            if let scalar = scalars.first {
                // Hiragana: U+3040 to U+309F
                // Katakana: U+30A0 to U+30FF
                return (scalar.value >= 0x3040 && scalar.value <= 0x309F) ||
                       (scalar.value >= 0x30A0 && scalar.value <= 0x30FF)
            }
            return false
        }
    }

    private func truncateMeaning(_ meaning: String, maxLength: Int = 35) -> String {
        guard meaning.count > maxLength else { return meaning }
        let truncated = meaning.prefix(maxLength)
        // Break at last space to avoid cutting mid-word
        if let lastSpace = truncated.lastIndex(of: " ") {
            return String(truncated[truncated.startIndex..<lastSpace]) + "…"
        }
        return String(truncated) + "…"
    }

    private func updateWordSize(for word: String, in maxWidth: CGFloat, height: CGFloat) {
        let charCount = word.count

        // Scale based on character count, using Kanji Champion's min(fixed, geometry) pattern
        if charCount <= 1 {
            // Single character — match Kanji Champion exactly
            wordDisplaySize = min(isRegularWidth ? 160 : 120, height * (isRegularWidth ? 0.18 : 0.135))
        } else if charCount <= 2 {
            wordDisplaySize = min(isRegularWidth ? 140 : 100, height * (isRegularWidth ? 0.16 : 0.12))
        } else if charCount <= 4 {
            wordDisplaySize = min(isRegularWidth ? 110 : 80, height * (isRegularWidth ? 0.13 : 0.10))
        } else if charCount <= 6 {
            wordDisplaySize = min(isRegularWidth ? 85 : 60, height * (isRegularWidth ? 0.10 : 0.08))
        } else {
            wordDisplaySize = min(isRegularWidth ? 70 : 48, height * (isRegularWidth ? 0.08 : 0.06))
        }

        // Shadow at 1.5x (matching Kanji Champion ratio)
        shadowSize = wordDisplaySize * 1.5
    }

    private func generateAnswers() {
        guard let word = currentWord else { return }

        var correctAnswer: String = ""
        var allOptions: [String] = []

        switch questionType {
        case .meaning:
            // Pick one random meaning from the first 3 (semicolon-separated)
            let meanings = word.meaning.components(separatedBy: ";").prefix(3).map { $0.trimmingCharacters(in: .whitespaces) }
            correctAnswer = truncateMeaning(meanings.randomElement() ?? word.meaning)

            // Pick one random meaning from the first 3 for each option
            allOptions = vocabularyWords.compactMap { w in
                let m = w.meaning.components(separatedBy: ";").prefix(3).map { $0.trimmingCharacters(in: .whitespaces) }
                return truncateMeaning(m.randomElement() ?? "")
            }
        case .reading:
            correctAnswer = word.reading
            allOptions = vocabularyWords.map { $0.reading }
        }

        // Get unique wrong answers
        var wrongAnswers = allOptions.filter { $0 != correctAnswer }.shuffled()
        wrongAnswers = Array(Set(wrongAnswers)).shuffled()
        wrongAnswers = Array(wrongAnswers.prefix(3))

        var allAnswers = wrongAnswers + [correctAnswer]
        allAnswers.shuffle()

        answers = allAnswers.map { answer in
            Answer(text: answer, isCorrect: answer == correctAnswer)
        }
    }
}

#Preview {
    PracticeSessionView(currentView: .constant("session"), settings: PracticeSettings())
        .environmentObject(AppSettings.shared)
        .environmentObject(PaywallManager.shared)
}
