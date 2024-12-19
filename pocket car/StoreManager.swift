import StoreKit

// Add these properties to StoreManager
@Published private(set) var products: [Product] = []
@Published private(set) var purchaseInProgress = false

// Add this method to StoreManager
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

// Add this method to StoreManager
func purchase(_ product: Product) async throws {
    purchaseInProgress = true
    defer { purchaseInProgress = false }
    
    let result = try await product.purchase()
    
    switch result {
    case .success(let verification):
        // Handle successful purchase
        if case .verified(let transaction) = verification {
            // Add points based on the product
            if product.id == "com.yourapp.points.100" {
                purchasePoints(amount: 100)
            } else if product.id == "com.yourapp.points.500" {
                purchasePoints(amount: 500)
            } else if product.id == "com.yourapp.points.1000" {
                purchasePoints(amount: 1000)
            }
            await transaction.finish()
        }
    case .userCancelled:
        break
    case .pending:
        break
    @unknown default:
        break
    }
} 
