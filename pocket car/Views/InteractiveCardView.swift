import SwiftUI

struct InteractiveCardView: View {
    let cardImage: String
    var body: some View {
        Image(cardImage)
            .resizable()
            .scaledToFit()
            .frame(width: 300, height: 420)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
    }
}
