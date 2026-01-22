import Foundation
import Combine

class RecordingManager: ObservableObject {
    @Published var isRecording = false
    @Published var currentSession: RecordingSession?
    @Published var sessions: [RecordingSession] = []
    @Published var permissionGranted = false

    private let audioRecorder = AudioRecorder()
    private let audioAnalyzer = AudioAnalyzer()
    private let storageKey = "recording_sessions"

    init() {
        loadSessions()
        checkPermission()
    }

    private func checkPermission() {
        audioRecorder.requestPermission { [weak self] granted in
            self?.permissionGranted = granted
        }
    }

    func requestPermission() {
        audioRecorder.requestPermission { [weak self] granted in
            self?.permissionGranted = granted
        }
    }

    func startRecording() {
        guard permissionGranted else {
            requestPermission()
            return
        }

        guard !isRecording else { return }

        let session = RecordingSession(startTime: Date())
        currentSession = session

        if let url = audioRecorder.startRecording() {
            var updatedSession = session
            updatedSession.audioFileURL = url
            currentSession = updatedSession
        }

        isRecording = true
    }

    func stopRecording() {
        guard isRecording, var session = currentSession else { return }

        if let audioURL = audioRecorder.stopRecording() {
            session.endTime = Date()
            session.audioFileURL = audioURL

            // Analyze the recording
            audioAnalyzer.analyzeAudioFile(url: audioURL) { [weak self] events in
                var analyzedSession = session
                analyzedSession.snoringEvents = events
                self?.saveSession(analyzedSession)
                self?.currentSession = nil
            }
        }

        isRecording = false
    }

    private func saveSession(_ session: RecordingSession) {
        sessions.insert(session, at: 0)
        saveSessions()
    }

    func deleteSession(_ session: RecordingSession) {
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            let sessionToDelete = sessions[index]

            // Delete audio file
            if let audioURL = sessionToDelete.audioFileURL {
                try? FileManager.default.removeItem(at: audioURL)
            }

            sessions.remove(at: index)
            saveSessions()
        }
    }

    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([RecordingSession].self, from: data) {
            sessions = decoded
        }
    }

    func getWeeklyStats() -> (totalNights: Int, avgSnoringPercentage: Double, avgDuration: TimeInterval) {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recentSessions = sessions.filter { $0.startTime >= weekAgo }

        guard !recentSessions.isEmpty else {
            return (0, 0, 0)
        }

        let totalNights = recentSessions.count
        let avgPercentage = recentSessions.reduce(0) { $0 + $1.snoringPercentage } / Double(totalNights)
        let avgDuration = recentSessions.reduce(0) { $0 + $1.duration } / Double(totalNights)

        return (totalNights, avgPercentage, avgDuration)
    }

    func createMockSession() {
        let startTime = Date().addingTimeInterval(-Double.random(in: 20000...30000))
        let endTime = startTime.addingTimeInterval(Double.random(in: 21600...28800)) // 6-8 hours
        let events = audioAnalyzer.generateMockSnoringEvents(duration: endTime.timeIntervalSince(startTime))

        let session = RecordingSession(
            startTime: startTime,
            endTime: endTime,
            audioFileURL: nil,
            snoringEvents: events
        )

        saveSession(session)
    }
}
