//
//  HomeView.swift
//  JLPT Vocabulary Champion
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Binding var currentView: String

    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }

    var body: some View {
        ZStack {
            // Background
            (appSettings.isDarkMode ? Color.backgroundDark : Color.backgroundLight)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 4) {
                    Text("JLPT VOCABULARY")
                        .font(.system(size: isRegularWidth ? 24 : 20, weight: .heavy))
                        .foregroundColor(appSettings.isDarkMode ? .white : Color.backgroundDark)
                        .tracking(1.5)

                    Text("CHAMPION")
                        .font(.system(size: isRegularWidth ? 18 : 15, weight: .bold))
                        .foregroundColor(Color.primaryGold)
                        .tracking(4)
                }
                .padding(.top, 60)

                Spacer()

                // Hero Section
                VStack(spacing: isRegularWidth ? -24 : -16) {
                    Text("日本")
                        .font(.system(size: isRegularWidth ? 120 : 72, weight: .black))
                        .foregroundColor(Color.primaryGold)
                    Text("優勝")
                        .font(.system(size: isRegularWidth ? 120 : 72, weight: .black))
                        .foregroundColor(Color.primaryGold)
                }

                Spacer()

                // Action Buttons
                VStack(spacing: 16) {
                    // Practice Button
                    Button(action: {
                        currentView = "practice"
                    }) {
                        HStack {
                            HStack(spacing: isRegularWidth ? 20 : 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.2))
                                        .frame(width: isRegularWidth ? 52 : 44, height: isRegularWidth ? 52 : 44)

                                    Image(systemName: "pencil.and.outline")
                                        .font(.system(size: isRegularWidth ? 32 : 28))
                                        .foregroundColor(Color.white)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Practice")
                                        .font(.system(size: isRegularWidth ? 22 : 18, weight: .bold))
                                        .foregroundColor(Color.white)

                                    Text("Test your knowledge")
                                        .font(.system(size: isRegularWidth ? 14 : 12))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: isRegularWidth ? 18 : 16))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.horizontal, isRegularWidth ? 28 : 24)
                        .padding(.vertical, isRegularWidth ? 20 : 16)
                        .background(Color.primaryGold)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, y: 2)
                    }

                    // Library Button
                    Button(action: {
                        currentView = "library"
                    }) {
                        HStack {
                            HStack(spacing: isRegularWidth ? 20 : 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.1))
                                        .frame(width: isRegularWidth ? 52 : 44, height: isRegularWidth ? 52 : 44)

                                    Image(systemName: "book.closed")
                                        .font(.system(size: isRegularWidth ? 32 : 28))
                                        .foregroundColor(Color.white)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Library")
                                        .font(.system(size: isRegularWidth ? 22 : 18, weight: .bold))
                                        .foregroundColor(Color.white)

                                    Text("Browse words")
                                        .font(.system(size: isRegularWidth ? 14 : 12))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: isRegularWidth ? 18 : 16))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.horizontal, isRegularWidth ? 28 : 24)
                        .padding(.vertical, isRegularWidth ? 20 : 16)
                        .background(Color.secondaryBrown)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, y: 2)
                    }

                    // Options Button
                    Button(action: {
                        currentView = "options"
                    }) {
                        HStack {
                            HStack(spacing: isRegularWidth ? 20 : 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.primaryGold.opacity(0.1))
                                        .frame(width: isRegularWidth ? 52 : 44, height: isRegularWidth ? 52 : 44)

                                    Image(systemName: "gearshape.fill")
                                        .font(.system(size: isRegularWidth ? 32 : 28))
                                        .foregroundColor(Color.primaryGold)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Options")
                                        .font(.system(size: isRegularWidth ? 22 : 18, weight: .bold))
                                        .foregroundColor(appSettings.isDarkMode ? .white : Color.backgroundDark)

                                    Text("Settings & Info")
                                        .font(.system(size: isRegularWidth ? 14 : 12, weight: .bold))
                                        .foregroundColor(Color.primaryGold)
                                }
                            }

                            Spacer()
                        }
                        .padding(.horizontal, isRegularWidth ? 28 : 24)
                        .padding(.vertical, isRegularWidth ? 20 : 16)
                        .background(
                            (appSettings.isDarkMode ? Color.secondaryBrownDark.opacity(0.3) : Color.backgroundLight)
                        )
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.secondaryBrown, lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: isRegularWidth ? 560 : .infinity)

                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    HomeView(currentView: .constant("home"))
        .environmentObject(AppSettings.shared)
}
