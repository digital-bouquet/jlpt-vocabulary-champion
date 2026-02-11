//
//  PracticeSettings.swift
//  JLPT Vocabulary Champion
//

import Foundation

enum JLPTLevel: String, CaseIterable, Identifiable, Codable {
    case n5 = "n5"
    case n4 = "n4"
    case n3 = "n3"
    case n2 = "n2"
    case n1 = "n1"

    var id: String { self.rawValue }

    var displayName: String {
        return self.rawValue.uppercased()
    }
}

enum QuizType: String, CaseIterable {
    case meaning = "Meaning"
    case reading = "Reading"
}

enum PracticeMode: String, CaseIterable {
    case frequentMistakes = "Prioritize Frequent Mistakes"
    case variety = "Prioritize Variety"
    case randomness = "Prioritize Randomness"

    var description: String {
        switch self {
        case .frequentMistakes:
            return "Focus on the words that keep challenging you the most."
        case .variety:
            return "A balanced blend of new words and past reviews."
        case .randomness:
            return "Let fate decide. Pure shuffle mode for advanced learners."
        }
    }
}

class PracticeSettings: ObservableObject {
    @Published var selectedLevels: Set<JLPTLevel> = [.n5]
    @Published var selectedQuizTypes: Set<QuizType> = [.meaning]
    @Published var practiceMode: PracticeMode = .frequentMistakes
}
