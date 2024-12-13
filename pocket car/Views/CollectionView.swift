import SwiftUI

struct CollectionView: View {
    @ObservedObject var collectionManager: CollectionManager
    @State private var selectedCard: BoosterCard? = nil

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.5)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    // Titre et compteur de cartes
                    HStack {
                        Text("Votre Collection")
                            .font(.system(size: 28, weight: .bold, design: .default))
                            .foregroundColor(.white)
                            .padding(.top, 20)

                        Spacer()

                        // Affiche le compteur de cartes collectées
                        Text("\(collectionManager.cards.count)/150")
                            .font(.system(size: 16, weight: .medium, design: .default))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.top, 20)
                            .padding(.trailing, 16)
                    }

                    if collectionManager.cards.isEmpty {
                        EmptyCollectionView()
                    } else {
                        CollectionGridView(cards: collectionManager.cards, selectedCard: $selectedCard)
                    }
                }

                if let selectedCard = selectedCard {
                    ZoomedCardView(selectedCard: $selectedCard)
                }
            }
        }
    }
}

// Composant pour afficher une collection vide
struct EmptyCollectionView: View {
    var body: some View {
        Spacer()
        Text("Vous n'avez pas encore de cartes dans votre collection.")
            .font(.system(size: 18, design: .rounded))
            .foregroundColor(.white.opacity(0.7))
            .multilineTextAlignment(.center)
            .padding()
        Spacer()
    }
}

// Composant pour afficher la grille des cartes
struct CollectionGridView: View {
    let cards: [(card: BoosterCard, count: Int)]
    @Binding var selectedCard: BoosterCard?

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(cards, id: \.card.id) { entry in
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
}

// Composant pour afficher une carte individuelle
struct CardView: View {
    let card: BoosterCard
    let count: Int

    var body: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                Image(card.name)
                    .resizable()
                    .aspectRatio(3 / 4, contentMode: .fit) // Maintient les proportions
                    .frame(maxWidth: 100, maxHeight: 140) // Taille du conteneur
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 4)

                // Badge indiquant la quantité
                if count > 1 {
                    Text("\(count)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Circle().fill(Color.red))
                        .offset(x: -5, y: 5)
                }
            }

            Text(card.name)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(card.rarity == .legendary ? Color.yellow.opacity(0.2) :
                      card.rarity == .rare ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
        )
        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
    }
}

// Composant pour afficher une carte en mode zoom
struct ZoomedCardView: View {
    @Binding var selectedCard: BoosterCard?

    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring()) {
                        selectedCard = nil
                    }
                }

            VStack(spacing: 20) {
                HolographicCard(cardImage: selectedCard?.name ?? "")
                    .scaledToFit()
                    .frame(width: 300, height: 420)
                    .cornerRadius(16)
                    .shadow(color: .yellow.opacity(0.6), radius: 20, x: 0, y: 10)

                Text(selectedCard?.name ?? "")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .transition(.opacity)
    }
}

