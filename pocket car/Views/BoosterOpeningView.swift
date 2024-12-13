import SwiftUI


struct BoosterOpeningView: View {
    @ObservedObject var collectionManager: CollectionManager

    @State private var isOpening = true
    @State private var currentCardIndex = 0
    @State private var cardScale: CGFloat = 1.3
    @State private var cardOffset: CGFloat = 0
    @Environment(\.presentationMode) var presentationMode

    // Pool de cartes avec leurs probabilités
    let allCards: [BoosterCard] = [
        BoosterCard(name: "car1_common", rarity: .common),
        BoosterCard(name: "car2_rare", rarity: .rare),
        BoosterCard(name: "car3_legendary", rarity: .legendary),
        // Ajoutez les 150 cartes ici
    ]

    var body: some View {
        ZStack {
            Color.white.opacity(0.1)
                .ignoresSafeArea()

            VStack {
                if isOpening {
                    if currentCardIndex < 5 { // Exemple : 5 cartes par booster
                        let selectedCard = randomCard()

                        HolographicCard(cardImage: selectedCard.name)
                            .scaleEffect(cardScale)
                            .offset(y: cardOffset)
                            .onTapGesture {
                                collectionManager.addCard(selectedCard)

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
        .onChange(of: currentCardIndex) {
            cardScale = 1.3
        }
    }

    // Fonction pour tirer une carte aléatoire
    func randomCard() -> BoosterCard {
        let probabilities: [CardRarity: Double] = [
            .common: 0.7,
            .rare: 0.25,
            .legendary: 0.05
        ]

        let weightedCards = allCards.flatMap { card -> [BoosterCard] in
            let weight = probabilities[card.rarity] ?? 0
            let count = Int(weight * 100)
            return Array(repeating: card, count: count)
        }

        return weightedCards.randomElement() ?? allCards.first!
    }
}

