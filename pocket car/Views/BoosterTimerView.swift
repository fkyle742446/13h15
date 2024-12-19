import SwiftUI
import Foundation

struct BoosterTimerView: View {
    @StateObject private var storeManager = StoreManager.shared
    @State private var remainingTime: TimeInterval = 0
    @State private var showingPointsAlert = false
    
    var body: some View {
        VStack {
            Text(timeString(from: remainingTime))
                .onTapGesture {
                    showingPointsAlert = true
                }
        }
        .alert("Use Points", isPresented: $showingPointsAlert) {
            let hoursNeeded = Int(ceil(remainingTime / 3600))
            
            Button("Use \(hoursNeeded) Points") {
                if storeManager.usePoints(amount: hoursNeeded) {
                    completeTimer()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            let hoursNeeded = Int(ceil(remainingTime / 3600))
            Text("You need \(hoursNeeded) points to skip this timer.\nYou have \(storeManager.availablePoints) points available.")
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        return String(format: "%02dh%02d", hours, minutes)
    }
    
    private func completeTimer() {
        // Logic to complete the booster timer
        remainingTime = 0
    }
}
