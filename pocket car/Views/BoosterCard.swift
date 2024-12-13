
import Foundation

enum CardRarity {
    case common
    case rare
    case legendary
}

struct BoosterCard: Identifiable {
    let id = UUID()
    let name: String
    let rarity: CardRarity
}
