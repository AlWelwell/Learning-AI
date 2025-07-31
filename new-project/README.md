# Universal Window Accordion

A macOS application that organizes windows from all applications in an accordion-style interface.

## Features (Planned)

- Universal window detection across all macOS applications
- Accordion-style window organization with app-specific grouping
- Customizable per-app configurations and shortcuts
- Smart window grouping and workspace management
- Menu bar integration

## Development Status

- [x] Basic project structure
- [x] App delegate with menu bar integration
- [x] Accessibility permissions handling
- [x] Core data models
- [x] Window detection system
- [ ] Application registry
- [ ] Accordion UI
- [ ] Window management

## Requirements

- macOS 13.0+
- Xcode 15.0+
- Accessibility permissions (requested on first launch)

## Building

1. Open `UniversalAccordion.xcodeproj` in Xcode
2. Build and run (⌘R)
3. Grant accessibility permissions when prompted

## Architecture

The app follows a modular architecture with clear separation of concerns:

- **App**: Main application lifecycle and menu bar
- **Models**: Core data structures
- **WindowManagement**: Window detection and monitoring
- **ApplicationRegistry**: App configuration and detection
- **UI**: Accordion interface components
- **Configuration**: Settings and preferences

## Current Step

**Step 3 Complete**: Window detection system implemented with:
- `UniversalWindowMonitor`: Real-time window detection across all applications using CGWindowList API
- `WindowController`: Window management (focus, minimize, close, move, resize) via Accessibility API
- `ApplicationDetector`: Application discovery from system directories and running processes
- Enhanced AppDelegate with debug menu for testing window detection
- Automatic accessibility permission handling with user-friendly alerts