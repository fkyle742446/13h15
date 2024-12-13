import SwiftUI

struct HolographicCardView: View {
    let cardImage: String

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.red, Color.blue, Color.green]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .mask(
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: 250, height: 350)
            )
            .overlay(
                Image(cardImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 350)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            )
        }
        .shadow(radius: 10)
    }
}

#Preview {
    HolographicCardView(cardImage: "car1_common")
}

