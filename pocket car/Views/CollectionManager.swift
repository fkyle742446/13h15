import SwiftUI

class CollectionManager: ObservableObject {
    // Un tableau contenant chaque carte et sa quantité
    @Published var cards: [(card: BoosterCard, count: Int)] = []

    // Ajoute une carte à la collection
    func addCard(_ card: BoosterCard) {
        DispatchQueue.main.async {
            if let index = self.cards.firstIndex(where: { $0.card.name == card.name && $0.card.rarity == card.rarity }) {
                // Si la carte existe déjà, incrémentez la quantité
                self.cards[index].count += 1
            } else {
                // Sinon, ajoutez une nouvelle entrée
                self.cards.append((card: card, count: 1))
            }
        }
    }
}
