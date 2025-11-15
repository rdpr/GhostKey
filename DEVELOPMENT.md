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

**To test:**
1. Install app to `/Applications`
2. Launch app
3. Grant notification permission when prompted
4. Check Console.app for logs starting with "🔔 Setting up notifications..."
5. Should see "✅ Notification authorization GRANTED" and test notification

**Troubleshooting:**
- Check System Settings → Notifications → GhostKey (or GhostKey Dev)
- Look for authorization logs in Console.app
- Test notification is sent on first authorization grant

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

### "Notifications don't work"
- Check notification permissions in System Settings
- Look for authorization logs in Console.app
- Verify the app requested permission on first launch
- Ensure app is installed in /Applications folder

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

## Conventional Commits Workflow

### Branch Strategy

GhostKey uses a three-branch release workflow:

```
dev (development) → beta (release candidates) → main (stable)
```

- **`dev` branch**: Active development, creates `X.Y.Z-dev.N` releases
- **`beta` branch**: Release candidates for testing, creates `X.Y.Z-beta.N` releases
- **`main` branch**: Stable releases only, creates `X.Y.Z` releases

### PR Title Format

**All PR titles MUST follow Conventional Commits format:**

```
<type>(<scope>): <description>
```

**Examples:**
- `feat: add dark mode support`
- `fix: resolve crash on startup`
- `docs: update installation guide`
- `feat(ui): implement new settings panel`

**Valid types:** `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `ci`, `build`, `revert`

The PR title validation workflow will enforce this format automatically.

### Versioning and Releases

**Fully Automatic Semantic Versioning:**
- Version is **automatically calculated** from conventional commit types
- **No VERSION file to update!** Everything is derived from git tags and commit messages
- Version bumps:
  - `fix:` → Patch (1.2.3 → 1.2.4)
  - `feat:` → Minor (1.2.3 → 1.3.0)
  - `!` → Major (1.2.3 → 2.0.0)
- Releases are auto-suffixed based on target branch:
  - `main`: `1.3.0` (stable)
  - `beta`: `1.3.0-beta.1`, `1.3.0-beta.2`, ... (auto-incremented)
  - `dev`: `1.3.0-dev.1`, `1.3.0-dev.2`, ... (auto-incremented)

**Automatic CHANGELOG Generation:**
- CHANGELOG is auto-generated from PR titles using `conventional-changelog`
- When you open a PR, a bot commits the CHANGELOG update to your branch
- For major releases, manually enhance with breaking changes/migration notes

**Automatic Releases:**
1. Merge PR to `dev`, `beta`, or `main`
2. GitHub Actions automatically:
   - Detects version and channel
   - Builds and signs the app
   - Creates release with appropriate suffix
   - Updates appcast with channel tags
   - Publishes to GitHub Releases

### Release Channels (Sparkle)

The appcast includes channel tags for different release types:
- **Dev releases**: `<sparkle:channel>dev</sparkle:channel>`
- **Beta releases**: `<sparkle:channel>beta</sparkle:channel>`
- **Stable releases**: No channel tag (default)

This allows future implementation of user preferences for subscribing to beta/dev releases.

### How to Create Releases

**Dev Release:**
1. Create feature branch from `dev`
2. Make changes and commit
3. Open PR to `dev` with conventional commit title
4. CHANGELOG auto-updates on PR
5. Merge → auto-releases as `X.Y.Z-dev.N`

**Beta Release:**
1. Create PR from `dev` to `beta` with conventional title
2. CHANGELOG auto-updates on PR
3. Merge → auto-releases as `X.Y.Z-beta.N`

**Stable Release:**
1. Create PR from `beta` to `main` with conventional title
2. CHANGELOG auto-updates on PR
3. Merge → auto-releases as `X.Y.Z`

**Version Bumping is Automatic:**
- No need to manually update any VERSION file!
- The system automatically:
  - Reads the latest stable version from git tags
  - Analyzes your commit type (`feat`, `fix`, `!`)
  - Calculates the next semantic version
  - Applies channel suffixes for dev/beta
  - Creates the release with the correct version

## Release Process

See [RELEASE.md](.github/RELEASE.md) for detailed information about the automated release workflow.

**Quick version:**
- Releases are fully automated via GitHub Actions
- No manual intervention needed
- Just merge PRs with conventional commit titles
- Version numbers and CHANGELOG update automatically

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

## Code Signing and Distribution

### GitHub Releases
All releases from GitHub Actions are **code-signed and notarized** by Apple:

**How it works:**
1. GitHub Actions installs the Developer ID certificate from secrets
2. Xcode builds and signs the app with the certificate
3. The DMG is submitted to Apple for notarization
4. Notarization ticket is stapled to the DMG
5. Sparkle's `generate_appcast` tool signs the update ZIP

**Required secrets/variables in GitHub:**
- `APPLE_CERTIFICATE_BASE64`: Base64-encoded .p12 certificate
- `APPLE_CERTIFICATE_PASSWORD`: Password for the certificate
- `APPLE_APP_STORE_CONNECT_API_KEY`: App Store Connect API key (.p8 file, base64)
- `APPLE_APP_STORE_CONNECT_API_KEY_ID`: API Key ID
- `APPLE_APP_STORE_CONNECT_API_ISSUER_ID`: Issuer ID
- `APPLE_TEAM_ID`: 10-character Team ID
- `APPLE_CODE_SIGN_IDENTITY`: Certificate identity string
- `SPARKLE_PRIVATE_KEY`: EdDSA private key for signing updates

### Local Development Builds
**Debug builds (from Xcode):**
- Automatically signed by Xcode with adhoc signature
- Bundle ID: `com.rdpr.GhostKey.debug`
- Display name: "GhostKey Dev"
- Full functionality including notifications

**Release builds (from Xcode):**
- Can be signed with Developer ID if certificate is installed
- Bundle ID: `com.rdpr.GhostKey`
- Display name: "GhostKey"

### Manual Code Signing (Optional)
If you have an Apple Developer account and want to manually sign:

```bash
# Sign the app
codesign --sign "Developer ID Application: Your Name (TEAMID)" \
  --deep --force --options runtime \
  GhostKey.app

# Verify signature
codesign -dv --verbose=4 GhostKey.app
codesign --verify --deep --strict GhostKey.app

# Notarize (requires App Store Connect API key)
xcrun notarytool submit GhostKey.dmg \
  --key ~/.private_keys/AuthKey_KEYID.p8 \
  --key-id YOUR_KEY_ID \
  --issuer YOUR_ISSUER_ID \
  --wait

# Staple notarization ticket
xcrun stapler staple GhostKey.dmg
xcrun stapler validate GhostKey.dmg
```

## Tips

- Use `NSLog()` for debug output (visible in Console.app)
- Test DMG installs separately from Xcode runs
- Keep Debug and Release versions side-by-side for comparison
- Check Console.app for detailed logs when debugging issues
- All GitHub releases are fully signed and notarized

