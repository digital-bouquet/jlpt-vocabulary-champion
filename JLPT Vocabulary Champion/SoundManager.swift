//
//  SoundManager.swift
//  Kanji Champion
//

import AVFoundation

class SoundManager {
    static let shared = SoundManager()

    private var correctPlayer: AVAudioPlayer?
    private var incorrectPlayer: AVAudioPlayer?

    private init() {
        loadSounds()
    }

    private func loadSounds() {
        if let correctURL = Bundle.main.url(forResource: "Correct", withExtension: "mp3") {
            correctPlayer = try? AVAudioPlayer(contentsOf: correctURL)
            correctPlayer?.prepareToPlay()
        }

        if let incorrectURL = Bundle.main.url(forResource: "Incorrect", withExtension: "mp3") {
            incorrectPlayer = try? AVAudioPlayer(contentsOf: incorrectURL)
            incorrectPlayer?.prepareToPlay()
        }
    }

    func playCorrect() {
        correctPlayer?.currentTime = 0
        correctPlayer?.play()
    }

    func playIncorrect() {
        incorrectPlayer?.currentTime = 0
        incorrectPlayer?.play()
    }
}
