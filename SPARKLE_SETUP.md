# Sparkle Auto-Update Setup Guide

This guide will help you add Sparkle framework to GhostKey for automatic updates.

## Step 1: Add Sparkle via Swift Package Manager

1. Open `GhostKey.xcodeproj` in Xcode
2. Select the **GhostKey** project in the navigator (blue icon at the top)
3. Select the **GhostKey** target
4. Go to the **Package Dependencies** tab
5. Click the **+** button at the bottom
6. In the search field, enter: `https://github.com/sparkle-project/Sparkle`
7. Click **Add Package**
8. Select **Sparkle** (not SparkleTestSupport) from the list
9. Click **Add Package**

That's it! Sparkle is now integrated.

## Step 2: Generate EdDSA Keys (Required for Signed Updates)

### Option A: Generate keys locally

```bash
# Install Sparkle tools
brew install sparkle

# Generate keys
generate_keys
```

This will output:
```
A key has been generated and saved in your keychain (SPARKLE_PRIVATE_KEY).

To use the private key in GitHub Actions, copy the value below and add it
as a secret named SPARKLE_PRIVATE_KEY in your repository settings.

Private key:
<YOUR_PRIVATE_KEY>

Public key:
<YOUR_PUBLIC_KEY>
```

### Option B: Let GitHub Actions generate keys automatically

The workflow will automatically generate temporary keys if `SPARKLE_PRIVATE_KEY` is not set. However, **this is not recommended for production** as keys will change with each release.

## Step 3: Add Keys to GitHub Secrets

1. Go to your repository on GitHub
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add two secrets:
   - Name: `SPARKLE_PRIVATE_KEY`, Value: Your private key from Step 2
   - Name: `SPARKLE_PUBLIC_KEY`, Value: Your public key from Step 2

**Important**: Never commit your private key to the repository!

## Step 4: Test the Integration

1. Build and run the app in Xcode (⌘R)
2. Check the console for: `✅ Sparkle updater initialized`
3. Click the menu bar icon → **Check for Updates...**
4. You should see Sparkle's update window (it will say "You're up to date!")

## How It Works

### Automatic Check on Launch
- GhostKey checks for updates automatically when it launches
- Checks happen every 24 hours (configurable in Info.plist)
- Non-intrusive: only notifies if an update is available

### Manual Check
- Users can manually check via **Check for Updates...** menu item
- Shows standard Sparkle UI with options:
  - **Install**: Download and install the update
  - **Remind Me Later**: Check again later
  - **Skip This Version**: Don't prompt for this version again

### Update Flow
1. App queries `appcast.xml` from GitHub
2. Compares current version with latest available
3. If newer version exists, shows update prompt
4. Downloads `.zip` file from GitHub Releases
5. Verifies EdDSA signature (prevents tampering)
6. Installs update and relaunches app

### Release Process (Automated)
When you merge to `main`:
1. GitHub Actions builds the app
2. Creates ZIP and DMG
3. Signs ZIP with EdDSA private key
4. Updates `appcast.xml` with new version info
5. Pushes `appcast.xml` back to repo
6. Creates GitHub Release with distributables

## Configuration (Info.plist)

All settings are already configured in `GhostKey/Info.plist`:

```xml
<key>SUFeedURL</key>
<string>https://raw.githubusercontent.com/rdpr/GhostKey/main/appcast.xml</string>

<key>SUEnableAutomaticChecks</key>
<true/>

<key>SUAllowsAutomaticUpdates</key>
<true/>

<key>SUScheduledCheckInterval</key>
<integer>86400</integer>  <!-- 24 hours -->

<key>SUPublicEDKey</key>
<string>SPARKLE_PUBLIC_KEY_PLACEHOLDER</string>  <!-- Auto-filled by workflow -->
```

## Troubleshooting

### "Module 'Sparkle' not found"
- Make sure you added the package in Step 1
- Clean build folder: Xcode → Product → Clean Build Folder (⇧⌘K)
- Close and reopen Xcode

### Updates not showing
- Check console for Sparkle logs
- Verify `appcast.xml` is accessible at the `SUFeedURL`
- Make sure version number in `VERSION` file is lower than published version

### Signature verification failed
- Ensure the same key pair is used for signing and verification
- Check that `SPARKLE_PUBLIC_KEY` secret matches the private key used for signing
- For testing, you can disable signature verification (not recommended for production)

## User Experience

### First Launch
- No update check (app just installed)
- Automatic check will happen on next launch (24 hours later)

### Update Available
- Small notification window appears
- User can install, skip, or be reminded later
- Non-blocking: app continues to function normally

### Installing Update
- Progress bar shows download status
- App automatically quits and relaunches with new version
- Seamless upgrade experience

## Security

- **EdDSA signatures** prevent malicious updates
- Only signed updates from your GitHub Releases can be installed
- Public key is embedded in app, private key stays secret
- HTTPS ensures update feed isn't tampered with

## Need Help?

- [Sparkle Documentation](https://sparkle-project.org/documentation/)
- [Sparkle GitHub](https://github.com/sparkle-project/Sparkle)
- Check workflow logs in GitHub Actions for signing/appcast errors

