# Generate Sparkle Keys - Quick Guide

The GitHub Actions workflow cannot automatically generate Sparkle keys because the `generate_keys` tool isn't available in the Homebrew formula. You need to generate them locally and add to GitHub Secrets.

## Steps

### 1. Install Sparkle locally

```bash
brew install sparkle
```

### 2. Download Sparkle's command-line tools

The Homebrew formula doesn't include the CLI tools. Download them from Sparkle's GitHub releases:

```bash
# Download latest Sparkle (2.x)
curl -L https://github.com/sparkle-project/Sparkle/releases/latest/download/Sparkle-for-Swift-Package-Manager.zip -o sparkle.zip

# Extract
unzip sparkle.zip

# The generate_keys tool should be in: Sparkle.framework/Versions/B/Resources/
find . -name "generate_keys"
```

### 3. Generate keys

```bash
# Run generate_keys (adjust path based on where you found it)
./Sparkle.framework/Versions/B/Resources/generate_keys

# Or try this alternative location:
./bin/generate_keys
```

This will output something like:

```
A key has been generated and saved in your keychain.

Private key:
ABC123XYZ...your private key here...

Public key:
DEF456UVW...your public key here...
```

### 4. Add keys to GitHub Secrets

1. Go to your repository on GitHub
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add two secrets:

   **Secret 1:**
   - Name: `SPARKLE_PRIVATE_KEY`
   - Value: [paste your private key]

   **Secret 2:**
   - Name: `SPARKLE_PUBLIC_KEY`
   - Value: [paste your public key]

### 5. Trigger a new release

Once the secrets are added, the next release will:
- ✅ Use your keys from GitHub Secrets
- ✅ Sign the ZIP file
- ✅ Inject public key into Info.plist
- ✅ Enable automatic updates with signature verification

## Alternative: Use Python script

If you can't find `generate_keys`, you can use Python to generate EdDSA keys:

```bash
# Install required package
pip3 install PyNaCl

# Generate keys
python3 << 'EOF'
import nacl.signing
import base64

# Generate a new key pair
signing_key = nacl.signing.SigningKey.generate()
verify_key = signing_key.verify_key

# Convert to base64 (Sparkle format)
private_key = base64.b64encode(signing_key._signing_key).decode('utf-8')
public_key = base64.b64encode(verify_key._key).decode('utf-8')

print("\nPrivate key (add to SPARKLE_PRIVATE_KEY secret):")
print(private_key)
print("\nPublic key (add to SPARKLE_PUBLIC_KEY secret):")
print(public_key)
EOF
```

## Verification

After adding the secrets and creating a new release:

1. Check the GitHub Actions logs for: `✅ Using keys from GitHub Secrets`
2. Look for: `✅ Public key successfully injected and verified`
3. Download the release DMG/ZIP
4. Open the app and click **Check for Updates...**
5. Should see Sparkle's update check dialog (not the "development build" message)

## Troubleshooting

**Keys not working?**
- Make sure there are no extra spaces/newlines when pasting into GitHub Secrets
- Keys should be long base64 strings (typically 43-44 characters)
- Private and public keys must be from the same key pair

**Still showing "development build" message?**
- Check that public key was injected: Download the DMG, extract GhostKey.app, and run:
  ```bash
  /usr/libexec/PlistBuddy -c "Print :SUPublicEDKey" GhostKey.app/Contents/Info.plist
  ```
- Should print your public key, not an error

## Need Help?

- [Sparkle Documentation](https://sparkle-project.org/documentation/)
- [Sparkle Signing Updates Guide](https://sparkle-project.org/documentation/signing/)

