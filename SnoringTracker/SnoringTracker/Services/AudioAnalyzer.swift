import Foundation
import AVFoundation
import Accelerate

class AudioAnalyzer {
    private let snoringFrequencyRange: ClosedRange<Double> = 50...300 // Hz
    private let snoringIntensityThreshold: Float = -30.0 // dB
    private let analysisWindowSize: Int = 2048

    func analyzeAudioFile(url: URL, completion: @escaping ([SnoringEvent]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let events = self.performAnalysis(url: url)
            DispatchQueue.main.async {
                completion(events)
            }
        }
    }

    private func performAnalysis(url: URL) -> [SnoringEvent] {
        guard let audioFile = try? AVAudioFile(forReading: url) else {
            print("Failed to open audio file")
            return []
        }

        let format = audioFile.processingFormat
        let frameCount = UInt32(audioFile.length)

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            print("Failed to create audio buffer")
            return []
        }

        do {
            try audioFile.read(into: buffer)
        } catch {
            print("Failed to read audio file: \(error)")
            return []
        }

        return analyzeSamples(buffer: buffer, sampleRate: format.sampleRate)
    }

    private func analyzeSamples(buffer: AVAudioPCMBuffer, sampleRate: Double) -> [SnoringEvent] {
        guard let channelData = buffer.floatChannelData?[0] else { return [] }

        let frameLength = Int(buffer.frameLength)
        var snoringEvents: [SnoringEvent] = []
        var currentSnoringStart: TimeInterval?
        var currentSnoringIntensities: [Double] = []

        let hopSize = analysisWindowSize / 2
        var position = 0

        while position + analysisWindowSize < frameLength {
            let window = Array(UnsafeBufferPointer(start: channelData.advanced(by: position), count: analysisWindowSize))

            let (frequency, intensity) = analyzeWindow(samples: window, sampleRate: sampleRate)
            let timestamp = Double(position) / sampleRate

            if isSnoring(frequency: frequency, intensity: intensity) {
                if currentSnoringStart == nil {
                    currentSnoringStart = timestamp
                }
                currentSnoringIntensities.append(Double(intensity))
            } else {
                if let startTime = currentSnoringStart, !currentSnoringIntensities.isEmpty {
                    let duration = timestamp - startTime
                    let avgIntensity = currentSnoringIntensities.reduce(0, +) / Double(currentSnoringIntensities.count)
                    let normalizedIntensity = normalizeIntensity(avgIntensity)

                    let event = SnoringEvent(
                        timestamp: Date(timeIntervalSinceNow: startTime),
                        duration: duration,
                        intensity: normalizedIntensity,
                        frequency: frequency
                    )
                    snoringEvents.append(event)

                    currentSnoringStart = nil
                    currentSnoringIntensities.removeAll()
                }
            }

            position += hopSize
        }

        // Handle any ongoing snoring at the end
        if let startTime = currentSnoringStart, !currentSnoringIntensities.isEmpty {
            let duration = Double(frameLength) / sampleRate - startTime
            let avgIntensity = currentSnoringIntensities.reduce(0, +) / Double(currentSnoringIntensities.count)
            let normalizedIntensity = normalizeIntensity(avgIntensity)

            let event = SnoringEvent(
                timestamp: Date(timeIntervalSinceNow: startTime),
                duration: duration,
                intensity: normalizedIntensity,
                frequency: 100.0
            )
            snoringEvents.append(event)
        }

        return snoringEvents
    }

    private func analyzeWindow(samples: [Float], sampleRate: Double) -> (frequency: Double, intensity: Float) {
        // Calculate RMS (intensity)
        let squaredSamples = samples.map { $0 * $0 }
        let meanSquare = squaredSamples.reduce(0, +) / Float(samples.count)
        let rms = sqrt(meanSquare)
        let intensityDB = 20 * log10(max(rms, 1e-10))

        // Simple peak frequency detection using zero-crossing rate
        var zeroCrossings = 0
        for i in 1..<samples.count {
            if (samples[i] >= 0 && samples[i-1] < 0) || (samples[i] < 0 && samples[i-1] >= 0) {
                zeroCrossings += 1
            }
        }

        let estimatedFrequency = (Double(zeroCrossings) / 2.0) * sampleRate / Double(samples.count)

        return (estimatedFrequency, intensityDB)
    }

    private func isSnoring(frequency: Double, intensity: Float) -> Bool {
        return snoringFrequencyRange.contains(frequency) && intensity > snoringIntensityThreshold
    }

    private func normalizeIntensity(_ intensity: Double) -> Double {
        // Normalize intensity from dB range to 0.0-1.0
        let minDB = -60.0
        let maxDB = 0.0
        let normalized = (intensity - minDB) / (maxDB - minDB)
        return max(0.0, min(1.0, normalized))
    }

    func generateMockSnoringEvents(duration: TimeInterval) -> [SnoringEvent] {
        var events: [SnoringEvent] = []
        let numberOfEvents = Int.random(in: 15...40)

        for _ in 0..<numberOfEvents {
            let timestamp = Date(timeIntervalSinceNow: -Double.random(in: 0...duration))
            let eventDuration = Double.random(in: 2...30)
            let intensity = Double.random(in: 0.2...0.9)
            let frequency = Double.random(in: 80...250)

            let event = SnoringEvent(
                timestamp: timestamp,
                duration: eventDuration,
                intensity: intensity,
                frequency: frequency
            )
            events.append(event)
        }

        return events.sorted { $0.timestamp < $1.timestamp }
    }
}
