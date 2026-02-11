//
//  KanjiData.swift
//  Kanji Champion
//

import Foundation

struct KanjiCharacter: Identifiable, Codable {
    let character: String
    let meaning: String
    let onyomi: String
    let kunyomi: String
    let level: String  // Changed from JLPTLevel to String
    let noJlptIndicated: Bool

    var id: String { character }

    enum CodingKeys: String, CodingKey {
        case character, meaning, onyomi, kunyomi, level, noJlptIndicated
    }
}

struct KanjiDataWrapper: Codable {
    let kanji: [KanjiCharacter]
}

class KanjiDatabase {
    static let shared = KanjiDatabase()

    let allKanji: [KanjiCharacter]
    private let kanjiLookup: [String: KanjiCharacter]

    private init() {
        // Load kanji data from JSON file
        guard let url = Bundle.main.url(forResource: "kanji_data", withExtension: "json") else {
            print("ERROR: Could not find kanji_data.json in bundle")
            self.allKanji = []
            self.kanjiLookup = [:]
            return
        }

        guard let data = try? Data(contentsOf: url) else {
            print("ERROR: Could not load data from kanji_data.json")
            self.allKanji = []
            self.kanjiLookup = [:]
            return
        }

        guard let decoded = try? JSONDecoder().decode(KanjiDataWrapper.self, from: data) else {
            print("ERROR: Could not decode kanji_data.json")
            self.allKanji = []
            self.kanjiLookup = [:]
            return
        }

        self.allKanji = decoded.kanji

        // Create O(1) lookup dictionary
        var lookup: [String: KanjiCharacter] = [:]
        for kanji in allKanji {
            lookup[kanji.character] = kanji
        }
        self.kanjiLookup = lookup

        print("Successfully loaded \(allKanji.count) kanji from JSON")
    }

    func getKanji(forLevels levels: Set<String>) -> [KanjiCharacter] {
        return allKanji.filter { levels.contains($0.level) }
    }

    func getKanji(character: String) -> KanjiCharacter? {
        return kanjiLookup[character]
    }
}
