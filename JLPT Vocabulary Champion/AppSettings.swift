//
//  AppSettings.swift
//  Kanji Champion
//

import SwiftUI

class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var isDarkMode: Bool = true
    @Published var hasActivePremium: Bool = false
    @Published var useHiragana: Bool = true

    private init() {
        // Private init for singleton
    }

    // Convert hiragana and katakana to romaji
    func toRomaji(_ kana: String) -> String {
        guard !useHiragana else { return kana }

        // Handle empty or whitespace-only strings
        let trimmed = kana.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return kana }

        let kanaToRomajiMap: [String: String] = [
            // Hiragana Vowels
            "あ": "a", "い": "i", "う": "u", "え": "e", "お": "o",
            // Katakana Vowels
            "ア": "a", "イ": "i", "ウ": "u", "エ": "e", "オ": "o",

            // Hiragana K
            "か": "ka", "き": "ki", "く": "ku", "け": "ke", "こ": "ko",
            "きゃ": "kya", "きゅ": "kyu", "きょ": "kyo",
            // Katakana K
            "カ": "ka", "キ": "ki", "ク": "ku", "ケ": "ke", "コ": "ko",
            "キャ": "kya", "キュ": "kyu", "キョ": "kyo",

            // Hiragana G
            "が": "ga", "ぎ": "gi", "ぐ": "gu", "げ": "ge", "ご": "go",
            "ぎゃ": "gya", "ぎゅ": "gyu", "ぎょ": "gyo",
            // Katakana G
            "ガ": "ga", "ギ": "gi", "グ": "gu", "ゲ": "ge", "ゴ": "go",
            "ギャ": "gya", "ギュ": "gyu", "ギョ": "gyo",

            // Hiragana S
            "さ": "sa", "し": "shi", "す": "su", "せ": "se", "そ": "so",
            "しゃ": "sha", "しゅ": "shu", "しょ": "sho",
            // Katakana S
            "サ": "sa", "シ": "shi", "ス": "su", "セ": "se", "ソ": "so",
            "シャ": "sha", "シュ": "shu", "ショ": "sho",

            // Hiragana Z
            "ざ": "za", "じ": "ji", "ず": "zu", "ぜ": "ze", "ぞ": "zo",
            "じゃ": "ja", "じゅ": "ju", "じょ": "jo",
            // Katakana Z
            "ザ": "za", "ジ": "ji", "ズ": "zu", "ゼ": "ze", "ゾ": "zo",
            "ジャ": "ja", "ジュ": "ju", "ジョ": "jo",

            // Hiragana T
            "た": "ta", "ち": "chi", "つ": "tsu", "て": "te", "と": "to",
            "ちゃ": "cha", "ちゅ": "chu", "ちょ": "cho",
            // Katakana T
            "タ": "ta", "チ": "chi", "ツ": "tsu", "テ": "te", "ト": "to",
            "チャ": "cha", "チュ": "chu", "チョ": "cho",

            // Hiragana D
            "だ": "da", "ぢ": "di", "づ": "du", "で": "de", "ど": "do",
            // Katakana D
            "ダ": "da", "ヂ": "di", "ヅ": "du", "デ": "de", "ド": "do",

            // Hiragana N
            "な": "na", "に": "ni", "ぬ": "nu", "ね": "ne", "の": "no",
            "にゃ": "nya", "にゅ": "nyu", "にょ": "nyo",
            // Katakana N
            "ナ": "na", "ニ": "ni", "ヌ": "nu", "ネ": "ne", "ノ": "no",
            "ニャ": "nya", "ニュ": "nyu", "ニョ": "nyo",

            // Hiragana H
            "は": "ha", "ひ": "hi", "ふ": "fu", "へ": "he", "ほ": "ho",
            "ひゃ": "hya", "ひゅ": "hyu", "ひょ": "hyo",
            // Katakana H
            "ハ": "ha", "ヒ": "hi", "フ": "fu", "ヘ": "he", "ホ": "ho",
            "ヒャ": "hya", "ヒュ": "hyu", "ヒョ": "hyo",

            // Hiragana B
            "ば": "ba", "び": "bi", "ぶ": "bu", "べ": "be", "ぼ": "bo",
            "びゃ": "bya", "びゅ": "byu", "びょ": "byo",
            // Katakana B
            "バ": "ba", "ビ": "bi", "ブ": "bu", "ベ": "be", "ボ": "bo",
            "ビャ": "bya", "ビュ": "byu", "ビョ": "byo",

            // Hiragana P
            "ぱ": "pa", "ぴ": "pi", "ぷ": "pu", "ぺ": "pe", "ぽ": "po",
            "ぴゃ": "pya", "ぴゅ": "pyu", "ぴょ": "pyo",
            // Katakana P
            "パ": "pa", "ピ": "pi", "プ": "pu", "ペ": "pe", "ポ": "po",
            "ピャ": "pya", "ピュ": "pyu", "ピョ": "pyo",

            // Hiragana M
            "ま": "ma", "み": "mi", "む": "mu", "め": "me", "も": "mo",
            "みゃ": "mya", "みゅ": "myu", "みょ": "myo",
            // Katakana M
            "マ": "ma", "ミ": "mi", "ム": "mu", "メ": "me", "モ": "mo",
            "ミャ": "mya", "ミュ": "myu", "ミョ": "myo",

            // Hiragana Y
            "や": "ya", "ゆ": "yu", "よ": "yo",
            // Katakana Y
            "ヤ": "ya", "ユ": "yu", "ヨ": "yo",

            // Hiragana R
            "ら": "ra", "り": "ri", "る": "ru", "れ": "re", "ろ": "ro",
            "りゃ": "rya", "りゅ": "ryu", "りょ": "ryo",
            // Katakana R
            "ラ": "ra", "リ": "ri", "ル": "ru", "レ": "re", "ロ": "ro",
            "リャ": "rya", "リュ": "ryu", "リョ": "ryo",

            // Hiragana W
            "わ": "wa", "を": "wo", "ん": "n",
            // Katakana W
            "ワ": "wa", "ヲ": "wo", "ン": "n",

            // Long vowel mark (katakana)
            "ー": "",
        ]

        var result = ""
        var i = trimmed.startIndex

        while i < trimmed.endIndex {
            let char = String(trimmed[i])

            // Handle small tsu (っ/ッ) - doubles the following consonant
            if char == "っ" || char == "ッ" {
                let nextIndex = trimmed.index(after: i)
                if nextIndex < trimmed.endIndex {
                    let nextChar = String(trimmed[nextIndex])
                    if let nextRomaji = kanaToRomajiMap[nextChar], !nextRomaji.isEmpty {
                        result.append(nextRomaji.first!)
                    }
                }
                i = trimmed.index(after: i)
                continue
            }

            // Handle long vowel mark (ー) - extends previous vowel
            if char == "ー" {
                if !result.isEmpty {
                    let lastChar = result.last!
                    // Extend the vowel by duplicating it
                    if "aeiou".contains(lastChar) {
                        result.append(lastChar)
                    }
                }
                i = trimmed.index(after: i)
                continue
            }

            // Try to match 2-character combinations first (like きゃ/キャ)
            let nextIndex = trimmed.index(after: i)
            if nextIndex < trimmed.endIndex {
                let twoChar = String(trimmed[i..<trimmed.index(after: nextIndex)])
                if let romaji = kanaToRomajiMap[twoChar] {
                    result.append(romaji)
                    i = trimmed.index(after: nextIndex)
                    continue
                }
            }

            // Try single character
            if let romaji = kanaToRomajiMap[char] {
                result.append(romaji)
            } else {
                result.append(char) // Keep unknown characters as-is
            }

            i = trimmed.index(after: i)
        }

        return result.isEmpty ? kana : result
    }
}
