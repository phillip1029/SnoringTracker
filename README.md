# Snoring Tracker

An iOS app that records and analyzes your snoring patterns during sleep to provide insights and help you understand your sleep quality.

## Features

### Recording
- High-quality audio recording during sleep
- Background recording support
- Real-time recording duration display
- Automatic session management

### Analysis
- Advanced audio analysis to detect snoring events
- Frequency and intensity analysis
- Snoring pattern detection (light, moderate, heavy)
- Statistical analysis of snoring duration and frequency

### Insights
- Comprehensive session history
- Weekly statistics and trends
- Visual charts showing snoring patterns over time (iOS 16+)
- Personalized recommendations based on your data
- Snoring percentage per session
- Average intensity calculations

### User Interface
- Beautiful, intuitive SwiftUI interface
- Three main tabs:
  - **Record**: Start/stop recording with visual feedback
  - **History**: View all past recording sessions
  - **Insights**: Analyze trends and get recommendations
- Dark mode support
- Detailed session views with event breakdown

## Technical Details

### Architecture
- **SwiftUI** for the user interface
- **AVFoundation** for audio recording
- **Combine** for reactive data flow
- **UserDefaults** for data persistence
- **Accelerate** framework for audio analysis

### Components

#### Models
- `RecordingSession`: Represents a sleep recording session
- `SnoringEvent`: Individual snoring event with timestamp, duration, intensity, and frequency

#### Services
- `AudioRecorder`: Handles audio recording using AVFoundation
- `AudioAnalyzer`: Processes audio files to detect snoring patterns
- `RecordingManager`: Coordinates recording, analysis, and data management

#### Views
- `RecordingView`: Main recording interface
- `HistoryView`: List of past sessions with details
- `InsightsView`: Statistics, trends, and recommendations

### Audio Analysis
The app uses signal processing techniques to detect snoring:
- Analyzes audio in windowed segments (2048 samples)
- Detects frequencies in the typical snoring range (50-300 Hz)
- Measures amplitude and intensity
- Uses zero-crossing rate for frequency estimation
- Filters out non-snoring sounds based on intensity thresholds

## Requirements

- iOS 15.0 or later
- Xcode 15.0 or later
- Swift 5.0 or later
- Microphone access permission

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/SnoringTracker.git
cd SnoringTracker
```

2. Open the Xcode project:
```bash
open SnoringTracker/SnoringTracker.xcodeproj
```

3. Select your development team in the project settings

4. Build and run the app on your device or simulator

## Usage

1. **Grant Permissions**: When first launching the app, grant microphone access

2. **Start Recording**:
   - Navigate to the "Record" tab
   - Place your device near your bed
   - Tap the green play button to start recording
   - Keep the app open during sleep

3. **Stop Recording**:
   - Tap the red stop button when you wake up
   - The app will automatically analyze the recording

4. **View Results**:
   - Check the "History" tab to see all your sessions
   - Tap on a session to see detailed snoring events
   - Visit the "Insights" tab for trends and recommendations

## Privacy

- All recordings are stored locally on your device
- No data is sent to external servers
- You have full control to delete any session

## Future Enhancements

Potential features for future versions:
- Export recordings and analysis reports
- Integration with Apple Health
- Smart alarm based on sleep cycles
- Share data with healthcare providers
- Apple Watch integration
- Cloud backup and sync

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is available under the MIT License.

## Disclaimer

This app is for informational purposes only and is not a medical device. If you have concerns about snoring or sleep apnea, please consult with a healthcare professional.