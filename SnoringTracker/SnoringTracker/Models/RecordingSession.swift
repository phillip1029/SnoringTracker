import Foundation

struct RecordingSession: Identifiable, Codable {
    let id: UUID
    let startTime: Date
    var endTime: Date?
    var duration: TimeInterval {
        guard let endTime = endTime else {
            return Date().timeIntervalSince(startTime)
        }
        return endTime.timeIntervalSince(startTime)
    }
    var audioFileURL: URL?
    var snoringEvents: [SnoringEvent]
    var totalSnoringDuration: TimeInterval {
        snoringEvents.reduce(0) { $0 + $1.duration }
    }
    var snoringPercentage: Double {
        guard duration > 0 else { return 0 }
        return (totalSnoringDuration / duration) * 100
    }
    var averageIntensity: Double {
        guard !snoringEvents.isEmpty else { return 0 }
        return snoringEvents.reduce(0) { $0 + $1.intensity } / Double(snoringEvents.count)
    }

    init(id: UUID = UUID(), startTime: Date = Date(), endTime: Date? = nil, audioFileURL: URL? = nil, snoringEvents: [SnoringEvent] = []) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.audioFileURL = audioFileURL
        self.snoringEvents = snoringEvents
    }
}
