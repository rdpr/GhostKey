# Release Process

This document describes how to create a new release of GhostKey.

## Automated Releases

GhostKey uses GitHub Actions to automatically build and release the app when code is merged to `main`.

### How It Works

1. **Merge to main**: When you merge a PR to the `main` branch
2. **Version check**: The workflow reads the version from the `VERSION` file
3. **Tag check**: If the version tag doesn't exist yet, it proceeds
4. **Build**: The app is built using Xcode on macOS
5. **Package**: Creates both `.dmg` and `.zip` distributables
6. **Release**: Creates a GitHub release with the version tag
7. **Artifacts**: Uploads the distributables with SHA256 checksums

### Creating a New Release

1. **Update the version** in the `VERSION` file:
   ```bash
   echo "1.1.0" > VERSION
   ```

2. **Update CHANGELOG.md** with the new version and changes:
   ```markdown
   ## [1.1.0] - 2025-01-15
   
   ### Added
   - New feature X
   - New feature Y
   
   ### Fixed
   - Bug fix Z
   ```

3. **Commit and push** to your branch:
   ```bash
   git add VERSION CHANGELOG.md
   git commit -m "Bump version to 1.1.0"
   git push
   ```

4. **Create and merge** a pull request to `main`

5. **Wait for the workflow** to complete (check the Actions tab)

6. **Verify the release** at `https://github.com/rdpr/ghostkey/releases`

### Version Numbering

We follow [Semantic Versioning](https://semver.org/):

- **Major** (1.x.x): Breaking changes
- **Minor** (x.1.x): New features (backward compatible)
- **Patch** (x.x.1): Bug fixes (backward compatible)

### Skipping Releases

The workflow automatically skips if:
- The version tag already exists
- Only documentation files are changed (`.md`, `LICENSE`, `.gitignore`)

### Manual Releases

If you need to create a release manually:

1. Build the app in Xcode (Product → Archive)
2. Export the app
3. Create DMG and ZIP manually
4. Create a GitHub release manually
5. Upload the artifacts

## Troubleshooting

### Workflow fails at build step
- Check Xcode version compatibility
- Verify the project builds locally
- Check GitHub Actions logs for details

### Tag already exists
- Update the `VERSION` file to a new version
- Or delete the existing tag if it was created in error:
  ```bash
  git tag -d v1.0.0
  git push origin :refs/tags/v1.0.0
  ```

### DMG creation fails
- The workflow has a fallback to create a simple DMG
- Check if the app was built successfully
- Verify the app icon paths are correct

## Security Note

The automated builds are **not code-signed** because that requires Apple Developer certificates. Users will need to:
1. Right-click the app and select "Open" on first launch
2. Or build from source themselves

To add code signing:
1. Add your certificate to GitHub Secrets
2. Update the workflow to include code signing steps
3. Add notarization if distributing outside the App Store

