//
//  ColorTheme.swift
//  JLPT Vocabulary Champion
//

import SwiftUI

extension Color {
    // Primary brand color - Gold
    static let primaryGold = Color(hex: "#D4A746")
    static let primaryGoldLight = Color(hex: "#E8C97C")
    static let primaryGoldDark = Color(hex: "#B8923A")

    // Secondary accent - Brown
    static let secondaryBrown = Color(hex: "#8B6F47")
    static let secondaryBrownLight = Color(hex: "#A68B66")
    static let secondaryBrownDark = Color(hex: "#6B5635")

    // Background colors
    static let backgroundLight = Color(hex: "#F9F7F4")  // Warm off-white
    static let backgroundDark = Color(hex: "#1F1A17")    // Dark brown-black

    // UI Colors
    static let cardLight = Color(hex: "#FFFFFF")
    static let cardDark = Color(hex: "#2C2521")

    static let correctGreen = Color(hex: "#5CB85C")
    static let incorrectRed = Color(hex: "#D9534F")

    // Helper initializer for hex colors
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
