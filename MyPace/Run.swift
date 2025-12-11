import Foundation
import SwiftData

@Model
class Run {
    @Attribute(.unique) var id: UUID
    var date: Date
    var distanceKm: Double
    var timeMinutes: Double
    
    var pace: Double {
        timeMinutes / distanceKm
    }
    
    init(id: UUID = UUID(), date: Date, distanceKm: Double, timeMinutes: Double) {
        self.id = id
        self.date = date
        self.distanceKm = distanceKm
        self.timeMinutes = timeMinutes
    }
}
