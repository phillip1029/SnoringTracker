import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var recordingManager: RecordingManager
    @State private var selectedSession: RecordingSession?
    @State private var showingDetail = false

    var body: some View {
        NavigationView {
            Group {
                if recordingManager.sessions.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "moon.zzz")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)

                        Text("No Recordings Yet")
                            .font(.title2)
                            .foregroundColor(.gray)

                        Text("Start tracking your sleep to see your history")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)

                        Button("Create Demo Session") {
                            recordingManager.createMockSession()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(recordingManager.sessions) { session in
                            SessionRowView(session: session)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedSession = session
                                    showingDetail = true
                                }
                        }
                        .onDelete(perform: deleteSessions)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingDetail) {
                if let session = selectedSession {
                    SessionDetailView(session: session)
                }
            }
        }
    }

    private func deleteSessions(at offsets: IndexSet) {
        for index in offsets {
            let session = recordingManager.sessions[index]
            recordingManager.deleteSession(session)
        }
    }
}

struct SessionRowView: View {
    let session: RecordingSession

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "moon.stars.fill")
                    .foregroundColor(.blue)

                Text(session.startTime, style: .date)
                    .font(.headline)

                Spacer()

                Text(formatDuration(session.duration))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 15) {
                Label("\(session.snoringEvents.count) events", systemImage: "waveform")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Label(String(format: "%.0f%% snoring", session.snoringPercentage), systemImage: "percent")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Intensity indicator
            HStack(spacing: 4) {
                Text("Intensity:")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                IntensityBadge(intensity: session.averageIntensity)
            }
        }
        .padding(.vertical, 4)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}

struct IntensityBadge: View {
    let intensity: Double

    var body: some View {
        let snoringIntensity = SnoringIntensity(intensity: intensity)

        Text(snoringIntensity.description)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(color(for: snoringIntensity))
            .foregroundColor(.white)
            .cornerRadius(4)
    }

    private func color(for intensity: SnoringIntensity) -> Color {
        switch intensity {
        case .light: return .green
        case .moderate: return .orange
        case .heavy: return .red
        }
    }
}

struct SessionDetailView: View {
    let session: RecordingSession
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Summary Card
                    VStack(spacing: 15) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Sleep Session")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text(session.startTime, style: .date)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "moon.stars.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                        }

                        Divider()

                        HStack(spacing: 30) {
                            StatView(title: "Duration", value: formatDuration(session.duration), icon: "clock.fill")
                            StatView(title: "Snoring", value: String(format: "%.0f%%", session.snoringPercentage), icon: "waveform")
                            StatView(title: "Events", value: "\(session.snoringEvents.count)", icon: "chart.bar.fill")
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)

                    // Snoring Events List
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Snoring Events")
                            .font(.headline)
                            .padding(.horizontal)

                        if session.snoringEvents.isEmpty {
                            Text("No snoring detected")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(session.snoringEvents.prefix(20)) { event in
                                EventRowView(event: event, sessionStart: session.startTime)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitle("Session Details", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}

struct StatView: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct EventRowView: View {
    let event: SnoringEvent
    let sessionStart: Date

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(formatTime(event.timestamp))
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("Duration: \(formatDuration(event.duration))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            IntensityBadge(intensity: event.intensity)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes)m \(seconds)s"
    }
}
