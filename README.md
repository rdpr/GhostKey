# GhostKey

<p align="center">
  <img src="Media.xcassets/AppIcon.appiconset/GhostKey-256.png" alt="GhostKey Logo" width="192" height="192">
</p>

A lightweight macOS menu bar app for quickly pasting authentication codes with a global hotkey. Perfect for managing 2FA codes, one-time passwords, or any sequential codes you need to paste frequently.

## Features

### 🚀 Quick Code Pasting
- **Global Hotkey**: Paste codes instantly with a customizable keyboard shortcut (default: ⌃⌥⌘Y)
- **Automatic Typing**: Codes are typed directly into any application (no clipboard pollution)
- **Auto-Submit**: Optional automatic Return key press after pasting

### 📊 Visual Counter
- **Menu Bar Display**: Shows remaining codes with color-coded status
  - 🟢 Green: Plenty of codes remaining
  - 🟡 Yellow: Getting low
  - 🟠 Orange: Running out
  - 🔴 Red: Critical - time to add more codes!
- **Customizable Thresholds**: Set your own thresholds for each status level

### 📝 Code Management
- **Simple Text File**: Codes stored in `codes.txt` for easy editing
- **Auto-Reload**: File changes are detected automatically (1-second refresh)
- **Management Hub**: Comprehensive window for viewing and adding codes
  - Interactive delete buttons for individual codes
  - Smart auto-scroll to newly added codes
  - Real-time validation with visual feedback
  - Shows app in dock when open
- **Live Counter**: See remaining codes and color thresholds at a glance
- **Automatic Cleanup**: Used codes are deleted from the file automatically

### ⚙️ Customization
- **Custom Hotkey**: Record any keyboard shortcut you prefer
- **Launch at Login**: Option to start automatically
- **Desktop Notifications**: Get alerted when codes are running low
- **Welcome Guide**: Interactive tutorial on first launch (can be shown again anytime)

## Installation

### Download

**Latest Release**: [Download from GitHub Releases](https://github.com/rdpr/ghostkey/releases/latest)

Choose either:
- **DMG** (recommended): Drag and drop to Applications
- **ZIP**: Extract and move to Applications

#### ⚠️ Important: First Launch

This app is **not code-signed or notarized**. macOS Gatekeeper will block it by default.

**Required step to open the app**:

Open Terminal and run:
```bash
xattr -d com.apple.quarantine /Applications/GhostKey.app
```

Then double-click GhostKey.app to open it normally.

> **What this does**: Removes the quarantine flag macOS adds to downloaded apps. You only need to do this once.

### Requirements
- macOS 12.0 (Monterey) or later
- Accessibility permissions (required for typing codes)

### Building from Source
1. Clone the repository:
   ```bash
   git clone https://github.com/rdpr/ghostkey.git
   cd ghostkey
   ```

2. Open the project in Xcode:
   ```bash
   open GhostKey.xcodeproj
   ```

3. Build and run (⌘R)

4. Grant Accessibility permissions when prompted:
   - System Settings → Privacy & Security → Accessibility
   - Enable GhostKey

## Usage

### First Launch

On first launch, GhostKey shows a **Welcome Guide** with:
- Overview of key features
- Setup instructions
- Understanding the counter
- Quick tips

You can revisit this guide anytime via the menu → "Show Welcome Guide"

### Initial Setup

1. **Add Codes**: Click the menu bar icon → "Manage codes…" to:
   - View all your current codes
   - See the live counter and thresholds
   - Add new codes with real-time validation
   - Or manually edit your `codes.txt` file
   
2. **Configure Hotkey** (optional): 
   - Open Preferences (⌘,)
   - Click the "Paste shortcut" field
   - Press your desired key combination
   - Must include at least one modifier key (⌃⌥⇧⌘)

3. **Set Thresholds** (optional):
   - Adjust the color thresholds to match your needs
   - Changes take effect immediately

### Daily Usage

1. **Paste Next Code**: Press your hotkey (default: ⌃⌥⌘Y) while focused on any text field
2. **Monitor Counter**: Check the menu bar to see how many codes remain
3. **Used Codes**: Codes are automatically deleted from `codes.txt` after use

### File Format

**codes.txt**:
```
# Comments start with #
123456
234567
345678
# Blank lines are ignored
456789
```

## Preferences

### Thresholds
- **🟡 Yellow**: Show yellow indicator when codes ≤ this number (default: 40)
- **🟠 Orange**: Show orange indicator when codes ≤ this number (default: 20)
- **🔴 Red**: Show red indicator when codes ≤ this number (default: 10)

### Hotkey
- **Paste shortcut**: Customizable global keyboard shortcut
- **Press Return after pasting**: Automatically press Enter after typing code (enabled by default)

### General
- **Launch at login**: Start GhostKey automatically when you log in (enabled by default)

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| ⌃⌥⌘Y | Paste next code (customizable) |
| ⌘, | Open Preferences |
| ⌘Q | Quit GhostKey |

## Privacy & Security

- **No Network Access**: All data stays on your Mac
- **No Analytics**: Zero tracking or telemetry
- **Local Storage**: Codes stored in plain text files you control
- **Accessibility Only**: Only requests necessary permissions for typing

## Troubleshooting

### Codes Not Typing
1. Check Accessibility permissions: System Settings → Privacy & Security → Accessibility
2. Make sure GhostKey is enabled in the list
3. Try removing and re-adding the permission

### File Not Updating
1. The Manage Codes window auto-refreshes every second
2. Check file permissions on `codes.txt`
3. Ensure the file is in the expected location
4. File watcher monitors `codes.txt` automatically

### Hotkey Not Working
1. Check for conflicts with other apps using the same shortcut
2. Try recording a different key combination in Preferences
3. Restart GhostKey after changing the hotkey

### Notifications Not Appearing (DMG Install)
**This is a known limitation of unsigned apps.** macOS returns `UNErrorCodeNotificationsNotAllowed` (Error Code=1) for unsigned apps, even with proper entitlements.

**The only reliable solution is to build from source:**
1. Clone the repository
2. Open `GhostKey.xcodeproj` in Xcode
3. Build and run (⌘R)
4. The locally-built app will have working notifications

**Why DMG installs don't work:**
- Unsigned apps lack proper code signatures
- macOS refuses to register them for notifications
- Adding entitlements doesn't help without signing
- This is a macOS security feature, not a bug

**Workarounds (unreliable):**
- Restart Notification Center: `killall NotificationCenter`
- Check Console.app for `UNErrorDomain Code=1` errors
- Note: These rarely work for unsigned apps

> **For developers**: To properly distribute with notifications, you need to sign with an Apple Developer ID certificate ($99/year).

## Development

### Project Structure
```
GhostKey/
├── GhostKeyApp.swift        # App entry point
├── StatusBarController.swift # Menu bar UI
├── CodeStore.swift           # Code storage and consumption
├── FileWatcher.swift         # File monitoring
├── PasteManager.swift        # Keyboard event handling
├── Hotkey.swift              # Global hotkey registration
├── PreferencesWindow.swift   # Settings UI
├── RegisterWindow.swift      # Manage codes window (main hub)
├── WelcomeWindow.swift       # First-launch tutorial
├── Notifications.swift       # System notifications
├── Models.swift              # Data models
└── Utilities.swift           # Helpers & preferences
```

### Key Technologies
- **SwiftUI**: Modern UI framework
- **AppKit**: Menu bar and window management
- **Carbon**: Global hotkey registration
- **CoreGraphics**: Keyboard event synthesis
- **ServiceManagement**: Login item management

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by the need for quick 2FA code entry
- Built with ❤️ using Swift and SwiftUI

## Support

If you encounter any issues or have suggestions, please [open an issue](https://github.com/rdpr/ghostkey/issues) on GitHub.

---

**Note**: This is a menu bar app. Look for the counter emoji in your menu bar! The app appears in the Dock only when the Manage Codes window is open.

