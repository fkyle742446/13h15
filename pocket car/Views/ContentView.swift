import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject var collectionManager = CollectionManager() // Instance partagée
    @State private var floatingOffset: CGFloat = 0 // Offset pour le flottement
    @State private var shadowRadius: CGFloat = 15 // Rayon de l'ombre
    @State private var boosterAvailableIn: TimeInterval = 1 * 3 // Temps d'attente en secondes (1 heure)
    @State private var timer: Timer? = nil
    
    @State private var audioPlayer: AVAudioPlayer? // Gestionnaire audio
    @State private var isFadingOut: Bool = false // Indicateur de fondu sonore

    var body: some View {
        NavigationView {
            ZStack {
                // Fond couvrant tout l'écran
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 170) {
                    // En-tête stylisé
                    HStack {
                        Spacer()
                        Image("user_profile")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 2))
                        Spacer()
                    }
                    .padding(.top, 20)

                    // Bloc principal des boosters avec le timer superposé
                    ZStack {
                        // Bloc des boosters
                        RoundedRectangle(cornerRadius: 30)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.4)]),
                                startPoint: .top,
                                endPoint: .bottom
                            ))
                            .frame(height: 250)
                            .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 5)

                        HStack(spacing: 20) {
                            ForEach(0..<3, id: \.self) { index in
                                NavigationLink(destination: BoosterOpeningView(collectionManager: collectionManager)) {
                                    Image("booster_closed")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 150)
                                        .shadow(color: Color.black.opacity(0.3), radius: shadowRadius, x: 0, y: 5)
                                        .offset(y: floatingOffset)
                                        .onAppear {
                                            // Animation de flottement
                                            withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                                                floatingOffset = -5
                                                shadowRadius = 20
                                            }
                                            startTimer()
                                            playMusic() // Démarre la musique
                                        }
                                }
                                .disabled(boosterAvailableIn > 0)
                            }
                        }
                        .padding(.horizontal, 20)

                        // Timer superposé
                        if boosterAvailableIn > 0 {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.2)]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ))
                                    .shadow(color: .purple.opacity(0.4), radius: 10, x: 0, y: 5)

                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(LinearGradient(
                                        gradient: Gradient(colors: [Color.white.opacity(0.5), Color.purple]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ), lineWidth: 2)

                                VStack(spacing: 4) {
                                    HStack {
                                        ProgressView(value: 1 - (boosterAvailableIn / (1 * 3600)))
                                            .progressViewStyle(LinearProgressViewStyle(tint: .white))
                                            .frame(height: 8)
                                        Text(timeRemainingString())
                                            .font(.footnote)
                                            .foregroundColor(.white)
                                            .padding(.leading, 5)
                                    }
                                    .padding(.horizontal, 10)
                                }
                                .padding(8)
                            }
                            .frame(width: 150, height: 8)
                            .offset(y: 130) // Positionnement du timer au-dessus des boosters
                        } else {
                            Text("Click on a Booster")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(LinearGradient(
                                            gradient: Gradient(colors: [Color.green.opacity(0.3), Color.green.opacity(0.5)]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ))
                                        .shadow(color: .green.opacity(1), radius: 10, x: 0, y: 5)
                                )
                                .frame(width: 320, height: 90)
                                .offset(y: 130) // Positionnement du message au-dessus des boosters
                        }
                    }

                    // Accès à la collection
                    NavigationLink(destination: CollectionView(collectionManager: collectionManager)) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.5)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .shadow(color: .purple.opacity(0.4), radius: 8, x: 0, y: 4)

                            RoundedRectangle(cornerRadius: 15)
                                .stroke(LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.5), Color.purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ), lineWidth: 2)

                            HStack(spacing: 10) {
                                Image(systemName: "tray.full.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.white)
                                Text("Collection")
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 12)
                        }
                        .frame(width: 220, height: 70)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
        }
        .onAppear {
            playMusic()
        }
        .onDisappear {
            stopMusic()
        }
    }

    // Timer
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if boosterAvailableIn > 0 {
                boosterAvailableIn -= 1
            } else {
                timer?.invalidate()
            }
        }
    }

    // Jouer une musique avec fondu
    func playMusic() {
        guard let path = Bundle.main.path(forResource: "Background", ofType: "mp3") else {
            print("Could not find Background.mp3")
            return
        }
        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1  // Loop indefinitely
            audioPlayer?.volume = 0.5
            audioPlayer?.play()
            
            // Fade in
            audioPlayer?.volume = 0
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                if let player = audioPlayer, player.volume < 0.5 {
                    player.volume += 0.1
                } else {
                    timer.invalidate()
                }
            }
        } catch {
            print("Error playing music: \(error.localizedDescription)")
        }
    }

    // Fondu sonore pour arrêter la musique
    func stopMusic() {
        isFadingOut = true
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if let player = audioPlayer, player.volume > 0 {
                player.volume -= 0.1
            } else {
                timer.invalidate()
                audioPlayer?.stop()
                isFadingOut = false
            }
        }
    }

    // Temps restant
    func timeRemainingString() -> String {
        let hours = Int(boosterAvailableIn) / 3600
        let minutes = (Int(boosterAvailableIn) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}

#Preview {
    ContentView()
}


