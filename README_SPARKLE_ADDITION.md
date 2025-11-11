# Adding Sparkle to GhostKey - Quick Guide

## Current Status
✅ All code implemented  
✅ All configuration files ready  
✅ GitHub Actions workflow updated  
⚠️  **ACTION REQUIRED**: Add Sparkle package in Xcode

## What You Need to Do

Open Xcode and add Sparkle:

1. Open `GhostKey.xcodeproj`
2. Click on **GhostKey** project (blue icon)
3. Select **GhostKey** target
4. Go to **Package Dependencies** tab
5. Click **+** button
6. Paste: `https://github.com/sparkle-project/Sparkle`
7. Click **Add Package**
8. Select **Sparkle** (not TestSupport)
9. Click **Add Package**
10. Build (⌘B) - should compile without errors!

## Files Created
- `GhostKey/UpdateManager.swift` - Sparkle integration
- `appcast.xml` - Update feed
- `SPARKLE_SETUP.md` - Full documentation
- `SPARKLE_TODO.md` - This reminder
- Updated `.github/workflows/release.yml` - Auto-update appcast
- Updated `Info.plist` - Sparkle configuration

## Testing
After adding package:
```bash
# Build and run
# Check menu bar → "Check for Updates..."
```

## Optional: Generate Keys
```bash
brew install sparkle
generate_keys
# Add output to GitHub Secrets as SPARKLE_PRIVATE_KEY and SPARKLE_PUBLIC_KEY
```

See `SPARKLE_SETUP.md` for complete details!
