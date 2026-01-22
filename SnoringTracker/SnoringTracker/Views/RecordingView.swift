import SwiftUI

struct RecordingView: View {
    @EnvironmentObject var recordingManager: RecordingManager
    @State private var showingPermissionAlert = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 40) {
                    Spacer()

                    // Moon icon
                    Image(systemName: recordingManager.isRecording ? "moon.zzz.fill" : "moon.fill")
                        .font(.system(size: 100))
                        .foregroundColor(recordingManager.isRecording ? .yellow : .white)
                        .shadow(radius: 10)

                    // Status text
                    Text(recordingManager.isRecording ? "Recording..." : "Ready to Track")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    if recordingManager.isRecording {
                        Text(formatTime(recordingManager.currentSession?.duration ?? 0))
                            .font(.system(size: 48, weight: .light, design: .rounded))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    // Record button
                    Button(action: {
                        if recordingManager.permissionGranted {
                            if recordingManager.isRecording {
                                recordingManager.stopRecording()
                            } else {
                                recordingManager.startRecording()
                            }
                        } else {
                            showingPermissionAlert = true
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(recordingManager.isRecording ? Color.red : Color.green)
                                .frame(width: 120, height: 120)
                                .shadow(radius: 15)

                            Image(systemName: recordingManager.isRecording ? "stop.fill" : "play.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 50)

                    // Instructions
                    if !recordingManager.isRecording {
                        VStack(spacing: 10) {
                            Text("Place your phone near your bed")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                            Text("Keep the app open while sleeping")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }

                    Spacer()
                }
            }
            .navigationTitle("Sleep Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Microphone Permission Required", isPresented: $showingPermissionAlert) {
                Button("Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Please enable microphone access in Settings to record your sleep.")
            }
        }
    }

    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
