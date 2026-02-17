//
//  KanjiHistory.swift
//  Kanji Champion
//

import Foundation

struct KanjiStats: Codable {
    var meaningCorrect: Int = 0
    var meaningTotal: Int = 0
    var readingCorrect: Int = 0  // Changed from onyomi
    var readingTotal: Int = 0     // Changed from onyomi
}

class KanjiHistoryManager: ObservableObject {
    static let shared = KanjiHistoryManager()

    @Published private var history: [String: KanjiStats] = [:]

    private let userDefaultsKey = "kanjiHistory"

    init() {
        loadHistory()
    }

    func getStats(for character: String) -> KanjiStats {
        return history[character] ?? KanjiStats()
    }

    func recordAnswer(character: String, quizType: QuizType, isCorrect: Bool) {
        var stats = history[character] ?? KanjiStats()

        switch quizType {
        case .meaning:
            stats.meaningTotal += 1
            if isCorrect {
                stats.meaningCorrect += 1
            }
        case .reading:  // Changed from onyomi/kunyomi
            stats.readingTotal += 1
            if isCorrect {
                stats.readingCorrect += 1
            }
        }

        history[character] = stats
        saveHistory()
    }

    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([String: KanjiStats].self, from: data) {
            history = decoded
        }
    }

    func clearAllHistory() {
        history.removeAll()
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }

    var totalWordsPracticed: Int {
        return history.filter { $0.value.meaningTotal > 0 || $0.value.readingTotal > 0 }.count
    }

    var totalAttempts: Int {
        return history.values.reduce(0) { $0 + $1.meaningTotal + $1.readingTotal }
    }
}
