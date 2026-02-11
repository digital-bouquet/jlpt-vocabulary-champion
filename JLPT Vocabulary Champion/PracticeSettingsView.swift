//
//  PracticeSettingsView.swift
//  JLPT Vocabulary Champion
//

import SwiftUI

struct PracticeSettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Binding var currentView: String
    @ObservedObject var settings: PracticeSettings

    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }

    var body: some View {
        ZStack {
            (appSettings.isDarkMode ? Color.backgroundDark : Color.backgroundLight)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        // Header
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

                            Spacer()

                            Text("Practice Settings")
                                .font(.system(size: isRegularWidth ? 22 : 18, weight: .bold))
                                .foregroundColor(appSettings.isDarkMode ? .white : Color.backgroundDark)

                            Spacer()

                            Color.clear.frame(width: isRegularWidth ? 90 : 70)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 20)

                VStack(alignment: .leading, spacing: isRegularWidth ? 20 : 16) {
                    // JLPT Levels
                    VStack(alignment: .leading, spacing: isRegularWidth ? 14 : 12) {
                        HStack(spacing: 8) {
                            Capsule()
                                .fill(Color.primaryGold)
                                .frame(width: 4, height: isRegularWidth ? 20 : 16)

                            Text("JLPT LEVELS")
                                .font(.system(size: isRegularWidth ? 16 : 14, weight: .bold))
                                .tracking(2)
                                .foregroundColor(appSettings.isDarkMode ? .white : Color.backgroundDark)
                        }

                        HStack(spacing: 10) {
                            ForEach(JLPTLevel.allCases.reversed()) { level in
                                Button(action: {
                                    if settings.selectedLevels.contains(level) {
                                        settings.selectedLevels.remove(level)
                                    } else {
                                        settings.selectedLevels.insert(level)
                                    }
                                }) {
                                    Text(level.displayName)
                                        .font(.system(size: isRegularWidth ? 15 : 13, weight: .bold))
                                        .foregroundColor(settings.selectedLevels.contains(level) ? .white : Color.gray)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: isRegularWidth ? 48 : 40)
                                        .background(
                                            settings.selectedLevels.contains(level) ?
                                            Color.primaryGold :
                                            Color.secondaryBrownDark.opacity(0.4)
                                        )
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }

                    // Study Aspects
                    VStack(alignment: .leading, spacing: isRegularWidth ? 14 : 12) {
                        HStack(spacing: 8) {
                            Capsule()
                                .fill(Color.primaryGold)
                                .frame(width: 4, height: isRegularWidth ? 20 : 16)

                            Text("QUIZ TYPES")
                                .font(.system(size: isRegularWidth ? 16 : 14, weight: .bold))
                                .tracking(2)
                                .foregroundColor(appSettings.isDarkMode ? .white : Color.backgroundDark)
                        }

                        HStack(spacing: 10) {
                            ForEach(QuizType.allCases, id: \.self) { quizType in
                                Button(action: {
                                    if settings.selectedQuizTypes.contains(quizType) {
                                        settings.selectedQuizTypes.remove(quizType)
                                    } else {
                                        settings.selectedQuizTypes.insert(quizType)
                                    }
                                }) {
                                    Text(quizType.rawValue)
                                        .font(.system(size: isRegularWidth ? 15 : 13, weight: .bold))
                                        .foregroundColor(settings.selectedQuizTypes.contains(quizType) ? .white : Color.gray)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: isRegularWidth ? 48 : 40)
                                        .background(
                                            settings.selectedQuizTypes.contains(quizType) ?
                                            Color.primaryGold :
                                            Color.secondaryBrownDark.opacity(0.4)
                                        )
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }

                    // Priority Strategy
                    VStack(alignment: .leading, spacing: isRegularWidth ? 14 : 12) {
                        HStack(spacing: 8) {
                            Capsule()
                                .fill(Color.primaryGold)
                                .frame(width: 4, height: isRegularWidth ? 20 : 16)

                            Text("PRACTICE MODE")
                                .font(.system(size: 14, weight: .bold))
                                .tracking(2)
                                .foregroundColor(appSettings.isDarkMode ? .white : Color.backgroundDark)
                        }

                        VStack(spacing: 10) {
                            ForEach(PracticeMode.allCases, id: \.self) { mode in
                                Button(action: {
                                    settings.practiceMode = mode
                                }) {
                                    HStack(spacing: 12) {
                                        Circle()
                                            .stroke(
                                                settings.practiceMode == mode ? Color.primaryGold : Color.secondaryBrown,
                                                lineWidth: 2
                                            )
                                            .frame(width: 18, height: 18)
                                            .overlay(
                                                Circle()
                                                    .fill(settings.practiceMode == mode ? Color.primaryGold : Color.clear)
                                                    .frame(width: 8, height: 8)
                                            )

                                        Text(mode.rawValue)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(appSettings.isDarkMode ? .white : Color.backgroundDark)

                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(
                                                settings.practiceMode == mode ?
                                                Color.primaryGold.opacity(0.1) :
                                                Color.secondaryBrownDark.opacity(0.2)
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(
                                                        settings.practiceMode == mode ?
                                                        Color.primaryGold :
                                                        Color.secondaryBrown.opacity(0.3),
                                                        lineWidth: 1
                                                    )
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 120)
                .frame(maxWidth: isRegularWidth ? 650 : .infinity)
                .frame(maxWidth: .infinity)
                    }
                }

                Spacer()

                // Begin Button
                Button(action: {
                    currentView = "session"
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                            .font(.system(size: 18))

                        Text("BEGIN PRACTICE")
                            .font(.system(size: 18, weight: .heavy))
                            .tracking(1)
                    }
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.primaryGold, Color.secondaryBrown]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                    .shadow(color: Color.primaryGold.opacity(0.3), radius: 12)
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: isRegularWidth ? 650 : .infinity)
                .padding(.bottom, 30)
            }
        }
    }
}

#Preview {
    PracticeSettingsView(currentView: .constant("practice"), settings: PracticeSettings())
        .environmentObject(AppSettings.shared)
}
