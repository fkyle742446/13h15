import SwiftUI
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    private var audioPlayers: [URL: AVAudioPlayer] = [:]
    
    func playSound(for rarity: CardRarity) {
        let soundName: String
        let volume: Float
        
        switch rarity {
        case .common:
            soundName = "common_reveal"
            volume = 0.5
        case .rare:
            soundName = "rare_reveal"
            volume = 0.6
        case .epic:
            soundName = "epic_reveal"
            volume = 0.7
        case .legendary:
            soundName = "legendary_reveal"
            volume = 0.8
        }
        
        guard let path = Bundle.main.path(forResource: soundName, ofType: "mp3") else {
            print("Failed to find sound file: \(soundName)")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume
            player.play()
            audioPlayers[url] = player
            
            // Clean up after playing
            DispatchQueue.main.asyncAfter(deadline: .now() + player.duration + 0.1) {
                self.audioPlayers.removeValue(forKey: url)
            }
        } catch {
            print("Failed to play sound: \(error.localizedDescription)")
        }
    }
}

struct BoosterOpeningView: View {
    @ObservedObject var collectionManager: CollectionManager

    @State private var isOpening = true
    @State private var boosterScale: CGFloat = 1.0
    @State private var boosterOpacity: Double = 1.0
    @State private var currentCardIndex = 0
    @State private var cardScale: CGFloat = 1.3
    @State private var cardOffset: CGFloat = 0
    @State private var showParticles = false
    @Environment(\.presentationMode) var presentationMode

    @State private var dragOffset: CGFloat = 0
    @State private var showArrowIndicator = true

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

            // Arrow indicator
            if !isOpening && showArrowIndicator {
                VStack {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                        .opacity(1.0 - abs(dragOffset/100))
                        .offset(y: -20)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: dragOffset)
                    Spacer()
                }
                .padding(.top, 40)
            }

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

                        ZStack {
                            // Halo effect
                            RoundedRectangle(cornerRadius: 20)
                                .fill(haloColor(for: selectedCard.rarity))
                                .blur(radius: 20)
                                .frame(width: 240, height: 340)
                                .opacity(0.7)
                                .scaleEffect(cardScale)
                                .offset(y: cardOffset + dragOffset)
                            
                            HolographicCard(cardImage: selectedCard.name)
                                .scaleEffect(cardScale)
                                .offset(y: cardOffset + dragOffset)
                                .modifier(AutoHolographicAnimation())
                                .gesture(
                                    DragGesture()
                                        .onChanged { gesture in
                                            let translation = gesture.translation.height
                                            if translation < 0 { // Only allow upward swipes
                                                dragOffset = translation
                                                showArrowIndicator = false
                                            }
                                        }
                                        .onEnded { gesture in
                                            if dragOffset < -100 { // Threshold for card switch
                                                withAnimation(.easeInOut(duration: 0.3)) {
                                                    cardOffset = -UIScreen.main.bounds.height
                                                }
                                                collectionManager.addCard(selectedCard)
                                                
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                    cardOffset = 0
                                                    currentCardIndex += 1
                                                    dragOffset = 0
                                                    showParticles = true
                                                    showArrowIndicator = true
                                                    // Play sound for next card
                                                    if currentCardIndex < 5 {
                                                        SoundManager.shared.playSound(for: randomCard().rarity)
                                                    }
                                                }
                                            } else {
                                                withAnimation {
                                                    dragOffset = 0
                                                    showArrowIndicator = true
                                                }
                                            }
                                        }
                                )
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        cardOffset = -UIScreen.main.bounds.height
                                    }
                                    collectionManager.addCard(selectedCard)
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        cardOffset = 0
                                        currentCardIndex += 1
                                        dragOffset = 0
                                        showParticles = true
                                        showArrowIndicator = true
                                        // Play sound for next card
                                        if currentCardIndex < 5 {
                                            SoundManager.shared.playSound(for: randomCard().rarity)
                                        }
                                    }
                                }
                                .onAppear {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        cardScale = 1.3
                                        showParticles = true
                                    }
                                    // Play sound when card appears
                                    SoundManager.shared.playSound(for: selectedCard.rarity)
                                }
                        }
                        
                        // Rarity text below card
                        Text(selectedCard.rarity.rawValue.uppercased())
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(haloColor(for: selectedCard.rarity))
                            .padding(.top, 20)
                            .opacity(0.8)
                    } else {
                        Text("")
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

    // Add this function to your view struct
    private func haloColor(for rarity: CardRarity) -> Color {
        switch rarity {
        case .common:
            return Color.white
        case .rare:
            return Color.blue
        case .epic:
            return Color.purple
        case .legendary:
            return Color(red: 1, green: 0.84, blue: 0) // Golden color
        }
    }
}

struct AutoHolographicAnimation: ViewModifier {
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(isAnimating ? 5 : -5),
                axis: (x: 0.0, y: 1.0, z: 0.0)
            )
            .onAppear {
                withAnimation(
                    Animation
                        .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                ) {
                    isAnimating = true
                }
            }
    }
}










