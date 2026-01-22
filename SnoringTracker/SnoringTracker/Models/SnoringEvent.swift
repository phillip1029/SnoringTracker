import Foundation

struct SnoringEvent: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let duration: TimeInterval
    let intensity: Double // 0.0 to 1.0
    let frequency: Double // in Hz

    init(id: UUID = UUID(), timestamp: Date, duration: TimeInterval, intensity: Double, frequency: Double) {
        self.id = id
        self.timestamp = timestamp
        self.duration = duration
        self.intensity = intensity
        self.frequency = frequency
    }
}

enum SnoringIntensity {
    case light
    case moderate
    case heavy

    init(intensity: Double) {
        switch intensity {
        case 0..<0.3:
            self = .light
        case 0.3..<0.7:
            self = .moderate
        default:
            self = .heavy
        }
    }

    var description: String {
        switch self {
        case .light: return "Light"
        case .moderate: return "Moderate"
        case .heavy: return "Heavy"
        }
    }

    var color: String {
        switch self {
        case .light: return "green"
        case .moderate: return "orange"
        case .heavy: return "red"
        }
    }
}
