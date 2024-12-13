import SwiftUI

struct WKWebViewExample: View {
    var body: some View {
        VStack {
            Text("Exemple de vue web")
                .font(.headline)
                .padding()

            // Appel corrigé de HolographicCardView
            HolographicCardView(cardImage: "car1_common")
                .frame(width: 250, height: 350)
        }
    }
}

#Preview {
    WKWebViewExample()
}

