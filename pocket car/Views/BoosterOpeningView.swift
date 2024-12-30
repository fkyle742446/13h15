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
            volume = 0.7
        case .rare:
            soundName = "rare_reveal"
            volume = 0.7
        case .epic:
            soundName = "epic_reveal"
            volume = 0.7
        case .legendary:
            soundName = "legendary_reveal"
            volume = 0.7
            
        case .HolyT:
            soundName = "legendary_reveal"
            volume = 0.7
        }
        
        guard let path = Bundle.main.path(forResource: soundName, ofType: "mp3") else {
            print("Failed to find sound file: \(soundName)")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        
        // Fade out existing sound if any
        if let existingPlayer = audioPlayers[url] {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                if existingPlayer.volume > 0 {
                    existingPlayer.volume -= 0.1
                } else {
                    timer.invalidate()
                    existingPlayer.stop()
                    self.audioPlayers.removeValue(forKey: url)
                }
            }
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = 0 // Start at 0 volume
            player.play()
            audioPlayers[url] = player
            
            // Fade in
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                if player.volume < volume {
                    player.volume += 0.1
                } else {
                    timer.invalidate()
                }
            }
            
            // Clean up after playing
            DispatchQueue.main.asyncAfter(deadline: .now() + player.duration + 0.1) {
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                    if player.volume > 0 {
                        player.volume -= 0.1
                    } else {
                        timer.invalidate()
                        self.audioPlayers.removeValue(forKey: url)
                    }
                }
            }
        } catch {
            print("Failed to play sound: \(error.localizedDescription)")
        }
    }
}

struct ParticleSystem: View {
    let rarity: CardRarity
    @State private var particles: [(id: Int, position: CGPoint, opacity: Double)] = []
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(particles, id: \.id) { particle in
                Circle()
                    .fill(haloColor(for: rarity))
                    .frame(width: 5, height: 5) // Increased particle size
                    .position(particle.position)
                    .opacity(particle.opacity)
            }
        }
        .onAppear {
            createParticles()
        }
    }
    
    private func createParticles() {
        particles = [] // Reset particles array
        for i in 0...200 { // Increased number of particles
            let angle = Double.random(in: -Double.pi...Double.pi)
            let speed = Double.random(in: 150...500) // Increased speed range
            let startPosition = CGPoint(x: 120, y: 170) // Center of card
            
            var particle = (id: i, position: startPosition, opacity: 0.8)
            particles.append(particle)
            
            withAnimation(.easeOut(duration: 1.0)) {
                let dx = cos(angle) * speed
                let dy = sin(angle) * speed
                particle.position.x += CGFloat(dx)
                particle.position.y += CGFloat(dy)
                particle.opacity = 0
                particles[i] = particle
            }
        }
    }
    
    private func haloColor(for rarity: CardRarity) -> Color {
        switch rarity {
        case .common:
            return .gray
        case .rare:
            return .blue
        case .epic:
            return .purple
        case .legendary:
            return Color(red: 1, green: 0.84, blue: 0)
            
        case .HolyT:
            return Color(red: 1, green: 0.84, blue: 0)
        }
    }
}

struct BoosterOpeningView: View {
    @ObservedObject var collectionManager: CollectionManager
    let boosterImage: String
    
    init(collectionManager: CollectionManager, boosterNumber: Int) {
        self._collectionManager = ObservedObject(wrappedValue: collectionManager)
        self.boosterImage = "booster_closed_\(boosterNumber)"
    }
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
    @State private var currentCard: BoosterCard? = nil
    @State private var isTransitioning = false // Add this state variable

    let allCards: [BoosterCard] = [
            // Common (70%) - Cards 1-70
            BoosterCard(name: "Renault Clio", rarity: .common, number: 1),
            BoosterCard(name: "Peugeot 208", rarity: .common, number: 2),
            BoosterCard(name: "Volkswagen Polo", rarity: .common, number: 3),
            BoosterCard(name: "Ford Fiesta", rarity: .common, number: 4),
            BoosterCard(name: "Toyota Yaris", rarity: .common, number: 5),
            BoosterCard(name: "Fiat 500", rarity: .common, number: 6),
            BoosterCard(name: "Mini Cooper", rarity: .common, number: 7),
            BoosterCard(name: "Hyundai i20", rarity: .common, number: 8),
            BoosterCard(name: "Opel Corsa", rarity: .common, number: 9),
            BoosterCard(name: "Kia Picanto", rarity: .common, number: 10),
            BoosterCard(name: "Citroën C3", rarity: .common, number: 11),
            BoosterCard(name: "SEAT Ibiza", rarity: .common, number: 12),
            BoosterCard(name: "Dacia Sandero", rarity: .common, number: 13),
            BoosterCard(name: "Skoda Fabia", rarity: .common, number: 14),
            BoosterCard(name: "Nissan Micra", rarity: .common, number: 15),
            BoosterCard(name: "Volkswagen Golf", rarity: .common, number: 16),
            BoosterCard(name: "BMW Série 3", rarity: .common, number: 17),
            BoosterCard(name: "Audi A3", rarity: .common, number: 18),
            BoosterCard(name: "Mercedes Classe A", rarity: .common, number: 19),
            BoosterCard(name: "Peugeot 308", rarity: .common, number: 20),
            BoosterCard(name: "Toyota Corolla", rarity: .common, number: 21),
            BoosterCard(name: "Renault Mégane", rarity: .common, number: 22),
            BoosterCard(name: "Skoda Octavia", rarity: .common, number: 23),
            BoosterCard(name: "Honda Civic", rarity: .common, number: 24),
            BoosterCard(name: "Mazda 3", rarity: .common, number: 25),
            BoosterCard(name: "Ford Focus", rarity: .common, number: 26),
            BoosterCard(name: "Hyundai i30", rarity: .common, number: 27),
            BoosterCard(name: "Renault Captur", rarity: .common, number: 28),
            BoosterCard(name: "Peugeot 2008", rarity: .common, number: 29),
            BoosterCard(name: "Volkswagen T-Roc", rarity: .common, number: 30),
            BoosterCard(name: "Toyota RAV4", rarity: .common, number: 31),
            BoosterCard(name: "Hyundai Tucson", rarity: .common, number: 32),
            BoosterCard(name: "Kia Sportage", rarity: .common, number: 33),
            BoosterCard(name: "BMW X1", rarity: .common, number: 34),
            BoosterCard(name: "Audi Q3", rarity: .common, number: 35),
            BoosterCard(name: "Mercedes GLA", rarity: .common, number: 36),
            BoosterCard(name: "Nissan Qashqai", rarity: .common, number: 37),
            BoosterCard(name: "Skoda Kodiaq", rarity: .common, number: 38),
            BoosterCard(name: "SEAT Ateca", rarity: .common, number: 39),
            BoosterCard(name: "Volvo XC40", rarity: .common, number: 40),
            BoosterCard(name: "Land Rover Discovery Sport", rarity: .common, number: 41),
            BoosterCard(name: "Ford Kuga", rarity: .common, number: 42),
            BoosterCard(name: "Volvo V60", rarity: .common, number: 43),
            BoosterCard(name: "Skoda Superb Combi", rarity: .common, number: 44),
            BoosterCard(name: "Audi A4 Avant", rarity: .common, number: 45),
            BoosterCard(name: "BMW Série 5 Touring", rarity: .common, number: 46),
            BoosterCard(name: "Mercedes Classe E Break", rarity: .common, number: 47),
            BoosterCard(name: "Peugeot 508 SW", rarity: .common, number: 48),
            BoosterCard(name: "Volkswagen Passat Variant", rarity: .common, number: 49),
            BoosterCard(name: "Ford Mondeo Estate", rarity: .common, number: 50),
            BoosterCard(name: "Subaru Outback", rarity: .common, number: 51),
            BoosterCard(name: "SEAT Leon ST", rarity: .common, number: 52),
            BoosterCard(name: "Tesla Model 3", rarity: .common, number: 53),
            BoosterCard(name: "Renault Zoe", rarity: .common, number: 54),
            BoosterCard(name: "Volkswagen ID.3", rarity: .common, number: 55),
            BoosterCard(name: "Hyundai Kona Electric", rarity: .common, number: 56),
            BoosterCard(name: "Kia EV6", rarity: .common, number: 57),
            BoosterCard(name: "Nissan Leaf", rarity: .common, number: 58),
            BoosterCard(name: "BMW i3", rarity: .common, number: 59),
            BoosterCard(name: "Audi e-tron", rarity: .common, number: 60),
            BoosterCard(name: "Mercedes EQC", rarity: .common, number: 61),
            BoosterCard(name: "Polestar 2", rarity: .common, number: 62),
            BoosterCard(name: "Renault Kangoo", rarity: .common, number: 63),
            BoosterCard(name: "Citroën Berlingo", rarity: .common, number: 64),
            BoosterCard(name: "Ford Transit Connect", rarity: .common, number: 65),
            BoosterCard(name: "Volkswagen Caddy", rarity: .common, number: 66),
            BoosterCard(name: "Peugeot Rifter", rarity: .common, number: 67),
            BoosterCard(name: "Opel Combo Life", rarity: .common, number: 68),
            BoosterCard(name: "Skoda Roomster", rarity: .common, number: 69),
            BoosterCard(name: "Toyota Proace City Verso", rarity: .common, number: 70),

            // Rare (25%) - Cards 71-90
            BoosterCard(name: "BMW M4 GTS", rarity: .rare, number: 71),
            BoosterCard(name: "Porsche 911 Carrera S", rarity: .rare, number: 72),
            BoosterCard(name: "Mercedes-AMG C63 S Coupe", rarity: .rare, number: 73),
            BoosterCard(name: "Chevrolet Corvette C8", rarity: .rare, number: 74),
            BoosterCard(name: "Lamborghini Huracan Evo", rarity: .rare, number: 75),
            BoosterCard(name: "Ferrari 488 GTB", rarity: .rare, number: 76),
            BoosterCard(name: "McLaren 570S", rarity: .rare, number: 77),
            BoosterCard(name: "Aston Martin V8 Vantage", rarity: .rare, number: 78),
            BoosterCard(name: "Nissan GT-R R35", rarity: .rare, number: 79),
            BoosterCard(name: "Audi R8 V10 Plus", rarity: .rare, number: 80),
            BoosterCard(name: "Maserati GranTurismo MC", rarity: .rare, number: 81),
            BoosterCard(name: "Bentley Continental GT", rarity: .rare, number: 82),
            BoosterCard(name: "Tesla Model S Plaid", rarity: .rare, number: 83),
            BoosterCard(name: "Jaguar XKR-S", rarity: .rare, number: 84),
            BoosterCard(name: "Lotus Exige S", rarity: .rare, number: 85),
            BoosterCard(name: "Shelby GT500", rarity: .rare, number: 86),
            BoosterCard(name: "Koenigsegg Jesko Absolut", rarity: .rare, number: 87),
            BoosterCard(name: "Lexus LFA", rarity: .rare, number: 88),
            BoosterCard(name: "Aston Martin DB11", rarity: .rare, number: 89),
            BoosterCard(name: "Bugatti EB110", rarity: .rare, number: 90),

            // Epic (5%) - Cards 91-100
            BoosterCard(name: "Lamborghini Aventador SVJ", rarity: .epic, number: 91),
            BoosterCard(name: "Ferrari Enzo", rarity: .epic, number: 92),
            BoosterCard(name: "Pagani Zonda Cinque", rarity: .epic, number: 93),
            BoosterCard(name: "Koenigsegg Agera RS", rarity: .epic, number: 94),
            BoosterCard(name: "McLaren P1", rarity: .epic, number: 95),
            BoosterCard(name: "Porsche 918 Spyder", rarity: .epic, number: 96),
            BoosterCard(name: "Bugatti Veyron Super Sport", rarity: .epic, number: 97),
            BoosterCard(name: "Lamborghini Veneno", rarity: .epic, number: 98),
            BoosterCard(name: "Ferrari LaFerrari", rarity: .epic, number: 99),
            BoosterCard(name: "Aston Martin Valkyrie", rarity: .epic, number: 100),

            // Legendary (2%) - Cards 101-108
            BoosterCard(name: "Bugatti Chiron Super Sport 300+", rarity: .legendary, number: 101),
            BoosterCard(name: "McLaren F1", rarity: .legendary, number: 102),
            BoosterCard(name: "Ferrari F40", rarity: .legendary, number: 103),
            BoosterCard(name: "Pagani Zonda R", rarity: .legendary, number: 104),
            BoosterCard(name: "Lamborghini Sian FKP 37", rarity: .legendary, number: 105),
            BoosterCard(name: "Koenigsegg Regera", rarity: .legendary, number: 106),
            BoosterCard(name: "Rimac Nevera", rarity: .legendary, number: 107),
            BoosterCard(name: "Aston Martin One-77", rarity: .legendary, number: 108),
            
            // HolyT (0,1%) - Cards 109-111
    
            BoosterCard(name: "McLaren P1", rarity: .HolyT, number: 109),
            BoosterCard(name: "Ferrari LaFerrari", rarity: .HolyT, number: 110),
            BoosterCard(name: "Porsche 918 Spyder", rarity: .HolyT, number: 111)
            
            
            
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
                        .font(.system(size: 14, weight: .bold))
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
                    Image(boosterImage)
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
                                currentCard = randomCard()
                            }
                        }
                } else {
                    // Révélation des cartes
                    if currentCardIndex < 5 { // Exemple : 5 cartes par booster
                        let selectedCard = currentCard ?? randomCard()

                        VStack(spacing: 60) { // Increased spacing between card and rarity label
                            ZStack {
                                // Particles for all cards
                                ParticleSystem(rarity: selectedCard.rarity)
                                    .frame(width: 300, height: 400) // Increased particle area
                                    .id(currentCardIndex) // Force view recreation for each card
                                
                                // Halo effect that follows holographic animation
                                HolographicCard(
                                    cardImage: selectedCard.name,
                                    rarity: selectedCard.rarity,
                                    cardNumber: selectedCard.number
                                )
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(haloColor(for: selectedCard.rarity))
                                            .blur(radius: 20)
                                            .opacity(0.7)
                                    )
                                    .scaleEffect(cardScale)
                                    .offset(y: cardOffset + dragOffset)
                                    .modifier(AutoHolographicAnimation())
                                    .gesture(
                                        DragGesture()
                                            .onChanged { gesture in
                                                if isTransitioning { return } // Ignore gestures during transition
                                                let translation = gesture.translation.height
                                                if translation < 0 { // Only allow upward swipes
                                                    dragOffset = translation
                                                    showArrowIndicator = false
                                                }
                                            }
                                            .onEnded { gesture in
                                                if isTransitioning { return } // Ignore gestures during transition
                                                if dragOffset < -50 { // Threshold for card switch
                                                    isTransitioning = true // Start transition
                                                    withAnimation(.easeInOut(duration: 0.3)) {
                                                        cardOffset = -UIScreen.main.bounds.height
                                                    }
                                                    collectionManager.addCard(selectedCard)
                                                    
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                        cardOffset = 0
                                                        currentCardIndex += 1
                                                        dragOffset = 0
                                                        showArrowIndicator = true
                                                        // Generate next card before playing sound
                                                        if currentCardIndex < 5 {
                                                            currentCard = randomCard()
                                                            SoundManager.shared.playSound(for: currentCard!.rarity)
                                                        }
                                                        isTransitioning = false // End transition
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
                                        if isTransitioning { return } // Ignore taps during transition
                                        isTransitioning = true // Start transition
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            cardOffset = -UIScreen.main.bounds.height
                                        }
                                        collectionManager.addCard(selectedCard)
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            cardOffset = 0
                                            currentCardIndex += 1
                                            dragOffset = 0
                                            showArrowIndicator = true
                                            // Generate next card before playing sound
                                            if currentCardIndex < 5 {
                                                currentCard = randomCard()
                                                SoundManager.shared.playSound(for: currentCard!.rarity)
                                            }
                                            isTransitioning = false // End transition
                                        }
                                    }
                                    .onAppear {
                                        withAnimation(.easeOut(duration: 0.3)) {
                                            cardScale = 1.3
                                        }
                                        // Play sound when card appears
                                        SoundManager.shared.playSound(for: selectedCard.rarity)
                                    }
                            }
                            
                            // Rarity bubble below card
                            ZStack {
                                Capsule()
                                    .fill(haloColor(for: selectedCard.rarity).opacity(0.4))
                                    .frame(width: 140, height: 40)
                                    .overlay(
                                        Capsule()
                                            .strokeBorder(haloColor(for: selectedCard.rarity), lineWidth: 1)
                                    )
                                
                                Text(selectedCard.rarity.rawValue.uppercased())
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(haloColor(for: selectedCard.rarity))
                            }
                        }
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
            .epic: 0.1,
            .legendary: 0.02
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
        case .HolyT:
            return Color(red: 1, green: 0.84, blue: 0) // Golden color
        }
    }
}

struct AutoHolographicAnimation: ViewModifier {
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(isAnimating ? 4 : -4),
                axis: (x: -1.0, y: 1.0, z: 0.0)
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
