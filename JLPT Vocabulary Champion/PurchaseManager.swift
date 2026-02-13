//
//  PurchaseManager.swift
//  JLPT Vocabulary Champion
//

import StoreKit
import SwiftUI

@MainActor
class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    @Published var hasActivePremium: Bool = false
    @Published var isLoading: Bool = false
    @Published var productLoaded: Bool = false
    @Published var displayPrice: String = ""

    private let productID = "vocabularyChampionCompleteEdition"
    private var product: Product?
    private var updateListenerTask: Task<Void, Error>?

    init() {
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await updatePurchasedStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // Load product from App Store
    func loadProducts() async {
        do {
            let products = try await Product.products(for: [productID])
            product = products.first
            productLoaded = product != nil
            displayPrice = product?.displayPrice ?? ""
        } catch {
            print("Failed to load products: \(error)")
            productLoaded = false
        }
    }

    // Purchase the product
    func purchase() async throws {
        guard let product = product else { return }

        isLoading = true
        defer { isLoading = false }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await updatePurchasedStatus()

        case .userCancelled:
            break

        case .pending:
            break

        @unknown default:
            break
        }
    }

    // Restore purchases
    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        try? await AppStore.sync()
        await updatePurchasedStatus()
    }

    // Check current entitlements
    private func updatePurchasedStatus() async {
        var hasPurchased = false

        for await result in Transaction.currentEntitlements {
            let transaction = try? checkVerified(result)
            if transaction?.productID == productID {
                hasPurchased = true
            }
        }

        hasActivePremium = hasPurchased

        // Sync with AppSettings and PaywallManager
        await MainActor.run {
            AppSettings.shared.hasActivePremium = hasPurchased
            if hasPurchased {
                PaywallManager.shared.unlockPremium()
            }
        }
    }

    // Listen for transaction updates
    private nonisolated func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await verificationResult in Transaction.updates {
                guard case .verified(let transaction) = verificationResult else {
                    print("Transaction verification failed")
                    continue
                }

                await transaction.finish()
                await PurchaseManager.shared.updatePurchasedStatus()
            }
        }
    }

    // Verify transaction is valid
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    enum StoreError: Error {
        case failedVerification
    }
}
