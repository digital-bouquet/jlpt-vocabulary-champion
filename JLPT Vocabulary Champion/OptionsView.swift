//
//  OptionsView.swift
//  JLPT Vocabulary Champion
//

import SwiftUI

struct OptionsView: View {
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @StateObject private var purchaseManager = PurchaseManager.shared
    @Binding var currentView: String

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

                            Text("Options")
                                .font(.system(size: isRegularWidth ? 22 : 18, weight: .bold))
                                .foregroundColor(appSettings.isDarkMode ? .white : Color.backgroundDark)

                            Spacer()

                            Color.clear.frame(width: isRegularWidth ? 90 : 70)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 20)

                    VStack(alignment: .leading, spacing: isRegularWidth ? 24 : 20) {
                        // Purchase Complete Edition
                        VStack(alignment: .leading, spacing: isRegularWidth ? 16 : 14) {
                            HStack(spacing: 8) {
                                Capsule()
                                    .fill(Color.primaryGold)
                                    .frame(width: 4, height: isRegularWidth ? 22 : 18)

                                Text("UNLOCK ALL VOCABULARY")
                                    .font(.system(size: isRegularWidth ? 16 : 14, weight: .bold))
                                    .tracking(2)
                                    .foregroundColor(appSettings.isDarkMode ? .white : Color.backgroundDark)
                            }

                            VStack(spacing: isRegularWidth ? 16 : 14) {
                                Text("Support the developer with a one-time purchase and unlock all vocabulary words.")
                                    .font(.system(size: isRegularWidth ? 15 : 13))
                                    .foregroundColor(appSettings.isDarkMode ? Color.gray : Color.gray.opacity(0.8))

                                if purchaseManager.hasActivePremium {
                                    Text("✓ Full Edition Unlocked")
                                        .font(.system(size: isRegularWidth ? 16 : 14, weight: .medium))
                                        .foregroundColor(.green)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, isRegularWidth ? 16 : 14)
                                } else if purchaseManager.productLoaded {
                                    Button(action: {
                                        Task {
                                            do {
                                                try await purchaseManager.purchase()
                                            } catch {
                                                print("Purchase failed: \(error)")
                                            }
                                        }
                                    }) {
                                        Text(purchaseManager.isLoading ? "Processing..." : "Purchase All Words - \(purchaseManager.displayPrice)")
                                            .font(.system(size: isRegularWidth ? 17 : 15, weight: .bold))
                                            .foregroundColor(Color.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, isRegularWidth ? 16 : 14)
                                            .background(purchaseManager.isLoading ? Color.gray : Color.primaryGold)
                                            .cornerRadius(10)
                                    }
                                    .disabled(purchaseManager.isLoading)

                                    Button(action: {
                                        Task {
                                            await purchaseManager.restorePurchases()
                                        }
                                    }) {
                                        Text("Restore Purchases")
                                            .font(.system(size: isRegularWidth ? 16 : 14))
                                            .foregroundColor(Color.primaryGold)
                                    }
                                    .disabled(purchaseManager.isLoading)
                                } else {
                                    Text("Loading purchase info...")
                                        .font(.system(size: isRegularWidth ? 15 : 13))
                                        .foregroundColor(Color.gray)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, isRegularWidth ? 16 : 14)

                                    Button(action: {
                                        Task {
                                            await purchaseManager.restorePurchases()
                                        }
                                    }) {
                                        Text("Restore Purchases")
                                            .font(.system(size: isRegularWidth ? 16 : 14))
                                            .foregroundColor(Color.primaryGold)
                                    }
                                }
                            }
                            .padding(isRegularWidth ? 20 : 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(appSettings.isDarkMode ? Color.secondaryBrownDark.opacity(0.2) : Color.gray.opacity(0.1))
                            )
                        }

                        // Appearance
                        VStack(alignment: .leading, spacing: isRegularWidth ? 16 : 14) {
                            HStack(spacing: 8) {
                                Capsule()
                                    .fill(Color.primaryGold)
                                    .frame(width: 4, height: isRegularWidth ? 22 : 18)

                                Text("APPEARANCE")
                                    .font(.system(size: isRegularWidth ? 16 : 14, weight: .bold))
                                    .tracking(2)
                                    .foregroundColor(appSettings.isDarkMode ? .white : Color.backgroundDark)
                            }

                            VStack(spacing: 0) {
                                HStack {
                                    Text("Dark Mode")
                                        .font(.system(size: isRegularWidth ? 17 : 15))
                                        .foregroundColor(appSettings.isDarkMode ? Color.gray.opacity(0.9) : Color.backgroundDark)

                                    Spacer()

                                    Toggle("", isOn: $appSettings.isDarkMode)
                                        .labelsHidden()
                                        .tint(Color.primaryGold)
                                }
                                .padding(isRegularWidth ? 16 : 14)

                                Divider()
                                    .background(Color.secondaryBrown.opacity(0.3))

                                HStack {
                                    Text("Use Hiragana & Katakana")
                                        .font(.system(size: isRegularWidth ? 17 : 15))
                                        .foregroundColor(appSettings.isDarkMode ? Color.gray.opacity(0.9) : Color.backgroundDark)

                                    Spacer()

                                    Toggle("", isOn: $appSettings.useHiragana)
                                        .labelsHidden()
                                        .tint(Color.primaryGold)
                                }
                                .padding(isRegularWidth ? 16 : 14)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(appSettings.isDarkMode ? Color.secondaryBrownDark.opacity(0.2) : Color.gray.opacity(0.1))
                            )
                        }

                        // Data Management
                        VStack(alignment: .leading, spacing: isRegularWidth ? 16 : 14) {
                            HStack(spacing: 8) {
                                Capsule()
                                    .fill(Color.primaryGold)
                                    .frame(width: 4, height: isRegularWidth ? 22 : 18)

                                Text("DATA")
                                    .font(.system(size: isRegularWidth ? 16 : 14, weight: .bold))
                                    .tracking(2)
                                    .foregroundColor(appSettings.isDarkMode ? .white : Color.backgroundDark)
                            }

                            VStack(spacing: 0) {
                                HStack {
                                    Text("Total Words Practiced")
                                        .font(.system(size: isRegularWidth ? 17 : 15))
                                        .foregroundColor(appSettings.isDarkMode ? Color.gray.opacity(0.9) : Color.backgroundDark)

                                    Spacer()

                                    Text("0")
                                        .font(.system(size: isRegularWidth ? 17 : 15, weight: .medium))
                                        .foregroundColor(appSettings.isDarkMode ? .white : Color.backgroundDark)
                                }
                                .padding(isRegularWidth ? 16 : 14)

                                Divider()
                                    .background(Color.secondaryBrown.opacity(0.3))

                                HStack {
                                    Text("Total Attempts")
                                        .font(.system(size: isRegularWidth ? 17 : 15))
                                        .foregroundColor(appSettings.isDarkMode ? Color.gray.opacity(0.9) : Color.backgroundDark)

                                    Spacer()

                                    Text("0")
                                        .font(.system(size: isRegularWidth ? 17 : 15, weight: .medium))
                                        .foregroundColor(appSettings.isDarkMode ? .white : Color.backgroundDark)
                                }
                                .padding(isRegularWidth ? 16 : 14)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(appSettings.isDarkMode ? Color.secondaryBrownDark.opacity(0.2) : Color.gray.opacity(0.1))
                            )

                            Button(action: {}) {
                                Text("Clear All Data")
                                    .font(.system(size: isRegularWidth ? 17 : 15, weight: .bold))
                                    .foregroundColor(Color.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, isRegularWidth ? 16 : 14)
                                    .background(Color.secondaryBrownDark.opacity(0.8))
                                    .cornerRadius(10)
                            }
                        }

                        // Legal
                        VStack(alignment: .leading, spacing: isRegularWidth ? 16 : 14) {
                            HStack(spacing: 8) {
                                Capsule()
                                    .fill(Color.primaryGold)
                                    .frame(width: 4, height: isRegularWidth ? 22 : 18)

                                Text("LEGAL")
                                    .font(.system(size: isRegularWidth ? 16 : 14, weight: .bold))
                                    .tracking(2)
                                    .foregroundColor(appSettings.isDarkMode ? .white : Color.backgroundDark)
                            }

                            VStack(spacing: 0) {
                                Button(action: {
                                    if let url = URL(string: "https://digitalbouquet.ink/privacy.html") {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    HStack {
                                        Text("Privacy Policy")
                                            .font(.system(size: isRegularWidth ? 17 : 15))
                                            .foregroundColor(appSettings.isDarkMode ? Color.gray.opacity(0.9) : Color.backgroundDark)

                                        Spacer()

                                        Image(systemName: "arrow.up.right")
                                            .font(.system(size: isRegularWidth ? 16 : 14))
                                            .foregroundColor(Color.gray)
                                    }
                                    .padding(isRegularWidth ? 16 : 14)
                                }

                                Divider()
                                    .background(Color.secondaryBrown.opacity(0.3))

                                Button(action: {
                                    if let url = URL(string: "https://digitalbouquet.ink/support.html") {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    HStack {
                                        Text("Support")
                                            .font(.system(size: isRegularWidth ? 17 : 15))
                                            .foregroundColor(appSettings.isDarkMode ? Color.gray.opacity(0.9) : Color.backgroundDark)

                                        Spacer()

                                        Image(systemName: "arrow.up.right")
                                            .font(.system(size: isRegularWidth ? 16 : 14))
                                            .foregroundColor(Color.gray)
                                    }
                                    .padding(isRegularWidth ? 16 : 14)
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(appSettings.isDarkMode ? Color.secondaryBrownDark.opacity(0.2) : Color.gray.opacity(0.1))
                            )
                        }

                        // Credits
                        VStack(spacing: 8) {
                            Text("Sound effects by Nathan Gibson")
                                .font(.system(size: 11))
                                .foregroundColor(appSettings.isDarkMode ? Color.gray.opacity(0.6) : Color.gray.opacity(0.8))
                                .frame(maxWidth: .infinity, alignment: .center)

                            Text("Vocabulary data sourced from Wiktionary")
                                .font(.system(size: 11))
                                .foregroundColor(appSettings.isDarkMode ? Color.gray.opacity(0.6) : Color.gray.opacity(0.8))
                                .frame(maxWidth: .infinity, alignment: .center)

                            Button(action: {
                                if let url = URL(string: "https://en.wiktionary.org/wiki/Wiktionary:Copyright") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Text("View Wiktionary License →")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(Color.primaryGold)
                                    .underline()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 20)

                        #if DEBUG
                        // Debug testing toggle (only visible in debug builds)
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(spacing: 8) {
                                Capsule()
                                    .fill(Color.orange)
                                    .frame(width: 4, height: 18)

                                Text("DEBUG TESTING")
                                    .font(.system(size: 14, weight: .bold))
                                    .tracking(2)
                                    .foregroundColor(.orange)
                            }

                            VStack(spacing: 0) {
                                HStack {
                                    Text("Force Premium Unlock")
                                        .font(.system(size: 15))
                                        .foregroundColor(appSettings.isDarkMode ? Color.gray.opacity(0.9) : Color.backgroundDark)

                                    Spacer()

                                    Toggle("", isOn: $appSettings.hasActivePremium)
                                        .labelsHidden()
                                        .tint(.orange)
                                        .onChange(of: appSettings.hasActivePremium) { _, newValue in
                                            if newValue {
                                                PaywallManager.shared.unlockPremium()
                                            } else {
                                                PaywallManager.shared.lockPremium()
                                            }
                                        }
                                }
                                .padding(14)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.orange.opacity(0.1))
                            )

                            Text("⚠️ This toggle only works in DEBUG builds. Production builds require actual purchase.")
                                .font(.system(size: 11))
                                .foregroundColor(.orange.opacity(0.7))
                        }
                        .padding(.top, 20)
                        #endif
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                    .frame(maxWidth: isRegularWidth ? 650 : .infinity)
                    .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

#Preview {
    OptionsView(currentView: .constant("options"))
        .environmentObject(AppSettings.shared)
}
