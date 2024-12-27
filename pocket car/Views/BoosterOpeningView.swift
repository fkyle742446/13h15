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
            // Common (70%) - Cards 1-29
            BoosterCard(name: "Mazda MX-5 Miata", rarity: .common, number: 1),
            BoosterCard(name: "Volkswagen Golf GTI", rarity: .common, number: 2),
            BoosterCard(name: "Ford Mustang GT", rarity: .common, number: 3),
            BoosterCard(name: "Chevrolet Camaro SS", rarity: .common, number: 4),
            BoosterCard(name: "Toyota Supra Mk4", rarity: .common, number: 5),
            BoosterCard(name: "Nissan 370Z", rarity: .common, number: 6),
            BoosterCard(name: "Subaru WRX STI", rarity: .common, number: 7),
            BoosterCard(name: "Honda Civic Type R", rarity: .common, number: 8),
            BoosterCard(name: "BMW M3 E46", rarity: .common, number: 9),
            BoosterCard(name: "Audi TT RS", rarity: .common, number: 10),
            BoosterCard(name: "Mercedes-AMG A45", rarity: .common, number: 11),
            BoosterCard(name: "Porsche 718 Cayman", rarity: .common, number: 12),
            BoosterCard(name: "Alfa Romeo 4C", rarity: .common, number: 13),
            BoosterCard(name: "Lexus RC F", rarity: .common, number: 14),
            BoosterCard(name: "Mini Cooper JCW", rarity: .common, number: 15),
            BoosterCard(name: "Hyundai i30 N", rarity: .common, number: 16),
            BoosterCard(name: "Fiat 500 Abarth", rarity: .common, number: 17),
            BoosterCard(name: "Peugeot 208 GTi", rarity: .common, number: 18),
            BoosterCard(name: "Renault Clio RS", rarity: .common, number: 19),
            BoosterCard(name: "Ford Focus RS", rarity: .common, number: 20),
            BoosterCard(name: "Dodge Challenger R/T", rarity: .common, number: 21),
            BoosterCard(name: "Chevrolet Corvette C6", rarity: .common, number: 22),
            BoosterCard(name: "Tesla Model 3 Performance", rarity: .common, number: 23),
            BoosterCard(name: "Mazda RX-8", rarity: .common, number: 24),
            BoosterCard(name: "Mitsubishi Lancer Evo X", rarity: .common, number: 25),
            BoosterCard(name: "Toyota GT86", rarity: .common, number: 26),
            BoosterCard(name: "Nissan Silvia S15", rarity: .common, number: 27),
            BoosterCard(name: "Jaguar F-Type P300", rarity: .common, number: 28),
            BoosterCard(name: "Dodge Charger R/T", rarity: .common, number: 29),

            // Rare (25%) - Cards 30-49
            BoosterCard(name: "BMW M4 GTS", rarity: .rare, number: 30),
            BoosterCard(name: "Porsche 911 Carrera S", rarity: .rare, number: 31),
            BoosterCard(name: "Mercedes-AMG C63 S Coupe", rarity: .rare, number: 32),
            BoosterCard(name: "Chevrolet Corvette C8", rarity: .rare, number: 33),
            BoosterCard(name: "Lamborghini Huracan Evo", rarity: .rare, number: 34),
            BoosterCard(name: "Ferrari 488 GTB", rarity: .rare, number: 35),
            BoosterCard(name: "McLaren 570S", rarity: .rare, number: 36),
            BoosterCard(name: "Aston Martin V8 Vantage", rarity: .rare, number: 37),
            BoosterCard(name: "Nissan GT-R R35", rarity: .rare, number: 38),
            BoosterCard(name: "Audi R8 V10 Plus", rarity: .rare, number: 39),
            BoosterCard(name: "Maserati GranTurismo MC", rarity: .rare, number: 40),
            BoosterCard(name: "Bentley Continental GT", rarity: .rare, number: 41),
            BoosterCard(name: "Tesla Model S Plaid", rarity: .rare, number: 42),
            BoosterCard(name: "Jaguar XKR-S", rarity: .rare, number: 43),
            BoosterCard(name: "Lotus Exige S", rarity: .rare, number: 44),
            BoosterCard(name: "Shelby GT500", rarity: .rare, number: 45),
            BoosterCard(name: "Koenigsegg Jesko Absolut", rarity: .rare, number: 46),
            BoosterCard(name: "Lexus LFA", rarity: .rare, number: 47),
            BoosterCard(name: "Aston Martin DB11", rarity: .rare, number: 48),
            BoosterCard(name: "Bugatti EB110", rarity: .rare, number: 49),

            // Epic (3%) - Cards 50-59
            BoosterCard(name: "Lamborghini Aventador SVJ", rarity: .epic, number: 50),
            BoosterCard(name: "Ferrari Enzo", rarity: .epic, number: 51),
            BoosterCard(name: "Pagani Zonda Cinque", rarity: .epic, number: 52),
            BoosterCard(name: "Koenigsegg Agera RS", rarity: .epic, number: 53),
            BoosterCard(name: "McLaren P1", rarity: .epic, number: 54),
            BoosterCard(name: "Porsche 918 Spyder", rarity: .epic, number: 55),
            BoosterCard(name: "Bugatti Veyron Super Sport", rarity: .epic, number: 56),
            BoosterCard(name: "Lamborghini Veneno", rarity: .epic, number: 57),
            BoosterCard(name: "Ferrari LaFerrari", rarity: .epic, number: 58),
            BoosterCard(name: "Aston Martin Valkyrie", rarity: .epic, number: 59),

            // Legendary (2%) - Cards 60-67
            BoosterCard(name: "Bugatti Chiron Super Sport 300+", rarity: .legendary, number: 60),
            BoosterCard(name: "McLaren F1", rarity: .legendary, number: 61),
            BoosterCard(name: "Ferrari F40", rarity: .legendary, number: 62),
            BoosterCard(name: "Pagani Zonda R", rarity: .legendary, number: 63),
            BoosterCard(name: "Lamborghini Sian FKP 37", rarity: .legendary, number: 64),
            BoosterCard(name: "Koenigsegg Regera", rarity: .legendary, number: 65),
            BoosterCard(name: "Rimac Nevera", rarity: .legendary, number: 66),
            BoosterCard(name: "Aston Martin One-77", rarity: .legendary, number: 67)
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
            .common: 0.1,
            .rare: 0.25,
            .epic: 0.25,
            .legendary: 0.25
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
