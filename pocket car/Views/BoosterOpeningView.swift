import SwiftUI

struct BoosterOpeningView: View {
    @ObservedObject var collectionManager: CollectionManager

    @State private var isOpening = true
    @State private var currentCardIndex = 0
    @State private var cardScale: CGFloat = 1.3
    @State private var cardOffset: CGFloat = 0
    @Environment(\.presentationMode) var presentationMode

    let cards: [BoosterCard] = [
        BoosterCard(name: "car1_common", rarity: .common),
        BoosterCard(name: "car2_rare", rarity: .rare),
        BoosterCard(name: "car3_common", rarity: .common),
        BoosterCard(name: "car4_legendary", rarity: .legendary),
        BoosterCard(name: "car5_common", rarity: .common)
    ]

    var body: some View {
        ZStack {
            Color.white.opacity(0.1)
                .ignoresSafeArea()

            VStack {
                if isOpening {
                    if currentCardIndex < cards.count {
                        HolographicCard(cardImage: cards[currentCardIndex].name)
                            .scaleEffect(cardScale)
                            .offset(y: cardOffset)
                            .onTapGesture {
                                // Ajout de la carte à la collection
                                collectionManager.addCard(cards[currentCardIndex]) // Assurez-vous que cette méthode existe

                                // Passe à la carte suivante
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    cardOffset = -UIScreen.main.bounds.height
                                }

                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    cardOffset = 0
                                    currentCardIndex += 1
                                }
                            }
                            .onAppear {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    cardScale = 1.3
                                }
                            }
                    } else {
                        Text("Ouverture terminée")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                    }
                }
            }
        }
        .onChange(of: currentCardIndex) { _ in
            cardScale = 1.3
        }
    }
}

