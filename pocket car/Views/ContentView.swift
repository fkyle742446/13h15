import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject var collectionManager = CollectionManager()
    @State private var floatingOffset: CGFloat = 0
    @State private var shadowRadius: CGFloat = 15
    @State private var boosterAvailableIn: TimeInterval = 1 * 3 // 3 seconds for testing
    @State private var timer: Timer? = nil
    
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isFadingOut: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [.white, Color(.systemGray6)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack {
                    // Single profile image
                    Image("user_profile")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .shadow(color: .gray.opacity(0.2), radius: 5)
                        .padding(.top, 20)
                    
                    Spacer()

                    VStack(spacing: 15) {
                        // Boosters section
                        ZStack {
                            // Base rectangle with depth effect
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color("mint").opacity(0.1))
                                .frame(height: 280)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color("mint").opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: Color("mint").opacity(0.1), radius: 10, x: 0, y: 5)
                            
                            // Surface rectangle
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.white.opacity(0.7))
                                .frame(height: 280)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                            
                            VStack(spacing: 15) {
                                HStack(spacing: 20) {
                                    // First booster
                                    NavigationLink(destination: BoosterOpeningView(collectionManager: collectionManager, boosterNumber: 1)) {
                                        Image("booster_closed_1")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 200)
                                            .shadow(color: .gray.opacity(0.3), radius: 8)
                                    }
                                    .disabled(boosterAvailableIn > 0)

                                    // Second booster
                                    NavigationLink(destination: BoosterOpeningView(collectionManager: collectionManager, boosterNumber: 2)) {
                                        Image("booster_closed_2")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 200)
                                            .shadow(color: .gray.opacity(0.3), radius: 8)
                                    }
                                    .disabled(boosterAvailableIn > 0)
                                }
                                
                                // Timer display
                                if boosterAvailableIn > 0 {
                                    HStack {
                                        Image(systemName: "clock")
                                            .foregroundColor(.gray)
                                        Text(timeRemainingString())
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 15)
                                    .background(
                                        Capsule()
                                            .fill(Color.white)
                                            .shadow(color: .gray.opacity(0.2), radius: 4)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)

                        // Collection and Shop buttons
                        HStack(spacing: 20) {
                            NavigationLink(destination: CollectionView(collectionManager: collectionManager)) {
                                VStack {
                                    Image(systemName: "rectangle.stack.fill")
                                        .font(.system(size: 30))
                                    Text("Collection")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white.opacity(0.7))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.white, lineWidth: 1)
                                        )
                                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                                )
                            }
                            
                            NavigationLink(destination: Text("Shop")) {
                                VStack {
                                    Image(systemName: "bag.fill")
                                        .font(.system(size: 30))
                                    Text("Shop")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white.opacity(0.7))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.white, lineWidth: 1)
                                        )
                                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                                )
                            }
                        }
                        .foregroundColor(.gray)
                        .padding(.horizontal)

                        // Bottom progress bar
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text("Register 150 cards in collection")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("\(collectionManager.cards.count)/150")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                            
                            ProgressView(value: Double(collectionManager.cards.count), total: 150)
                                .tint(.blue)
                                .background(Color.white)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: .gray.opacity(0.1), radius: 5)
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .onAppear {
            startTimer()
            playMusic()
        }
        .onDisappear {
            stopMusic()
        }
    }
    
    // Timer functionality
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if boosterAvailableIn > 0 {
                boosterAvailableIn -= 1
            } else {
                timer?.invalidate()
            }
        }
    }
    
    private func timeRemainingString() -> String {
        let hours = Int(boosterAvailableIn) / 3600
        let minutes = (Int(boosterAvailableIn) % 3600) / 60
        let seconds = Int(boosterAvailableIn) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    // Add these functions inside ContentView struct
    private func playMusic() {
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

    private func stopMusic() {
        // Fade out the music
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
}

#Preview {
    ContentView()
}



