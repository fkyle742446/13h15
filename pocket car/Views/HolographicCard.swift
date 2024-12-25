import SwiftUI

struct HolographicCard: View {
    let cardImage: String
    let rarity: CardRarity
    let cardNumber: Int
    
    init(cardImage: String, rarity: CardRarity, cardNumber: Int = 0) {
        self.cardImage = cardImage
        self.rarity = rarity
        self.cardNumber = cardNumber
    }
    
    @State var translation: CGSize = .zero
    @GestureState private var press = false
    
    private func haloColor(for rarity: CardRarity) -> Color {
        switch rarity {
        case .common:
            return Color.white
        case .rare:
            return Color.blue
        case .epic:
            return Color.purple
        case .legendary:
            return Color(red: 1, green: 0.84, blue: 0)
        }
    }

    private func starsForRarity(_ rarity: CardRarity) -> Int {
        switch rarity {
        case .common:
            return 0
        case .rare:
            return 1
        case .epic:
            return 2
        case .legendary:
            return 3
        }
    }

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
            // Halo effect that follows the card movement
            RoundedRectangle(cornerRadius: 15)
                .fill(haloColor(for: rarity))
                .blur(radius: 20)
                .opacity(0.7)
                .frame(width: 250, height: 350)
            
            // Holographic base gradient with dynamic movement
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple, .pink, .yellow, .green]),
                startPoint: UnitPoint(
                    x: 0.5 + translation.width / 500,
                    y: 0.5 + translation.height / 500
                ),
                endPoint: UnitPoint(
                    x: 1.0 + translation.width / 250,
                    y: 1.0 + translation.height / 250
                )
            )
            .frame(width: 250, height: 350)
            .mask(
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: 250, height: 350)
            )
            
            // Card image
            Image(cardImage)
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 350)
                .cornerRadius(15)
            
            // Dynamic holographic shine effect
            LinearGradient(
                colors: [.clear, .white.opacity(0.4), .clear],
                startPoint: UnitPoint(
                    x: 0.5 + translation.width / 500,
                    y: 0.5 + translation.height / 500
                ),
                endPoint: UnitPoint(
                    x: 1.0 + translation.width / 250,
                    y: 1.0 + translation.height / 250
                )
            )
            .frame(width: 250, height: 350)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            
           // Card border effect
           RoundedRectangle(cornerRadius: 15)
               .strokeBorder(
                   LinearGradient(
                       colors: [
                           .yellow.opacity(0.8),
                           .orange.opacity(0.8),
                           .yellow.opacity(0.8)
                       ],
                       startPoint: UnitPoint(
                           x: translation.width / 250,
                           y: translation.height / 250
                       ),
                       endPoint: UnitPoint(
                           x: 1 + translation.width / 250,
                           y: 1 + translation.height / 250
                       )
                   ),
                   lineWidth: 8
               )
               .frame(width: 250, height: 350)
               .animation(.easeInOut(duration: 0.3), value: translation)
           
           // Info box
           VStack(alignment: .leading, spacing: 4) {
               Text("\(cardNumber)/67")
                   .font(.system(size: 10, weight: .regular))
                   .foregroundColor(.black)
               
               /*  Text(rarity.rawValue.capitalized)
                                 .font(.system(size: 8, weight: .medium))
                                 .foregroundColor(.gray) */
           }
           .padding(6)
           .background(
               RoundedRectangle(cornerRadius: 8)
                .fill(Color.yellow.opacity(0.9))
                   .shadow(color: .black.opacity(0.2), radius: 1)
           )
           .offset(x: 85, y: 147)
           
           // Rarity stars
           if starsForRarity(rarity) > 0 {
               HStack(spacing: 2) {
                   ForEach(0..<starsForRarity(rarity), id: \.self) { _ in
                       Image(systemName: "star.fill")
                           .foregroundColor(.yellow)
                           .shadow(color: .black.opacity(0.3), radius: 1)
                   }
               }
               .font(.system(size: 10))
               .offset(x: -90, y: 147)
           }
        }
        .frame(width: 250, height: 350)
        .rotation3DEffect(
            .degrees(Double(translation.height / 10)),
            axis: (x: -1, y: translation.width / 100, z: 0)
        )
        .gesture(drag)
    }
}

