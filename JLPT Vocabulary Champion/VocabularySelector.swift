//
//  VocabularySelector.swift
//  JLPT Vocabulary Champion
//

import Foundation

struct VocabularyQuizItem: Equatable {
    let vocabulary: VocabularyWord
    let quizType: QuizType

    static func == (lhs: VocabularyQuizItem, rhs: VocabularyQuizItem) -> Bool {
        return lhs.vocabulary.word == rhs.vocabulary.word && lhs.quizType == rhs.quizType
    }
}

class VocabularySelector {
    private var recentItems: [VocabularyQuizItem] = []
    private let maxRecentItems = 20

    func selectNext(
        from vocabularyList: [VocabularyWord],
        quizTypes: Set<QuizType>,
        mode: PracticeMode
    ) -> VocabularyQuizItem? {
        // Create all possible combinations of vocabulary and quiz types
        var allPossibleItems: [VocabularyQuizItem] = []
        for vocabulary in vocabularyList {
            for quizType in quizTypes {
                allPossibleItems.append(VocabularyQuizItem(vocabulary: vocabulary, quizType: quizType))
            }
        }

        // Filter out items shown in last 20
        let availableItems = allPossibleItems.filter { item in
            !recentItems.contains(item)
        }

        // If all items have been shown recently, clear the recent list
        guard !availableItems.isEmpty else {
            recentItems.removeAll()
            return selectNext(from: vocabularyList, quizTypes: quizTypes, mode: mode)
        }

        // Select based on practice mode
        let selectedItem: VocabularyQuizItem?
        switch mode {
        case .frequentMistakes, .variety, .randomness:
            selectedItem = availableItems.randomElement()
        }

        if let item = selectedItem {
            recentItems.append(item)
            if recentItems.count > maxRecentItems {
                recentItems.removeFirst()
            }
        }

        return selectedItem
    }
}
