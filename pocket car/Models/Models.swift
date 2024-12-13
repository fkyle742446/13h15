import Foundation

struct BoosterCard: Identifiable {
    let id = UUID()
    let name: String
    let rarity: CardRarity
}

enum CardRarity {
    case common, rare, legendary
}

