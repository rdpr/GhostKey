# Changelog

All notable changes to GhostKey will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> **Note**: Version numbers are stored in the `VERSION` file. Update that file to trigger a new release.

## [Unreleased]

<!-- Add unreleased changes here -->

## [1.0.0-alpha.1] - 2025-11-11

### 🎯 Breaking Changes
- **Removed index tracking system**: Codes are now deleted from `codes.txt` when used
- **No more index.json file**: The app now operates on a simpler "consume and delete" model
- Counter now shows the actual number of remaining codes in the file

### Changed
- `CodeStore.consumeNext()` replaces `advance()` - deletes the first code from the file
- Counter always reflects the current length of the codes file
- File watcher now only watches `codes.txt` (no more `index.json`)
- Removed "Reset index" menu item (no longer needed)
- Removed "Open index.json" menu item
- Removed index path configuration from Preferences window

### Technical
- Simplified `CodeStore` by removing all index-related logic
- Removed `IndexFile` model
- Removed checksum validation (no longer needed without index)
- Codes are now atomically written back to file after consumption

### Migration Note
- Existing users: Your `index.json` file will be ignored (safe to delete)
- All codes in `codes.txt` are now available, regardless of previous index position

## [1.0.0] - 2025-11-10

### Added
- Initial release of GhostKey
- Global hotkey for pasting codes (default: ⌃⌥⌘Y)
- Customizable keyboard shortcuts
- Menu bar counter with color-coded status (🟢🟡🟠🔴)
- Automatic file watching with instant updates
- Auto-save preferences (no Save button needed)
- Press Return after pasting option (enabled by default)
- Launch at login support (enabled by default)
- Manual code registration window
- Desktop notifications for low code alerts
- Customizable threshold levels
- Custom file paths for codes.txt and index.json
- Accessibility-based code typing (no clipboard usage)
- Real-time file change detection
- Index tracking with checksum validation

### Features
- Codes stored in plain text format
- Comments and blank lines supported in codes.txt
- Automatic index reset on file changes
- Stepper controls + number input for thresholds
- Visual feedback during hotkey recording
- Reset to default hotkey button
- ScrollView in preferences for better layout
- Resizable preferences window

### Technical
- Built with Swift and SwiftUI
- FileWatcher using DispatchSource for efficient monitoring
- Fixed file watching race condition with double-close issue
- Proper event source (.privateState) for keyboard events
- Session event tap for reliable cross-app typing
- Carbon framework for global hotkey registration
- ServiceManagement for login item control

### Initial Release
- First stable release of GhostKey
- All core features implemented and tested

