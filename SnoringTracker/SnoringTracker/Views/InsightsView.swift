import SwiftUI
import Charts

struct InsightsView: View {
    @EnvironmentObject var recordingManager: RecordingManager

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if recordingManager.sessions.isEmpty {
                        EmptyInsightsView()
                    } else {
                        WeeklyStatsCard()
                        TrendsCard()
                        RecommendationsCard()
                    }
                }
                .padding()
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct EmptyInsightsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 80))
                .foregroundColor(.gray)

            Text("No Data Yet")
                .font(.title2)
                .foregroundColor(.gray)

            Text("Record some sleep sessions to see insights and trends")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct WeeklyStatsCard: View {
    @EnvironmentObject var recordingManager: RecordingManager

    var body: some View {
        let stats = recordingManager.getWeeklyStats()

        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                Text("This Week")
                    .font(.headline)
            }

            Divider()

            HStack(spacing: 20) {
                StatItemView(
                    title: "Nights Tracked",
                    value: "\(stats.totalNights)",
                    icon: "moon.fill",
                    color: .blue
                )

                StatItemView(
                    title: "Avg Snoring",
                    value: String(format: "%.0f%%", stats.avgSnoringPercentage),
                    icon: "waveform",
                    color: .orange
                )

                StatItemView(
                    title: "Avg Sleep",
                    value: formatHours(stats.avgDuration),
                    icon: "clock.fill",
                    color: .green
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private func formatHours(_ duration: TimeInterval) -> String {
        let hours = duration / 3600
        return String(format: "%.1fh", hours)
    }
}

struct StatItemView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct TrendsCard: View {
    @EnvironmentObject var recordingManager: RecordingManager

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.purple)
                Text("Trends")
                    .font(.headline)
            }

            Divider()

            if #available(iOS 16.0, *) {
                SnoringTrendChart(sessions: Array(recordingManager.sessions.prefix(7)))
                    .frame(height: 200)
            } else {
                Text("Charts require iOS 16 or later")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Recent Pattern")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text(analyzePattern())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private func analyzePattern() -> String {
        let recentSessions = Array(recordingManager.sessions.prefix(3))
        guard recentSessions.count >= 2 else {
            return "Not enough data to analyze patterns"
        }

        let avgRecent = recentSessions.reduce(0.0) { $0 + $1.snoringPercentage } / Double(recentSessions.count)

        if avgRecent < 20 {
            return "Your snoring is minimal"
        } else if avgRecent < 40 {
            return "Moderate snoring detected"
        } else {
            return "Significant snoring - consider consulting a doctor"
        }
    }
}

@available(iOS 16.0, *)
struct SnoringTrendChart: View {
    let sessions: [RecordingSession]

    var body: some View {
        let chartData = sessions.reversed().map { session in
            ChartDataPoint(
                date: session.startTime,
                percentage: session.snoringPercentage
            )
        }

        Chart(chartData) { item in
            LineMark(
                x: .value("Date", item.date, unit: .day),
                y: .value("Snoring %", item.percentage)
            )
            .foregroundStyle(.blue)
            .interpolationMethod(.catmullRom)

            AreaMark(
                x: .value("Date", item.date, unit: .day),
                y: .value("Snoring %", item.percentage)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [.blue.opacity(0.3), .blue.opacity(0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(.catmullRom)
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in
                AxisValueLabel(format: .dateTime.month().day())
            }
        }
    }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let percentage: Double
}

struct RecommendationsCard: View {
    @EnvironmentObject var recordingManager: RecordingManager

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Recommendations")
                    .font(.headline)
            }

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                ForEach(getRecommendations(), id: \.self) { recommendation in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)

                        Text(recommendation)
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private func getRecommendations() -> [String] {
        let stats = recordingManager.getWeeklyStats()
        var recommendations: [String] = []

        if stats.avgSnoringPercentage > 40 {
            recommendations.append("Consider sleeping on your side instead of your back")
            recommendations.append("Consult with a sleep specialist or doctor")
        } else if stats.avgSnoringPercentage > 20 {
            recommendations.append("Try maintaining a regular sleep schedule")
            recommendations.append("Avoid alcohol before bedtime")
        } else {
            recommendations.append("Your snoring levels are good - keep it up!")
        }

        recommendations.append("Maintain a healthy weight")
        recommendations.append("Keep your bedroom cool and well-ventilated")

        return Array(recommendations.prefix(4))
    }
}
