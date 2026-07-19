# Sim Train

A macOS menu bar application for managing iOS, watchOS, tvOS, and visionOS simulators. Sim Station provides a convenient interface to interact with Xcode's simulator command-line tools without leaving your menu bar.

<img width="419" height="309" alt="Screenshot 2026-07-19 at 11 43 13 AM" src="https://github.com/user-attachments/assets/672caa18-1ad9-4e1a-844d-ec18f5b1ac7a" />
<img width="419" height="309" alt="Screenshot 2026-07-19 at 11 43 46 AM" src="https://github.com/user-attachments/assets/2e6d676c-8ba1-4d76-a4ca-369b4a2b1438" />

## Features

### Simulator Management
- **Create Simulators**: Multi-step wizard to create new simulators
  - Select runtime (iOS/watchOS/tvOS/visionOS versions)
  - Choose device type (iPhone, iPad, Apple Watch, Apple TV, Vision Pro models)
  - Name and configure your simulator
- **View All Simulators**: Organized by OS and version with visual status indicators
- **Boot/Shutdown**: Quick access to start and stop simulators
- **Delete**: Remove unwanted simulators
- **Erase Content**: Wipe simulator data without deleting

### Simulator Inspection
- **Active Processes**: View and search running processes in any simulator
- **Installed Applications**: Browse apps installed in each simulator
  - Open app data containers
  - Access UserDefaults plist files
- **Simulator Information**: Detailed information about each simulator
- **Documents Access**: Quick access to simulator document folders

### Device Simulation
- **Battery Status**: Simulate battery levels and charging states
  - Adjust battery level (0-100%)
  - Set charge state (charging, charged, discharging)

### User Experience
- **Menu Bar Integration**: Always accessible from your menu bar
- **Auto-refresh**: Simulator list updates when app becomes active
- **Visual Status Indicators**: Green dot for booted simulators, white for shutdown
- **Searchable Interfaces**: Quick filtering in process lists
- **Loading States**: Clear visual feedback for all async operations

## Installation

### Installing from the dmg file
1. Click the releases button
2. Downlaod the zip file and install

### Building from Source

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd Sim-Station
   ```

2. Open the project in Xcode:
   ```bash
   open "Sim Station.xcodeproj"
   ```

3. Build and run (⌘R)

The app will appear in your menu bar with a train icon.

## License

Sim Station is available under the BSD Zero Clause License. See [LICENSE](LICENSE).

## Acknowledgments

- Built with [SSM](https://github.com/JohnDemirci/SSM) state management framework
- Uses Apple's `simctl` command-line tools
- Icons and UI components built with SwiftUI
