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
- [ ] Core data models
- [ ] Window detection system
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

**Step 1 Complete**: Basic project structure with menu bar integration and accessibility permission handling.