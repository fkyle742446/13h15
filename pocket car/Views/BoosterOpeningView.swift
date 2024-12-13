import SwiftUI

struct BoosterOpeningView: View {
    @ObservedObject var collectionManager: CollectionManager

    @State private var isOpening = true
    @State private var boosterScale: CGFloat = 1.0
    @State private var boosterOpacity: Double = 1.0
    @State private var currentCardIndex = 0
    @State private var cardScale: CGFloat = 1.3
    @State private var cardOffset: CGFloat = 0
    @Environment(\.presentationMode) var presentationMode

    let allCards: [BoosterCard] = [
            // Common (50%)
            BoosterCard(name: "Mazda MX-5 Miata", rarity: .common),
            BoosterCard(name: "Volkswagen Golf GTI", rarity: .common),
            BoosterCard(name: "Ford Mustang GT", rarity: .common),
            BoosterCard(name: "Chevrolet Camaro SS", rarity: .common),
            BoosterCard(name: "Toyota Supra Mk4", rarity: .common),
            BoosterCard(name: "Nissan 370Z", rarity: .common),
            BoosterCard(name: "Subaru WRX STI", rarity: .common),
            BoosterCard(name: "Honda Civic Type R", rarity: .common),
            BoosterCard(name: "BMW M3 E46", rarity: .common),
            BoosterCard(name: "Audi TT RS", rarity: .common),
            BoosterCard(name: "Mercedes-AMG A45", rarity: .common),
            BoosterCard(name: "Porsche 718 Cayman", rarity: .common),
            BoosterCard(name: "Alfa Romeo 4C", rarity: .common),
            BoosterCard(name: "Lexus RC F", rarity: .common),
            BoosterCard(name: "Mini Cooper JCW", rarity: .common),
            BoosterCard(name: "Hyundai i30 N", rarity: .common),
            BoosterCard(name: "Fiat 500 Abarth", rarity: .common),
            BoosterCard(name: "Peugeot 208 GTi", rarity: .common),
            BoosterCard(name: "Renault Clio RS", rarity: .common),
            BoosterCard(name: "Ford Focus RS", rarity: .common),
            BoosterCard(name: "Dodge Challenger R/T", rarity: .common),
            BoosterCard(name: "Chevrolet Corvette C6", rarity: .common),
            BoosterCard(name: "Tesla Model 3 Performance", rarity: .common),
            BoosterCard(name: "Mazda RX-8", rarity: .common),
            BoosterCard(name: "Mitsubishi Lancer Evo X", rarity: .common),
            BoosterCard(name: "Toyota GT86", rarity: .common),
            BoosterCard(name: "Nissan Silvia S15", rarity: .common),
            BoosterCard(name: "Jaguar F-Type P300", rarity: .common),
            BoosterCard(name: "Dodge Charger R/T", rarity: .common),

            // Rare (30%)
            BoosterCard(name: "BMW M4 GTS", rarity: .rare),
            BoosterCard(name: "Porsche 911 Carrera S", rarity: .rare),
            BoosterCard(name: "Mercedes-AMG C63 S Coupe", rarity: .rare),
            BoosterCard(name: "Chevrolet Corvette C8", rarity: .rare),
            BoosterCard(name: "Lamborghini Huracan Evo", rarity: .rare),
            BoosterCard(name: "Ferrari 488 GTB", rarity: .rare),
            BoosterCard(name: "McLaren 570S", rarity: .rare),
            BoosterCard(name: "Aston Martin V8 Vantage", rarity: .rare),
            BoosterCard(name: "Nissan GT-R R35", rarity: .rare),
            BoosterCard(name: "Audi R8 V10 Plus", rarity: .rare),
            BoosterCard(name: "Maserati GranTurismo MC", rarity: .rare),
            BoosterCard(name: "Bentley Continental GT", rarity: .rare),
            BoosterCard(name: "Tesla Model S Plaid", rarity: .rare),
            BoosterCard(name: "Jaguar XKR-S", rarity: .rare),
            BoosterCard(name: "Lotus Exige S", rarity: .rare),
            BoosterCard(name: "Shelby GT500", rarity: .rare),
            BoosterCard(name: "Koenigsegg Jesko Absolut", rarity: .rare),
            BoosterCard(name: "Lexus LFA", rarity: .rare),
            BoosterCard(name: "Aston Martin DB11", rarity: .rare),
            BoosterCard(name: "Bugatti EB110", rarity: .rare),

            // Epic (15%)
            BoosterCard(name: "Lamborghini Aventador SVJ", rarity: .epic),
            BoosterCard(name: "Ferrari Enzo", rarity: .epic),
            BoosterCard(name: "Pagani Zonda Cinque", rarity: .epic),
            BoosterCard(name: "Koenigsegg Agera RS", rarity: .epic),
            BoosterCard(name: "McLaren P1", rarity: .epic),
            BoosterCard(name: "Porsche 918 Spyder", rarity: .epic),
            BoosterCard(name: "Bugatti Veyron Super Sport", rarity: .epic),
            BoosterCard(name: "Lamborghini Veneno", rarity: .epic),
            BoosterCard(name: "Ferrari LaFerrari", rarity: .epic),
            BoosterCard(name: "Aston Martin Valkyrie", rarity: .epic),
            BoosterCard(name: "McLaren Senna", rarity: .epic),
            BoosterCard(name: "Lamborghini Reventon", rarity: .epic),
            BoosterCard(name: "Pagani Huayra BC", rarity: .epic),
            BoosterCard(name: "Ford GT (2022)", rarity: .epic),
            BoosterCard(name: "Hennessey Venom GT", rarity: .epic),
            BoosterCard(name: "BMW M5 CS", rarity: .epic),
            BoosterCard(name: "Mercedes-AMG GT Black Series", rarity: .epic),
            BoosterCard(name: "Lexus LFA Nürburgring Edition", rarity: .epic),
            BoosterCard(name: "Chevrolet Corvette ZR1", rarity: .epic),
            BoosterCard(name: "Jaguar XJ220", rarity: .epic),

            // Legendary (5%)
            BoosterCard(name: "Bugatti Chiron Super Sport 300+", rarity: .legendary),
            BoosterCard(name: "McLaren F1", rarity: .legendary),
            BoosterCard(name: "Ferrari F40", rarity: .legendary),
            BoosterCard(name: "Pagani Zonda R", rarity: .legendary),
            BoosterCard(name: "Lamborghini Sian FKP 37", rarity: .legendary),
            BoosterCard(name: "Koenigsegg Regera", rarity: .legendary),
            BoosterCard(name: "Rimac Nevera", rarity: .legendary),
            BoosterCard(name: "Aston Martin One-77", rarity: .legendary),
            BoosterCard(name: "Lamborghini Centenario", rarity: .legendary),
            BoosterCard(name: "Bugatti Divo", rarity: .legendary),
            BoosterCard(name: "Porsche 959", rarity: .legendary),
            BoosterCard(name: "Rolls-Royce Sweptail", rarity: .legendary),
            BoosterCard(name: "Ferrari 250 GTO", rarity: .legendary),
            BoosterCard(name: "McLaren Speedtail", rarity: .legendary),
            BoosterCard(name: "Mercedes-Benz CLK GTR", rarity: .legendary),
            BoosterCard(name: "Bugatti Bolide", rarity: .legendary),
            BoosterCard(name: "Aston Martin Vulcan", rarity: .legendary),
            BoosterCard(name: "Koenigsegg CCXR Trevita", rarity: .legendary),
            BoosterCard(name: "Lamborghini Countach LPI 800-4", rarity: .legendary),
            BoosterCard(name: "Ferrari Monza SP2", rarity: .legendary)
        ]

    var body: some View {
        ZStack {
            // Fond noir
            Color.black.opacity(0.9)
                .ignoresSafeArea()

            VStack {
                if isOpening {
                    // Booster fermé
                    Image("booster_closed")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 400)
                        .scaleEffect(boosterScale)
                        .opacity(boosterOpacity)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                boosterScale = 1.2
                                boosterOpacity = 0
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                isOpening = false
                            }
                        }
                } else {
                    // Révélation des cartes
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
