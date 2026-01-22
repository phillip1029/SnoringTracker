import SwiftUI

@main
struct SnoringTrackerApp: App {
    @StateObject private var recordingManager = RecordingManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(recordingManager)
        }
    }
}
