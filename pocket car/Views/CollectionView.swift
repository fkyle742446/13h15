import SwiftUI

struct CollectionView: View {
    @ObservedObject var collectionManager: CollectionManager
    @State private var selectedCard: BoosterCard? = nil

    // Nombre de cartes uniques possédées
    private var ownedCardCount: Int {
        collectionManager.cards.count
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.5)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    // Titre et compteur
                    HStack {
                        Text("Votre Collection")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.top, 20)

                        Spacer()

                        // Compteur affichant cartes possédées / cartes totales
                        Text("\(ownedCardCount)/150")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.trailing, 16)
                            .padding(.top, 20)
                    }

                    if collectionManager.cards.isEmpty {
                        Spacer()
                        Text("Vous n'avez pas encore de cartes dans votre collection.")
                            .font(.system(size: 18, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                ForEach(collectionManager.cards) { card in
                                    VStack {
                                        Image(card.name)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 140)
                                            .cornerRadius(12)
                                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 4)
                                            .onTapGesture {
                                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                                    selectedCard = card
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
                            .padding(.horizontal, 16)
                        }
                    }
                }

                if let selectedCard = selectedCard {
                    ZStack {
                        Color.black.opacity(0.9).ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring()) {
                                self.selectedCard = nil
                            }
                        }

                        VStack(spacing: 20) {
                            HolographicCard(cardImage: selectedCard.name)
                                .frame(width: 300, height: 420)
                                .cornerRadius(16)
                                .shadow(color: .yellow.opacity(0.6), radius: 20, x: 0, y: 10)
                                .onTapGesture {
                                    // Ne rien faire pour éviter la fermeture
                                }

                            Text(selectedCard.name)
                                .font(.system(size: 22, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .transition(.opacity)
                }
            }
        }
    }
}

