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
    
    private func cardThemeColor(for rarity: CardRarity) -> Color {
        switch rarity {
        case .common:
            return Color(red: 0.75, green: 0.75, blue: 0.75) // Silver
        case .rare:
            return Color(red: 0.0, green: 0.48, blue: 0.97) // Blue
        case .epic:
            return Color(red: 0.5, green: 0.0, blue: 0.5) // Purple
        case .legendary:
            return Color(red: 1, green: 0.84, blue: 0) // Gold
            
        case .HolyT:
            return Color(red: 1, green: 0.84, blue: 0) // Golden color
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
            // Card background with rarity color and texture
            RoundedRectangle(cornerRadius: 15)
                .fill(cardThemeColor(for: rarity))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        .blur(radius: 1)
                )
                .frame(width: 250, height: 350)
            
            // Main card content
            VStack(spacing: 0) {
                // Title bar with name and rarity
                HStack {
                    Text(cardImage)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 1, x: 1, y: 1)
                        .lineLimit(1)
                        .padding(.leading, 15)
                    
                    Spacer()
                    
                    Text("\(rarity.rawValue.uppercased())")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 1, x: 1, y: 1)
                        .padding(.trailing, 15)
                }
                .padding(.vertical, 12)
                .background(Color.black.opacity(0.2))
                
                // Image section with decorative frame
                ZStack {
                    // Outer frame
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.2), radius: 2)
                    
                    // Inner frame
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(cardThemeColor(for: rarity), lineWidth: 2)
                        .padding(4)
                    
                    // Car image
                    Image(cardImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 220, height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .padding(8)
                }
                .frame(width: 240, height: 260)
                .padding(.vertical, 10)
                
                // Stats and info section
                VStack(spacing: 12) {
                    // Card number with decorative elements
                    HStack {
                        Text("POCKET CAR ILLUSTRATION ©")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 1, x: 1, y: 1)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 4)
                        
                        Spacer()
                        
                        Text("№ \(cardNumber)/108")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.3))
                            )
                    }
                    .padding(.horizontal, 15)
                }
            }
            
            // Enhanced holographic effect
            LinearGradient(
                colors: [
                    .clear,
                    .white.opacity(0.4),
                    .white.opacity(0.2),
                    .clear
                ],
                startPoint: UnitPoint(
                    x: 0.2 + translation.width / 500,
                    y: 0.2 + translation.height / 500
                ),
                endPoint: UnitPoint(
                    x: 0.8 + translation.width / 250,
                    y: 0.8 + translation.height / 250
                )
            )
            .frame(width: 250, height: 350)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .blendMode(.overlay)
            
            // Premium border effect
            RoundedRectangle(cornerRadius: 15)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            cardThemeColor(for: rarity).opacity(0.8),
                            .white.opacity(0.5),
                            cardThemeColor(for: rarity).opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 4
                )
                .frame(width: 250, height: 350)
        }
        .frame(width: 250, height: 350)
        .rotation3DEffect(
            .degrees(Double(translation.height / 10)),
            axis: (x: -1, y: translation.width / 100, z: 0)
        )
        .gesture(drag)
    }
}

