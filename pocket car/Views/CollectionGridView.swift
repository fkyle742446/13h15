import SwiftUI

struct CollectionGridView: View {
    let cards: [(card: BoosterCard, count: Int)]
    @Binding var selectedCard: BoosterCard?

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(sortedCards, id: \.card.id) { entry in
                    CardView(card: entry.card, count: entry.count)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                selectedCard = entry.card
                            }
                        }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var sortedCards: [(card: BoosterCard, count: Int)] {
        cards.sorted { lhs, rhs in
            lhs.card.rarity.sortOrder > rhs.card.rarity.sortOrder
        }
    }
}


