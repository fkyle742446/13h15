import SwiftUI
import AVFoundation
import SceneKit
import SpriteKit
import UserNotifications

// Add the glow extension
extension View where Self: Shape {
    func glow(
        fill: some ShapeStyle,
        lineWidth: Double,
        blurRadius: Double = 8.0,
        lineCap: CGLineCap = .round
    ) -> some View {
        self
            .stroke(style: StrokeStyle(lineWidth: lineWidth / 2, lineCap: lineCap))
            .fill(fill)
            .overlay {
                self
                    .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: lineCap))
                    .fill(fill)
                    .blur(radius: blurRadius)
            }
            .overlay {
                self
                    .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: lineCap))
                    .fill(fill)
                    .blur(radius: blurRadius / 2)
            }
    }
}

struct ContentView: View {
    @StateObject var collectionManager = CollectionManager()
    @State private var floatingOffset: CGFloat = 0
    @State private var shadowRadius: CGFloat = 15
    @State private var boosterAvailableIn: TimeInterval = 1 * 2 // 3 seconds for testing
    @State private var timer: Timer? = nil
    @State private var giftAvailableIn: TimeInterval = 1 * 10 // 10 seconds for testing
    
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isFadingOut: Bool = false
    @State private var glareOffset: CGFloat = -200
    @State private var booster1GlareOffset: CGFloat = -200
    @State private var booster2GlareOffset: CGFloat = -200
    @State private var rotationAngle: Double = 0
    @State private var rotationAngle2: Double = 180 // Added second rotation angle
    @State private var isCollectionPressed: Bool = false
    @State private var isShopPressed: Bool = false
    
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

                VStack(spacing: 0) {
                    // Top logo and gift button
                    VStack(spacing: -80) {
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
                            
                            // Request notification permission when view appears
                            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
                                if let error = error {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                        
                        // 3D Model View with Legendary Halo
                        ZStack {
                            // Base rectangle with depth effect
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color("mint").opacity(0.1))
                                .frame(height: 250)
                                .overlay(
                                    
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color("mint").opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: Color("mint").opacity(0.1), radius: 10, x: 0, y: 5)
                            
                            // Surface rectangle
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.white.opacity(1))
                                .frame(height: 170)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.white, lineWidth: 1)
                                    
                                )
                                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 2)
                            
                                .offset(y: 30) // Added offset to move down

                            
                            // 3D Model positioned above halo
                            VStack(spacing: -80) {
                                // 3D Model
                                SpriteView(scene: { () -> SKScene in
                                    let scene = SKScene()
                                    scene.backgroundColor = UIColor.clear
                                    
                                    let model = SK3DNode(viewportSize: .init(width: 12, height: 12))
                                    model.scnScene = {
                                        let scnScene = SCNScene(named: "car.obj")!
                                        scnScene.background.contents = UIColor.clear
                                        
                                        let node = scnScene.rootNode.childNodes.first!
                                        
                                        // Add rotation animation
                                        let rotation = CABasicAnimation(keyPath: "rotation")
                                        rotation.fromValue = NSValue(scnVector4: SCNVector4(0, 1, 0, 0))
                                        rotation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi * 2))
                                        rotation.duration = 15
                                        rotation.repeatCount = .infinity
                                        node.addAnimation(rotation, forKey: "rotate")
                                        
                                        
                                        // Ajouter les textures au matériau
                                                let material = SCNMaterial()
                                                material.diffuse.contents = UIImage(named: "texture_diffuse.png") // Texture diffuse
                                                material.metalness.contents = UIImage(named: "texture_metallic.png") // Texture métallique
                                                material.normal.contents = UIImage(named: "texture_normal.png") // Carte de normales
                                                material.roughness.contents = UIImage(named: "texture_roughness.png") // Rugosité
                                        
                                        // Ajouter une émission pour rendre l'objet plus lumineux
                                        material.emission.contents = UIColor.white // Couleur émise
                                        material.emission.intensity = 0.2 // Intensité de la lumière émise
                                        
                                        // Augmenter la réflexion spéculaire
                                        material.specular.contents = UIColor.white
                                        material.shininess = 0.7 // Contrôle la brillance
                                    
                                        
                                        
                                        // Ajouter la texture shaded comme diffuse alternative (si besoin)
                                                    let shadedMaterial = SCNMaterial()
                                                    shadedMaterial.diffuse.contents = UIImage(named: "shaded.png") // Shaded texture
                                        
                                        // Appliquer le matériau à la géométrie
                                               node.geometry?.materials = [material]

                                        
                                        // Add camera to the scene
                                        let cameraNode = SCNNode()
                                        cameraNode.camera = SCNCamera()
                                        cameraNode.position = SCNVector3(x: -1.6, y: 0, z: 14)
                                        scnScene.rootNode.addChildNode(cameraNode)
                                        
                                        return scnScene
                                    }()
                                    
                                    scene.addChild(model)
                                    return scene
                                }(), options: [.allowsTransparency])
                                .frame(height: 150)
                                .background(Color.clear)
                                .zIndex(2) // Ensure model is above halo
                                
                                // Legendary halo effect positioned below model
                                                      ZStack {
                                                          // Base glow
                                                          RoundedRectangle(cornerRadius: 25)
                                                              .fill(
                                                                  RadialGradient(
                                                                      gradient: Gradient(colors: [
                                                                        Color.white.opacity(0.1),
                                                                        Color.white.opacity(0.1),
                                                                          Color.clear
                                                                      ]),
                                                                      center: .center,
                                                                      startRadius: 80,
                                                                      endRadius: 150
                                                                  )
                                                              )
                                                              .frame(width: 300, height: 200)
                                                              .blur(radius: 45)
                                                          
                                                          // Animated rays
                                                          ForEach(0..<10) { i in
                                                              Rectangle()
                                                                  .fill(
                                                                      LinearGradient(
                                                                          colors: [
                                                                              Color.yellow.opacity(0.6),
                                                                              Color.orange.opacity(0.3),
                                                                              Color.clear
                                                                          ],
                                                                          startPoint: .center,
                                                                          endPoint: .trailing
                                                                      )
                                                                  )
                                                                  .frame(width: 200, height: 0.2)
                                                                  .rotationEffect(.degrees(Double(i) * 45))
                                                                  .blur(radius: 5)
                                                          }
                                                      }
                                                      .offset(y: -0)
                                                      .zIndex(1)
                                
                                
                                
                                // Season availability bubble
                                                              Text("Only available this season")
                                                                  .font(.system(size: 12, weight: .medium))
                                                                  .foregroundColor(.white)
                                                                  .padding(.horizontal, 12)
                                                                  .padding(.vertical, 6)
                                                                  .background(
                                                                      Capsule()
                                                                        .fill(
                                                                                                                       LinearGradient(
                                                                                                                           colors: [Color.yellow, Color.orange],
                                                                                                                           startPoint: .leading,
                                                                                                                           endPoint: .trailing
                                                                                                                       )
                                                                                                                   )
                                                                        .shadow(color: .black.opacity(0.2), radius: 4)
                                                                  )
                                                                  .overlay(
                                                                      Capsule()
                                                                          .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                                                  )
                                                                  .offset(y: -15)
                                                                  .zIndex(3)
                            }
                            .padding(-10)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, -10)
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
                                    NavigationLink(destination: BoosterOpeningView(collectionManager: collectionManager, boosterNumber: 1)
                                        .onDisappear {
                                            boosterAvailableIn = 1 * 3 // Reset timer when returning from booster opening
                                        }
                                    ) {
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
                                    NavigationLink(destination: BoosterOpeningView(collectionManager: collectionManager, boosterNumber: 2)
                                        .onDisappear {
                                            boosterAvailableIn = 1 * 3 // Reset timer when returning from booster opening
                                        }
                                    ) {
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
                                
                                // Timer display or instruction text
                                HStack {
                                    if boosterAvailableIn > 0 {
                                        Image(systemName: "clock")
                                            .foregroundColor(.gray)
                                        Text(timeRemainingString())
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.gray)
                                    } else {
                                        Image(systemName: "hand.tap")
                                            .foregroundColor(.gray)
                                        Text("Click on a booster")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.gray)
                                    }
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
                        .padding(.horizontal)

                        // Collection and Shop buttons
                        HStack(spacing: 20) {
                            // Collection Button with animated glow effect
                            NavigationLink(destination: CollectionView(collectionManager: collectionManager)) {
                                ZStack {
                                    // Animated Glowing border
                                    RoundedRectangle(cornerRadius: 20)
                                        .glow(
                                            fill: .angularGradient(
                                                colors: [.blue, .purple, .red, .orange, .yellow, .blue],
                                                center: .center,
                                                startAngle: .degrees(rotationAngle),
                                                endAngle: .degrees(rotationAngle + 360)
                                            ),
                                            lineWidth: 3.0,
                                            blurRadius: 6.0
                                        )
                                        .opacity(0.7)
                                    
                                    // Button content
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
                                .scaleEffect(isCollectionPressed ? 0.5 : 1.0)
                                .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isCollectionPressed = pressing
                                    }
                                }, perform: { })
                            }
                            .foregroundColor(.gray)
                            
                            NavigationLink(destination: Text("Shop")) {
                                ZStack {
                                    // Animated Glowing border
                                    RoundedRectangle(cornerRadius: 20)
                                        .glow(
                                            fill: .angularGradient(
                                                colors: [.blue, .purple, .red, .orange, .yellow, .blue],
                                                center: .center,
                                                startAngle: .degrees(rotationAngle2),
                                                endAngle: .degrees(rotationAngle2 + 360)
                                            ),
                                            lineWidth: 3.0,
                                            blurRadius: 6.0
                                        )
                                        .opacity(0.7)
                                    
                                    // Button content
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
                                .scaleEffect(isShopPressed ? 0.5 : 1.0)
                                .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isShopPressed = pressing
                                    }
                                }, perform: { })
                            }
                            .foregroundColor(.gray)
                        }
                        .onAppear {
                            withAnimation(.linear(duration: 3)
                                .repeatForever(autoreverses: false)) {
                                rotationAngle = 360
                            }
                            withAnimation(.linear(duration: 5)
                                .repeatForever(autoreverses: false)) {
                                rotationAngle2 = 540 // Different speed and starting point
                            }
                        }
                        .padding(.horizontal)

                        // Bottom progress bar
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text("Register 108 cards in collection")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("\(collectionManager.cards.count)/108")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                            
                            ProgressView(value: Double(collectionManager.cards.count), total: 108)
                                .tint(
                                    LinearGradient(
                                        colors: [Color.yellow, Color.orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
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
                if boosterAvailableIn == 0 {
                    // Schedule notification when timer hits 0
                    let content = UNMutableNotificationContent()
                    content.title = "Booster Available!"
                    content.body = "You can now open a booster"
                    content.sound = .default
                    
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request)
                }
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
