import Foundation
import StoreKit

class StoreManager: ObservableObject {
    static let shared = StoreManager()
    
    @Published private(set) var availablePoints: Int = UserDefaults.standard.integer(forKey: "userPoints")
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchaseInProgress = false
    
    private init() {}
    
    func purchasePoints(amount: Int) {
        availablePoints += amount
        UserDefaults.standard.set(availablePoints, forKey: "userPoints")
    }
    
    func usePoints(amount: Int) -> Bool {
        guard availablePoints >= amount else { return false }
        availablePoints -= amount
        UserDefaults.standard.set(availablePoints, forKey: "userPoints")
        return true
    }
    
    func loadProducts() async {
        do {
            let productIdentifiers = ["com.yourapp.points.100",
                                    "com.yourapp.points.500",
                                    "com.yourapp.points.1000"]
            let products = try await Product.products(for: productIdentifiers)
            DispatchQueue.main.async {
                self.products = products
            }
        } catch {
            print("Failed to load products:", error)
        }
    }
} 
