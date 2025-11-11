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
- **Removed codes path configuration**: Users can no longer customize `codes.txt` location
- **Removed menu items**: "Reload files" and "Open index.json" no longer available
- Counter now shows the actual number of remaining codes in the file

### ✨ New Features

#### Welcome Guide
- Multi-step interactive tutorial shown on first launch
- 4 steps with progress indicators: Welcome, Getting Started, Understanding Counter, You're All Set
- App icon displayed on welcome screen
- "Don't show this again" option
- Can be reopened anytime via menu → "Show Welcome Guide"
- Automatically opens Manage Codes window after completion

#### Manage Codes Window (Major Overhaul)
- **Renamed** from "Register codes…" to "Manage codes…"
- **Window title**: Now displays "GhostKey"
- **Live counter display** with color-coded emoji and status message
- **Threshold badges**: Quick reference showing all threshold levels (🟢🟡🟠🔴)
- **Real-time code list viewer**:
  - Shows all codes with row numbers (#1, #2, etc.)
  - Auto-refreshes every second
  - Scrollable list with alternating row colors
  - Empty state with helpful message
- **Interactive delete buttons**:
  - Subtle grey minus icon for each code
  - Immediate deletion with file update
  - Tooltip: "Remove this code"
- **Smart auto-scroll**:
  - Automatically scrolls to bottom when codes are added
  - Stays in place when codes are deleted
- **Enhanced input validation**:
  - Real-time validation as you type
  - Visual error messages with icon
  - Success confirmation with green checkmark (auto-dismisses after 2s)
  - Add button disabled when field is empty or has validation errors
  - Fixed-height message container (button doesn't jump)
- **Live threshold updates**: Thresholds automatically update when changed in Preferences
- **Shows in Dock**: App appears in Dock when window is open, hides when closed

#### Hotkey Recorder Improvements
- **Temporarily disables global hotkey** while recording new shortcut
- **Fixed "Press keys..." persistence**: Now properly clears after reset or clicking outside
- **Can record current hotkey**: Previously would trigger paste action, now properly captures the keys
- Notifications sent via `NotificationCenter` to coordinate with app

### 🎨 UI/UX Improvements
- **Preferences**: Click anywhere outside fields to unfocus them
- **Preferences**: Added `.contentShape(Rectangle())` for better tap detection
- **Menu bar**: Changed counter font from monospaced to system font
- **Add button**: Uses top alignment to prevent jumping during validation
- **Delete buttons**: Dark grey color (subtle, not attention-grabbing)
- **Validation messages**: Fixed-height container with invisible spacer when empty

### 🔧 Code Quality & Technical

#### Architecture
- Simplified `CodeStore` by removing all index-related logic:
  - Removed `nextIndex`, `cleanedChecksum` properties
  - Removed `advance()`, `resetIndex()`, `writeIndex()` methods
  - Removed checksum computation and validation
  - Added `consumeNext()` method that deletes first code
  - Added `writeCodes()` helper for atomic file writing
- Removed `IndexFile` model from `Models.swift`
- Removed `reloadAction` callback from `StatusBarController`
- Removed index path from `Utilities.swift` preferences

#### Bug Fixes
- Fixed iOS-only API usage: Removed `.ephemeral` notification status (macOS incompatible)
- Fixed race condition in hotkey recording
- Fixed button layout issues with validation messages

#### Notifications
- Added comprehensive logging for notification authorization
- Added `NSUserNotificationAlertStyle` to `Info.plist`
- Created `GhostKey.entitlements` file (though notifications still require code signing)
- Improved error messages and debugging info

#### File Management
- File watcher now only monitors `codes.txt` (removed `index.json` watch)
- Codes automatically deleted from file after use (atomic writes)
- Auto-refresh timer in Manage Codes window (1-second interval)

### 📝 Documentation
- Updated README with all new features
- Added WelcomeWindow.swift to project structure
- Removed references to index.json throughout
- Updated all "Register codes" mentions to "Manage codes"
- Added notes about dock appearance behavior
- Removed "Reload files" from keyboard shortcuts
- Updated troubleshooting sections

### Migration Note
- **Existing users**: Your `index.json` file will be ignored (safe to delete)
- **All codes available**: Codes in `codes.txt` are now available regardless of previous index position
- **Codes location**: Codes path is now fixed at `~/Library/Application Support/GhostKey/codes.txt`

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

