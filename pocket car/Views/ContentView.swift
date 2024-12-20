import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject var collectionManager = CollectionManager()
    @State private var floatingOffset: CGFloat = 0
    @State private var shadowRadius: CGFloat = 15
    @State private var boosterAvailableIn: TimeInterval = 1 * 3 // 3 seconds for testing
    @State private var timer: Timer? = nil
    @State private var giftAvailableIn: TimeInterval = 1 * 10 // 10 seconds for testing
    
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isFadingOut: Bool = false
    @State private var glareOffset: CGFloat = -200
    @State private var booster1GlareOffset: CGFloat = -200
    @State private var booster2GlareOffset: CGFloat = -200
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [.white, Color(.systemGray5)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 30) {
                    // Top logo and gift button
                    VStack(spacing: 20) {
                        // Logo with glare effect
                        ZStack {
                            Image("logo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 80)
                            
                            // Glare effect
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            .clear,
                                            .white.opacity(0.5),
                                            .clear
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 50)
                                .offset(x: glareOffset)
                                .blur(radius: 5)
                        }
                        .mask(
                            Image("logo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 80)
                        )
                        .onAppear {
                            withAnimation(Animation.linear(duration: 15.0).repeatForever(autoreverses: false)) {
                                glareOffset = 200
                            }
                        }
                        
                        // Gift button and timer
                        VStack(spacing: 8) {
                            NavigationLink(destination: Text("Gifts")) {
                                VStack {
                                    Image(systemName: "gift.fill")
                                        .font(.system(size: 24))
                                    Text("Gift")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .foregroundColor(.gray)
                                .frame(width: 60, height: 60)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(1))
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: 1)
                                        )
                                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 2)
                                )
                            }
                            .disabled(giftAvailableIn > 0)
                            
                            if giftAvailableIn > 0 {
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundColor(.gray)
                                    Text(giftTimeRemainingString())
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 15)
                                .background(
                                    Capsule()
                                        .fill(Color.white)
                                        .shadow(color: .gray.opacity(0.4), radius: 4)
                                )
                            }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal)
                    
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
                                .fill(Color.white.opacity(1))
                                .frame(height: 280)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 2)
                            
                            VStack {
                                Spacer()
                                HStack(spacing: 20) {
                                    // First booster with glare
                                    NavigationLink(destination: BoosterOpeningView(collectionManager: collectionManager, boosterNumber: 1)) {
                                        ZStack {
                                            Image("booster_closed_1")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 200)
                                            
                                            // Glare effect for booster 1
                                            Rectangle()
                                                .fill(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            .clear,
                                                            .white.opacity(0.5),
                                                            .clear
                                                        ]),
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .frame(width: 50)
                                                .offset(x: booster1GlareOffset)
                                                .blur(radius: 5)
                                        }
                                        .mask(
                                            Image("booster_closed_1")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 200)
                                        )
                                        .shadow(color: .gray.opacity(0.2), radius: 10)
                                    }
                                    .disabled(boosterAvailableIn > 0)
                                    .onAppear {
                                        withAnimation(Animation.linear(duration: 9.0).repeatForever(autoreverses: false)) {
                                            booster1GlareOffset = 50
                                        }
                                    }

                                    // Second booster with glare
                                    NavigationLink(destination: BoosterOpeningView(collectionManager: collectionManager, boosterNumber: 2)) {
                                        ZStack {
                                            Image("booster_closed_2")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 200)
                                            
                                            // Glare effect for booster 2
                                            Rectangle()
                                                .fill(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            .clear,
                                                            .white.opacity(0.5),
                                                            .clear
                                                        ]),
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .frame(width: 50)
                                                .offset(x: booster2GlareOffset)
                                                .blur(radius: 5)
                                        }
                                        .mask(
                                            Image("booster_closed_2")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 200)
                                        )
                                        .shadow(color: .gray.opacity(0.2), radius: 10)
                                    }
                                    .disabled(boosterAvailableIn > 0)
                                    .onAppear {
                                        withAnimation(Animation.linear(duration: 9.0).repeatForever(autoreverses: false)) {
                                            booster2GlareOffset = 50
                                        }
                                    }
                                }
                                Spacer()
                                
                                // Timer display with placeholder
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
                                            .shadow(color: .gray.opacity(0.4), radius: 4)
                                    )
                                    .padding(.bottom, 10)
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
                                        .fill(Color.white.opacity(1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.white, lineWidth: 1)
                                        )
                                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 2)
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
                                        .fill(Color.white.opacity(1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.white, lineWidth: 1)
                                        )
                                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 2)
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
                                .tint(.pink)
                                .background(Color.white)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 2)
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .onAppear {
            startTimer()
            startGiftTimer()
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
            }
            if giftAvailableIn > 0 {
                giftAvailableIn -= 1
            }
        }
    }
    
    private func startGiftTimer() {
        giftAvailableIn = 10 // Reset gift timer to 10 seconds
    }
    
    private func timeRemainingString() -> String {
        let hours = Int(boosterAvailableIn) / 3600
        let minutes = (Int(boosterAvailableIn) % 3600) / 60
        let seconds = Int(boosterAvailableIn) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func giftTimeRemainingString() -> String {
        let hours = Int(giftAvailableIn) / 3600
        let minutes = (Int(giftAvailableIn) % 3600) / 60
        let seconds = Int(giftAvailableIn) % 60
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

