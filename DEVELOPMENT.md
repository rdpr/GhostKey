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
rm -rf ~/Library/Application\ Support/GhostKey 2>/dev/null && echo "✓ Deleted Application Support (codes.txt)"

# Restart preferences daemon
killall cfprefsd 2>/dev/null && echo "✓ Restarted preferences daemon"

echo "✅ Complete reset done!"
echo "Note: This will reset the Welcome Guide and delete all codes"
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
Notifications require explicit permission and proper app registration:

**Debug builds (from Xcode):**
- Usually work immediately
- Check Console for detailed logs

**Release builds (DMG):**
- May not appear in System Settings → Notifications (unsigned app limitation)
- App needs to be in `/Applications` folder
- Workaround: Restart Notification Center after first launch:
  ```bash
  killall NotificationCenter
  ```
- Check Console.app for logs starting with "🔔 Setting up notifications..."
- Test notification sent on first authorization grant

**To test:**
1. Install DMG to `/Applications`
2. Launch app
3. Check Console.app for notification setup logs
4. Look for bundle ID and authorization status
5. Should see "✅ Notification authorization GRANTED" and test notification

### Hotkeys
Hotkeys are stored in UserDefaults with fallback to defaults:
- Default: ⌃⌥⌘Y (Control+Option+Command+Y)
- Modifier value: 6400 (Control=4096 + Option=2048 + Cmd=256)
- Fallback protection prevents broken hotkeys on reset
- Check console for "Registering hotkey: keyCode=16, modifiers=6400"

### Automatic Updates (Sparkle)
GhostKey uses the Sparkle framework for automatic updates:
- **Public key** is hardcoded in `Info.plist` (`SUPublicEDKey`)
- **Private key** is stored in GitHub Secrets (`SPARKLE_PRIVATE_KEY`)
- GitHub Actions workflow signs releases automatically
- Updates are checked daily and on manual trigger from menu
- Local builds have full update support (no special setup needed)

**For contributors:** No Sparkle setup required. The public key is already in the repository.

**For maintainers:** The private key must remain in GitHub Secrets. Never commit it to the repository.

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
├── CodeStore           - Code storage and consumption
├── FileWatcher         - Monitors files for changes
├── PasteManager        - Keyboard event synthesis
├── GlobalHotKey        - Hotkey registration
├── NotificationManager - System notifications
├── PreferencesWindow   - Settings UI
├── ManageCodesWindow   - Main code management hub (shows in dock)
└── WelcomeWindow       - First-launch tutorial (4-step guide)
```

### Key Components

**ManageCodesWindow** (formerly RegisterWindow):
- Central hub for code management
- Live counter with threshold badges
- Auto-refreshing code list (1-second timer)
- Interactive delete buttons
- Real-time validation
- Shows app in dock when open

**WelcomeWindow**:
- Multi-step onboarding flow
- Shows on first launch
- Can be reopened from menu
- Leads to ManageCodesWindow on completion

## Notification Issues (Unsigned Apps)

### The Problem
macOS returns `UNErrorCodeNotificationsNotAllowed` (Error Code=1) for unsigned apps, regardless of entitlements:

```
[com.rdpr.GhostKey] Requested authorization [ didGrant: 0 hasError: 1 ]
❌ Notification authorization error: Error Domain=UNErrorDomain Code=1 "(null)"
```

### Root Cause
- **Code signing required**: macOS Notification Center requires apps to be properly signed
- **Entitlements alone aren't enough**: Even with `GhostKey.entitlements`, unsigned apps are rejected
- **Security feature**: This prevents malicious apps from spamming notifications
- **No workarounds**: Restarting Notification Center, clearing preferences, etc. don't work reliably

### Solutions

#### For Development (Local Builds)
✅ **Works perfectly** - Xcode signs debug builds automatically:
1. Build and run from Xcode (⌘R)
2. Notifications work immediately
3. Bundle ID: `com.rdpr.GhostKey.debug` (Dev) or `com.rdpr.GhostKey` (Release)

#### For Distribution (DMG/ZIP)
❌ **Doesn't work** unless you:
1. **Sign with Apple Developer ID** ($99/year)
   ```bash
   codesign --sign "Developer ID Application: Your Name" GhostKey.app
   ```
2. **Notarize the app** (submit to Apple for scanning)
   ```bash
   xcrun notarytool submit GhostKey.dmg --apple-id ... --password ...
   ```
3. **Staple the notarization** (attach approval to app)
   ```bash
   xcrun stapler staple GhostKey.app
   ```

### Testing Notifications

1. **Clean state** (always start fresh):
   ```bash
   ./development-scripts/complete-reset.sh
   ```

2. **Build and run** from Xcode (not from DMG)

3. **Check Console.app**:
   - Filter: "GhostKey"
   - Look for: "✅ Notification authorization GRANTED"
   - Error: "UNErrorDomain Code=1" = unsigned app rejected

4. **Verify in System Settings**:
   - System Settings → Notifications
   - Should see "GhostKey Dev" (Debug) or "GhostKey" (Release)
   - If missing = app not registered (unsigned or error)

### Why GitHub Releases Don't Have Notifications
The automated releases are **unsigned and unnotarized** because:
- No Apple Developer certificate in GitHub Actions
- Would require storing signing credentials in repo (security risk)
- $99/year per developer account
- Users who need notifications should build from source

## Tips

- Use `NSLog()` for debug output (visible in Console.app)
- Test DMG installs separately from Xcode runs
- Keep Debug and Release versions side-by-side for comparison
- Check Console.app for detailed logs when debugging issues
- **Notifications only work in local builds** (from Xcode)

