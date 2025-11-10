# Development Guide

This guide contains information for developers working on GhostKey.

## Build Configurations

GhostKey uses different bundle identifiers for Debug and Release builds to prevent conflicts:

- **Debug**: `com.rdpr.GhostKey.debug` (Menu bar shows as "GhostKey Dev")
- **Release**: `com.rdpr.GhostKey` (Menu bar shows as "GhostKey")

This allows you to run both the development and production versions simultaneously without conflicts.

## Complete Reset for Testing

When testing fresh installs, use this script to completely reset both versions:

```bash
#!/bin/bash
echo "🧹 Resetting GhostKey (Debug + Release)..."

# Kill both versions
killall GhostKey 2>/dev/null && echo "✓ Killed running apps"

# === Debug build ===
defaults delete com.rdpr.GhostKey.debug 2>/dev/null && echo "✓ Deleted debug defaults"
rm -f ~/Library/Preferences/com.rdpr.GhostKey.debug.plist 2>/dev/null && echo "✓ Deleted debug plist"
rm -rf ~/Library/Caches/com.rdpr.GhostKey.debug 2>/dev/null

# === Release build ===
defaults delete com.rdpr.GhostKey 2>/dev/null && echo "✓ Deleted release defaults"
rm -f ~/Library/Preferences/com.rdpr.GhostKey.plist 2>/dev/null && echo "✓ Deleted release plist"
rm -rf ~/Library/Caches/com.rdpr.GhostKey 2>/dev/null

# === Shared data ===
rm -rf ~/Library/Application\ Support/GhostKey 2>/dev/null && echo "✓ Deleted Application Support"

# Restart preferences daemon
killall cfprefsd 2>/dev/null && echo "✓ Restarted preferences daemon"

echo "✅ Complete reset done!"
```

## Debugging

### Check Console Logs

View logs in Console.app or Xcode console to see:
- Login item registration status
- Notification permission status
- Hotkey registration details
- File watcher events

### Verify Settings

```bash
# Check debug build defaults
defaults read com.rdpr.GhostKey.debug

# Check release build defaults
defaults read com.rdpr.GhostKey

# Check login items
sfltool dumpbtm

# Check notification permissions
# System Settings → Notifications → GhostKey (or GhostKey Dev)
```

## Testing Features

### Login Items
Login items only work properly when:
- App is in `/Applications` folder
- Running a Release build (or archived Debug build)
- Not running from Xcode's DerivedData

To test:
1. Archive the app (Product → Archive → Export)
2. Copy to `/Applications`
3. Reset defaults (see script above)
4. Launch from `/Applications`
5. Check System Settings → General → Login Items

### Notifications
Notifications require explicit permission:
- First launch prompts for permission
- Check Console.app for authorization status
- Verify in System Settings → Notifications

### Hotkeys
Hotkeys are stored in UserDefaults with fallback to defaults:
- Default: ⌃⌥⌘Y (Control+Option+Command+Y)
- Modifier value: 6400 (Control=4096 + Option=2048 + Cmd=256)
- Fallback protection prevents broken hotkeys on reset
- Check console for "Registering hotkey: keyCode=16, modifiers=6400"

## Common Issues

### "Notifications don't work in DMG build"
- Check notification permissions in System Settings
- Look for authorization logs in Console.app
- Verify the app requested permission on first launch

### "Hotkey doesn't work after reset"
- Check console for "Invalid hotkey settings detected"
- Verify defaults are properly registered
- Try manually setting in Preferences

### "Login item doesn't register"
- Verify `SMLoginItemEnabled` is in Info.plist
- Check that app is in `/Applications`
- Look for registration logs in Console.app
- Test with Release build, not Xcode debug

### "Debug and Release builds conflict"
- Both should now have separate bundle identifiers
- Clear both using the reset script above
- Verify they show different names in menu bar

## Release Process

See [RELEASE.md](.github/RELEASE.md) for the automated release workflow.

Quick version:
1. Update `VERSION` file
2. Update `CHANGELOG.md`
3. Commit and push to `main`
4. GitHub Actions handles the rest

## Architecture Overview

```
GhostKeyApp.swift        - Entry point, lifecycle management
├── StatusBarController  - Menu bar UI and interactions
├── CodeStore           - Code storage and index management
├── FileWatcher         - Monitors files for changes
├── PasteManager        - Keyboard event synthesis
├── GlobalHotKey        - Hotkey registration
├── NotificationManager - System notifications
└── PreferencesWindow   - Settings UI
```

## Tips

- Use `NSLog()` for debug output (visible in Console.app)
- Test DMG installs separately from Xcode runs
- Keep Debug and Release versions side-by-side for comparison
- Check Console.app for detailed logs when debugging issues

