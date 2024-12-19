import SwiftUI

struct StoreView: View {
    @StateObject private var storeManager = StoreManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Available Points: \(storeManager.availablePoints)")
                    .font(.title2)
                    .padding()
                
                VStack(spacing: 15) {
                    pointPackageButton(points: 100, price: "$0.99")
                    pointPackageButton(points: 500, price: "$4.99")
                    pointPackageButton(points: 1000, price: "$9.99")
                }
                .padding()
            }
            .navigationTitle("Store")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
    
    private func pointPackageButton(points: Int, price: String) -> some View {
        Button(action: {
            storeManager.purchasePoints(amount: points)
        }) {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(points) Points")
                        .font(.headline)
                    Text(price)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "cart")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

// Preview provider for SwiftUI canvas
struct StoreView_Previews: PreviewProvider {
    static var previews: some View {
        StoreView()
    }
}
