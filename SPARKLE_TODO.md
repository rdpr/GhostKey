# 🚀 Sparkle Auto-Update - Next Steps

All the code and configuration for Sparkle auto-updates has been implemented! However, there's **one manual step** required that can only be done in Xcode.

## ⚠️ REQUIRED: Add Sparkle Package

**You must add Sparkle via Xcode** before the code will compile:

1. Open `GhostKey.xcodeproj` in Xcode
2. Select the **GhostKey** project (blue icon at top of navigator)
3. Select the **GhostKey** target
4. Go to **Package Dependencies** tab
5. Click **+** button at the bottom
6. Enter URL: `https://github.com/sparkle-project/Sparkle`
7. Click **Add Package**
8. Select **Sparkle** from the list (not SparkleTestSupport)
9. Click **Add Package**

**Why this step?**: Swift Package Manager dependencies must be added through Xcode's UI. The project file format makes it impractical to edit manually.

## ✅ What's Already Done

### Code Implementation
- ✅ `UpdateManager.swift` - Sparkle integration and delegate
- ✅ `GhostKeyApp.swift` - Initialize updater on launch
- ✅ `StatusBarController.swift` - "Check for Updates..." menu item

### Configuration
- ✅ `Info.plist` - All Sparkle keys configured
  - Feed URL pointing to GitHub
  - Automatic checks enabled (every 24 hours)
  - Public key placeholder (auto-filled by workflow)

### Release Automation
- ✅ GitHub Actions workflow updated with:
  - Sparkle tools installation
  - EdDSA signing of ZIP files
  - Automatic appcast.xml generation
  - Public key injection into Info.plist

### Files
- ✅ `appcast.xml` - Update feed (initial version)
- ✅ `SPARKLE_SETUP.md` - Complete setup guide
- ✅ `.gitignore` - Protect private keys

## 🔐 Optional: Generate EdDSA Keys

For **signed updates** (recommended), generate keys:

```bash
brew install sparkle
generate_keys
```

Then add to GitHub Secrets:
- `SPARKLE_PRIVATE_KEY` - Your private key
- `SPARKLE_PUBLIC_KEY` - Your public key

**Without keys**: Workflow will generate temporary keys, but they'll change with each release (not ideal).

## 📝 Testing

After adding the Sparkle package:

1. **Build and Run** (⌘R)
2. Check console for: `✅ Sparkle updater initialized`
3. Click menu → **Check for Updates...**
4. Should show: "You're up to date!"

## 🎯 How Updates Work

1. **On Launch**: App checks `appcast.xml` every 24 hours
2. **If Update Found**: Shows Sparkle dialog with options:
   - Install now
   - Remind me later
   - Skip this version
3. **Installation**: Downloads signed ZIP, verifies, installs, relaunches

## 📦 Release Process

When you merge to `main`:
1. Builds app
2. Creates ZIP + DMG
3. Signs ZIP with EdDSA
4. Updates appcast.xml
5. Commits appcast back to repo
6. Creates GitHub Release

Users automatically get update notifications!

## 📚 Full Documentation

See `SPARKLE_SETUP.md` for complete details.

---

**Ready?** Add the Sparkle package in Xcode, then build! 🎉

