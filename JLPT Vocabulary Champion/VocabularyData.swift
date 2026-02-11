//
//  VocabularyData.swift
//  JLPT Vocabulary Champion
//

import Foundation

struct VocabularyWord: Identifiable, Codable {
    let word: String
    let reading: String
    let meaning: String
    let level: JLPTLevel

    var id: String { word }

    enum CodingKeys: String, CodingKey {
        case word, reading, meaning, level
    }
}

struct VocabularyDataWrapper: Codable {
    let vocabulary: [VocabularyWord]
}

class VocabularyDatabase {
    static let shared = VocabularyDatabase()

    let allVocabulary: [VocabularyWord]
    private let vocabularyLookup: [String: VocabularyWord]

    private init() {
        // Load vocabulary data from JSON files
        var allWords: [VocabularyWord] = []

        for level in JLPTLevel.allCases {
            let fileName = "vocabulary_\(level.rawValue)"
            guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
                print("WARNING: Could not find \(fileName).json in bundle")
                continue
            }

            guard let data = try? Data(contentsOf: url) else {
                print("WARNING: Could not load data from \(fileName).json")
                continue
            }

            guard let decoded = try? JSONDecoder().decode([VocabularyWord].self, from: data) else {
                print("WARNING: Could not decode \(fileName).json")
                continue
            }

            allWords.append(contentsOf: decoded)
        }

        self.allVocabulary = allWords

        // Create O(1) lookup dictionary
        var lookup: [String: VocabularyWord] = [:]
        for vocab in allVocabulary {
            lookup[vocab.word] = vocab
        }
        self.vocabularyLookup = lookup

        print("Successfully loaded \(allVocabulary.count) vocabulary words from JSON")
    }

    func getVocabulary(forLevels levels: Set<JLPTLevel>) -> [VocabularyWord] {
        return allVocabulary.filter { levels.contains($0.level) }
    }

    func getVocabulary(word: String) -> VocabularyWord? {
        return vocabularyLookup[word]
    }

    func searchVocabulary(query: String) -> [VocabularyWord] {
        guard !query.isEmpty else { return [] }

        let lowerQuery = query.lowercased()
        return allVocabulary.filter { vocab in
            vocab.word.contains(query) ||
            vocab.reading.contains(query) ||
            vocab.meaning.lowercased().contains(lowerQuery)
        }
    }
}
