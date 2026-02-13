//
//  RootView.swift
//  JLPT Vocabulary Champion
//

import SwiftUI

// MARK: - Vocabulary Word Model
struct VocabularyWord: Identifiable, Codable {
    let word: String
    let reading: String
    let meaning: String
    let level: JLPTLevel

    var id: String { word }

    // Get first meaning (before semicolon) for cleaner display
    var firstMeaning: String {
        return meaning.components(separatedBy: ";").first?.trimmingCharacters(in: .whitespaces) ?? meaning
    }

    enum CodingKeys: String, CodingKey {
        case word, reading, meaning, level
    }
}

// MARK: - Paywall Manager
class PaywallManager: ObservableObject {
    static let shared = PaywallManager()

    @Published var hasPremium: Bool = false
    private let freeWordsPerLevel = 25

    private init() {
        // Check if user has premium
        hasPremium = UserDefaults.standard.bool(forKey: "hasPremium")
    }

    func unlockPremium() {
        hasPremium = true
        UserDefaults.standard.set(true, forKey: "hasPremium")
    }

    func lockPremium() {
        hasPremium = false
        UserDefaults.standard.set(false, forKey: "hasPremium")
    }

    func canViewWord(at index: Int, in level: JLPTLevel) -> Bool {
        if hasPremium {
            return true
        }
        return index < freeWordsPerLevel
    }

    func availableWords(for words: [VocabularyWord], in level: JLPTLevel) -> [VocabularyWord] {
        if hasPremium {
            return words
        }
        let levelWords = words.filter { $0.level == level }
        return Array(levelWords.prefix(freeWordsPerLevel))
    }
}

struct RootView: View {
    @StateObject private var appSettings = AppSettings.shared
    @StateObject private var practiceSettings = PracticeSettings()
    @StateObject private var paywallManager = PaywallManager.shared
    @State private var currentView = "home"

    var body: some View {
        ZStack {
            if currentView == "home" {
                HomeView(currentView: $currentView)
                    .environmentObject(appSettings)
            } else if currentView == "practice" {
                PracticeSettingsView(currentView: $currentView, settings: practiceSettings)
                    .environmentObject(appSettings)
            } else if currentView == "session" {
                PracticeSessionView(currentView: $currentView, settings: practiceSettings)
                    .environmentObject(appSettings)
                    .environmentObject(paywallManager)
            } else if currentView == "library" {
                LibraryHomeView(currentView: $currentView, selectedLevelBinding: Binding(
                    get: { nil },
                    set: { if let level = $0 { currentView = "library_\(level.rawValue)" } }
                ))
                .environmentObject(appSettings)
                .environmentObject(paywallManager)
            } else if currentView.hasPrefix("library_") {
                let levelStr = currentView.replacingOccurrences(of: "library_", with: "")
                if let level = JLPTLevel(rawValue: levelStr) {
                    LibraryLevelDetailView(currentView: $currentView, level: level)
                        .environmentObject(appSettings)
                        .environmentObject(paywallManager)
                }
            } else if currentView == "options" {
                OptionsView(currentView: $currentView)
                    .environmentObject(appSettings)
                    .environmentObject(paywallManager)
            }
        }
        .preferredColorScheme(appSettings.isDarkMode ? .dark : .light)
    }
}

#Preview {
    RootView()
}

// MARK: - Library Home View (Level Categories)
struct LibraryHomeView: View {
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var paywallManager: PaywallManager
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Binding var currentView: String
    @Binding var selectedLevelBinding: JLPTLevel?
    @State private var allWords: [VocabularyWord] = []

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
                // Header
                Text("Library")
                    .font(.system(size: isRegularWidth ? 22 : 18, weight: .bold))
                    .foregroundColor(appSettings.isDarkMode ? .white : Color.backgroundDark)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
                    .padding(.bottom, 20)

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(JLPTLevel.allCases.reversed()) { level in
                            Button(action: {
                                selectedLevelBinding = level
                            }) {
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
                                            .foregroundColor(appSettings.isDarkMode ? .white : Color.backgroundDark)

                                        let count = wordCount(for: level)
                                        Text("\(paywallManager.hasPremium ? count : min(count, 25)) of \(count) words")
                                            .font(.system(size: isRegularWidth ? 16 : 14))
                                            .foregroundColor(appSettings.isDarkMode ? Color.white.opacity(0.7) : Color.gray)
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
                                        .fill(appSettings.isDarkMode ? Color.cardDark : Color.cardLight)
                                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }

            // Back button
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
            loadVocabularyData()
        }
    }

    private func wordCount(for level: JLPTLevel) -> Int {
        return allWords.filter { $0.level == level }.count
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
            if let url = Bundle.main.url(forResource: filename, withExtension: "json"),
               let data = try? Data(contentsOf: url),
               let decoded = try? JSONDecoder().decode([VocabularyWord].self, from: data) {
                loaded.append(contentsOf: decoded)
            }
        }

        allWords = loaded
        print("Loaded \(allWords.count) vocabulary words from JSON")
    }
}

// MARK: - Library Level Detail View
struct LibraryLevelDetailView: View {
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var paywallManager: PaywallManager
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Binding var currentView: String
    let level: JLPTLevel
    @State private var searchText = ""
    @State private var allWords: [VocabularyWord] = []

    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }

    private var filteredWords: [VocabularyWord] {
        let levelWords = allWords.filter { $0.level == level }

        // Apply paywall restriction
        let availableLevelWords: [VocabularyWord]
        if paywallManager.hasPremium {
            availableLevelWords = levelWords
        } else {
            availableLevelWords = Array(levelWords.prefix(25))
        }

        if searchText.isEmpty {
            return availableLevelWords
        }

        let searchLower = searchText.lowercased()
        return availableLevelWords.filter { word in
            word.word.contains(searchText) ||
            word.reading.contains(searchText) ||
            // Search only the first meaning (what's displayed to user)
            word.firstMeaning.lowercased().contains(searchLower)
        }
    }

    private var totalWordsInLevel: Int {
        return allWords.filter { $0.level == level }.count
    }

    var body: some View {
        ZStack {
            (appSettings.isDarkMode ? Color.backgroundDark : Color.backgroundLight)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        currentView = "library"
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

                    Text("JLPT \(level.displayName.uppercased())")
                        .font(.system(size: isRegularWidth ? 22 : 18, weight: .bold))
                        .foregroundColor(appSettings.isDarkMode ? .white : Color.backgroundDark)

                    Spacer()

                    Text("\(filteredWords.count) words")
                        .font(.system(size: isRegularWidth ? 16 : 14))
                        .foregroundColor(appSettings.isDarkMode ? Color.white.opacity(0.7) : Color.gray)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 20)

                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))

                    TextField("Search JLPT \(level.displayName) words", text: $searchText)
                        .font(.system(size: isRegularWidth ? 18 : 16))
                        .foregroundColor(appSettings.isDarkMode ? .white : Color.backgroundDark)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
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

                // Word list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(filteredWords.enumerated()), id: \.offset) { index, word in
                            VocabularyWordRow(word: word, isDarkMode: appSettings.isDarkMode, isRegularWidth: isRegularWidth)
                        }

                        // Paywall lock
                        if !paywallManager.hasPremium && totalWordsInLevel > 25 {
                            PaywallLockView()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            loadVocabularyData()
        }
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
            if let url = Bundle.main.url(forResource: filename, withExtension: "json"),
               let data = try? Data(contentsOf: url),
               let decoded = try? JSONDecoder().decode([VocabularyWord].self, from: data) {
                loaded.append(contentsOf: decoded)
            }
        }

        allWords = loaded
    }
}

// MARK: - Paywall Lock View
struct PaywallLockView: View {
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.system(size: isRegularWidth ? 32 : 28))
                .foregroundColor(Color.primaryGold)

            Text("Purchase the full version")
                .font(.system(size: isRegularWidth ? 18 : 16, weight: .bold))
                .foregroundColor(appSettings.isDarkMode ? .white : Color.backgroundDark)
                .multilineTextAlignment(.center)

            Text("to unlock all \(appSettings.isDarkMode ? "6,705" : "6705") words")
                .font(.system(size: isRegularWidth ? 16 : 14))
                .foregroundColor(appSettings.isDarkMode ? Color.white.opacity(0.7) : Color.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, isRegularWidth ? 32 : 24)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(appSettings.isDarkMode ? Color.cardDark.opacity(0.5) : Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primaryGold.opacity(0.3), lineWidth: 2)
                )
        )
        .padding(.top, 8)
    }
}

// MARK: - Vocabulary Word Row Component
struct VocabularyWordRow: View {
    let word: VocabularyWord
    let isDarkMode: Bool
    let isRegularWidth: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(word.word)
                    .font(.system(size: isRegularWidth ? 20 : 18, weight: .bold))
                    .foregroundColor(isDarkMode ? .white : Color.backgroundDark)

                Text(word.reading)
                    .font(.system(size: isRegularWidth ? 16 : 14))
                    .foregroundColor(isDarkMode ? Color.white.opacity(0.7) : Color.gray)
            }

            Spacer()

            Text(word.firstMeaning)
                .font(.system(size: isRegularWidth ? 14 : 12))
                .foregroundColor(isDarkMode ? Color.white.opacity(0.6) : Color.gray)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: isRegularWidth ? 280 : 180, alignment: .trailing)
        }
        .padding(.horizontal, isRegularWidth ? 16 : 12)
        .padding(.vertical, isRegularWidth ? 14 : 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isDarkMode ? Color.cardDark.opacity(0.5) : Color.gray.opacity(0.05))
        )
    }
}
