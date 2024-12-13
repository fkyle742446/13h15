import SwiftUI

class CollectionManager: ObservableObject {
    @Published var cards: [BoosterCard] = [
        BoosterCard(name: "Card1", rarity: .common),
        BoosterCard(name: "Card2", rarity: .rare),
        BoosterCard(name: "Card3", rarity: .legendary),
        BoosterCard(name: "Card4", rarity: .common),
        BoosterCard(name: "Card5", rarity: .rare),
        BoosterCard(name: "Card6", rarity: .legendary)
    ]

    // Ajoute une carte à la collection
    func addCard(_ card: BoosterCard) {
        DispatchQueue.main.async {
            self.cards.append(card)
        }
    }
}
