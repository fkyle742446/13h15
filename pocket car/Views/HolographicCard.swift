import SwiftUI

struct HolographicCard: View {
    let cardImage: String

    @State var translation: CGSize = .zero
    @GestureState private var press = false

    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                translation = value.translation
            }
            .onEnded { _ in
                withAnimation {
                    translation = .zero
                }
            }
    }

    var body: some View {
        ZStack {
            // Gradient pour l'effet holographique
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple, .pink, .yellow, .green]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: 250, height: 350)
            .mask(
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: 250, height: 350)
            )
            .overlay(
                Image(cardImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 350)
                    .cornerRadius(15)
            )
            .overlay(
                LinearGradient(
                    colors: [.clear, .white.opacity(0.2), .clear],
                    startPoint: .topLeading,
                    endPoint: UnitPoint(
                        x: abs(translation.height) / 100 + 1,
                        y: abs(translation.height) / 100 + 1


                    )
                )
                .frame(width: 250, height: 350)
                .clipShape(RoundedRectangle(cornerRadius: 15))

            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.clear, .yellow.opacity(1), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 10
                    )
                    .frame(width: 250, height: 350)
            )
            .rotation3DEffect(
                .degrees(15),
                axis: (x: -translation.height / 50, y: translation.width / 50, z: 0)
            )
            .gesture(drag)
        }
        .frame(width: 250, height: 350)
    }
}
