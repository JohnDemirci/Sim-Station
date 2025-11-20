# Sim Station

A macOS menu bar application for managing iOS, watchOS, tvOS, and visionOS simulators. Sim Station provides a convenient interface to interact with Xcode's simulator command-line tools without leaving your menu bar.

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
- **Location Updates**: Update simulator location (coming soon)

### User Experience
- **Menu Bar Integration**: Always accessible from your menu bar
- **Auto-refresh**: Simulator list updates when app becomes active
- **Visual Status Indicators**: Green dot for booted simulators, white for shutdown
- **Searchable Interfaces**: Quick filtering in process lists
- **Loading States**: Clear visual feedback for all async operations

## Requirements

- macOS 13.0 or later
- Xcode 14.0 or later (for simulator support)
- Swift 5.9 or later

## Installation

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

## Architecture

Sim Station is built using modern Swift and SwiftUI with a clean, modular architecture:

### State Management (SSM Framework)
- **Redux-like pattern** with Reducers and Stores
- **Unidirectional data flow** for predictable state updates
- **LoadableValue** wrapper for tracking async operation states
- **BroadcastStudio** pub/sub system for cross-feature communication

### Project Structure
```
Sim Station/
├── Application/        # App entry point and global state
│   ├── Sim_StationApp.swift
│   ├── GlobalReducer.swift
│   └── AppEnvironment.swift
├── Models/             # Domain models
│   ├── Simulator.swift
│   ├── OS.swift
│   ├── SimulatorRuntime.swift
│   └── BatteryState.swift
├── Shell/              # Command execution layer
│   ├── Shell+Command.swift
│   └── Commands/       # Individual command implementations
├── UI/                 # SwiftUI views and reducers
│   ├── MenuBarListView/
│   ├── SimulatorListView/
│   ├── CreateSimulatorView/
│   ├── ActiveProcessesView/
│   ├── BatteryStatusView/
│   └── Common/         # Reusable components
└── Utility/            # Helper utilities
```

### Key Design Patterns
- **Protocol-Oriented Design**: `ShellCommand` protocol for all simulator operations
- **Dependency Injection**: `AppEnvironment` provides testable command factories
- **Type Safety**: `ShellCommandToken` enum prevents command construction errors
- **Modern Concurrency**: Async/await throughout, Swift 6 concurrency compliant
- **Generic Window Management**: Type-safe multi-window coordination

## Usage

### Creating a Simulator
1. Click the Sim Station icon in your menu bar
2. Click "Create Simulator"
3. Follow the wizard:
   - Select runtime version
   - Choose device type
   - Enter a name
   - Review and confirm

### Managing Simulators
1. Click the Sim Station icon in your menu bar
2. Find your simulator in the list (organized by OS)
3. Click on a simulator to see available actions:
   - Boot/Shutdown
   - View Active Processes
   - Open Documents folder
   - View Simulator Information
   - See Installed Applications
   - Modify Battery Status
   - Delete

### Simulating Battery States
1. Right-click a booted simulator
2. Select "Modify Battery Status"
3. Adjust battery level and charge state
4. Changes apply immediately to the simulator

## Development

### Dependencies
- **SSM**: Custom state management framework
- **swift-collections**: Apple's OrderedDictionary for maintaining simulator order

### Shell Commands
The app wraps 14 `simctl` commands:
- `CreateSimulator`
- `DeleteSimulator`
- `EraseContent`
- `FetchActiveProcesses`
- `FetchDeviceTypes`
- `FetchRuntimes`
- `FetchSimulators`
- `OpenPath`
- `OpenSimulator`
- `RetrieveBatteryState`
- `RetrieveInstalledApplications`
- `SetNewBatteryState`
- `ShutdownSimulator`
- `UpdateLocation`

Each command implements the `ShellCommand` protocol with proper error handling and type-safe result parsing.

### Adding New Features
1. Create a new command in `Shell/Commands/` implementing `ShellCommand`
2. Add the command factory to `AppEnvironment`
3. Create a reducer in the appropriate UI directory
4. Build the SwiftUI view
5. Integrate with `GlobalReducer` if it requires a new window

## Contributing

Contributions are welcome! Please follow these guidelines:
- Follow Swift API Design Guidelines
- Maintain the existing architecture patterns
- Add tests for new shell commands
- Update this README for new features

## License

## Acknowledgments

- Built with [SSM](https://github.com/JohnDemirci/SSM) state management framework
- Uses Apple's `simctl` command-line tools
- Icons and UI components built with SwiftUI
