import Foundation

// Modèle de carte
struct BoosterCard {
    let name: String
    let rarity: rarity
    let id: UUID = UUID()

}

// Énumération pour les niveaux de rareté
enum rarity: String {
    case common
    case rare
    case epic
    case legendary

    // Taux de drop associé à chaque rareté
    var dropRate: Double {
        switch self {
        case .common: return 0.5 // 50%
        case .rare: return 0.3  // 30%
        case .epic: return 0.15 // 15%
        case .legendary: return 0.05 // 5%
        }
    }

    // Description stylisée pour l'affichage
    var description: String {
        switch self {
        case .common: return "Common"
        case .rare: return "Rare"
        case .epic: return "Epic"
        case .legendary: return "Legendary"
        }
    }

    // Couleur associée pour l'interface utilisateur (optionnel)
    var color: String {
        switch self {
        case .common: return "Gray"
        case .rare: return "Blue"
        case .epic: return "Purple"
        case .legendary: return "Gold"
        }
    }
}

