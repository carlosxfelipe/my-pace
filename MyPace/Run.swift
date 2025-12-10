import Foundation

struct Run: Identifiable {
    let id = UUID()
    let date: Date
    let distanceKm: Double
    let timeMinutes: Double
    
    var pace: Double {
        timeMinutes / distanceKm
    }
}
