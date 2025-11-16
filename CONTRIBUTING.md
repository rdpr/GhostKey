# Contributing to GhostKey

Thank you for your interest in contributing to GhostKey! This document provides guidelines and information for contributors.

## Code of Conduct

- Be respectful and constructive
- Welcome newcomers and help them learn
- Focus on what is best for the community
- Show empathy towards other community members

## How Can I Contribute?

### Reporting Bugs

Before creating a bug report:
- Check the [Issues](https://github.com/rdpr/GhostKey/issues) to see if the problem has already been reported
- Try to reproduce the issue with the latest version

When creating a bug report, include:
- A clear and descriptive title
- Steps to reproduce the behavior
- Expected vs. actual behavior
- Screenshots if applicable
- Your macOS version and GhostKey version
- Console logs if relevant (Console.app filtered by "GhostKey")

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:
- A clear and descriptive title
- A detailed description of the proposed feature
- Explain why this enhancement would be useful
- List any alternatives you've considered

### Pull Requests

We welcome pull requests! Here's how to contribute code:

## Development Workflow

### Branch Strategy

GhostKey uses a three-branch workflow:

```
dev → beta → main
```

- **`dev`**: Active development, latest features (creates `X.Y.Z-dev.N` releases)
- **`beta`**: Release candidates for testing (creates `X.Y.Z-beta.N` releases)  
- **`main`**: Stable releases only (creates `X.Y.Z` releases)

### Getting Started

1. **Fork the repository**
   ```bash
   # Click "Fork" on GitHub
   git clone https://github.com/YOUR-USERNAME/GhostKey.git
   cd GhostKey
   ```

2. **Create a feature branch from `dev`**
   ```bash
   git checkout dev
   git pull origin dev
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Write clear, readable code
   - Follow the existing code style
   - Add comments for complex logic
   - Test your changes thoroughly

4. **Commit your changes** (see Commit Message Format below)

5. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Open a Pull Request**
   - Target the `dev` branch (not `main`!)
   - Use a conventional commit format for the PR title
   - Fill out the PR template
   - Link any related issues

## Commit Message Format

GhostKey follows the [Conventional Commits](https://www.conventionalcommits.org/) specification for **PR titles** (not individual commits).

### Format

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### PR Title Requirements

**Your PR title MUST follow this format:**

```
<type>(<scope>): <description>
```

- **type**: Required (see types below)
- **scope**: Optional (e.g., `ui`, `auth`, `docs`)
- **description**: Required, lowercase, no period at the end

### Types

- **feat**: A new feature
  - Example: `feat: add dark mode support`
  - Example: `feat(ui): implement new settings panel`
  - Example: `feat!: redesign entire UI` (breaking change)

- **fix**: A bug fix
  - Example: `fix: resolve crash on startup`
  - Example: `fix(auth): correct token validation`
  - Example: `fix(api)!: change response format` (breaking change)

- **docs**: Documentation only changes
  - Example: `docs: update installation guide`
  - Example: `docs(api): add code examples`

- **style**: Code style changes (formatting, missing semi-colons, etc.)
  - Example: `style: fix indentation in PreferencesWindow`

- **refactor**: Code refactoring (neither fixes a bug nor adds a feature)
  - Example: `refactor: extract validation logic to helper`

- **perf**: Performance improvements
  - Example: `perf: optimize file watching`

- **test**: Adding or updating tests
  - Example: `test: add unit tests for CodeStore`

- **chore**: Maintenance tasks, dependency updates
  - Example: `chore: update dependencies`
  - Example: `chore: clean up unused files`

- **ci**: Changes to CI/CD configuration
  - Example: `ci: update release workflow`

- **build**: Changes to build system or external dependencies
  - Example: `build: update Xcode project settings`

- **revert**: Reverting a previous commit
  - Example: `revert: feat: add dark mode support`

### Good Examples

✅ `feat: add keyboard shortcut customization`
✅ `fix: resolve memory leak in FileWatcher`
✅ `docs: update README with new installation steps`
✅ `feat(notifications): implement low-code alerts`
✅ `fix(ui): correct button alignment in preferences`

### Bad Examples

❌ `Added new feature` (not conventional format)
❌ `Fix bug` (too vague)
❌ `feat: Add Dark Mode` (description should be lowercase)
❌ `updated docs` (no type)
❌ `fix: fixed the thing.` (don't end with period)

### Breaking Changes

To indicate a breaking change, add `!` after the type/scope:

```
feat!: complete redesign of preferences UI
fix(api)!: change authentication flow
refactor(core)!: remove deprecated methods
```

The `!` tells users and tooling that this change breaks backward compatibility. Use it when:
- Removing features or APIs
- Changing existing behavior
- Requiring manual migration steps

### Rules

- Use present tense: "add" not "added"
- Use lowercase for description
- Don't end description with a period
- Be concise but descriptive
- First line should be ≤ 72 characters
- Add `!` before `:` for breaking changes

## Automated Workflows

### CHANGELOG Generation

When you open a PR targeting `dev`, `beta`, or `main`:
- The CHANGELOG will be **automatically generated** from your PR title
- A bot will commit the CHANGELOG update to your PR branch
- For major releases, you may want to manually enhance the CHANGELOG with:
  - Breaking changes section
  - Migration guide
  - Detailed feature descriptions

### Release Process

Releases are fully automated:
1. PR is merged to a branch (`dev`, `beta`, or `main`)
2. GitHub Actions automatically:
   - Detects the version and channel
   - Builds and signs the app
   - Creates a release with appropriate suffix
   - Updates the appcast feed
   - Publishes to GitHub Releases

**You don't need to manually create releases or update version numbers—everything is automatic!**

## Version Numbers

### How Automatic Semantic Versioning Works

GhostKey uses **fully automatic semantic versioning** based on conventional commits:

#### Version Calculation

The version is **automatically calculated** from your PR title:

- **`fix:`** → Patch bump (1.2.3 → 1.2.4)
  - Bug fixes, documentation, style changes, refactors
  
- **`feat:`** → Minor bump (1.2.3 → 1.3.0)
  - New features, enhancements
  
- **`!` (breaking)** → Major bump (1.2.3 → 2.0.0)
  - Any type with `!` (e.g., `feat!:`, `fix!:`)
  - Breaking changes, API changes

#### Channel Suffixes

After calculating the semantic version, the workflow adds channel suffixes:

- **`main`**: `1.3.0` (stable, no suffix)
- **`beta`**: `1.3.0-beta.1`, `1.3.0-beta.2`, ... (auto-incremented)
- **`dev`**: `1.3.0-dev.1`, `1.3.0-dev.2`, ... (auto-incremented)

#### Examples

**Starting from version 1.2.3:**

1. Merge `fix: resolve crash` to `dev`
   → Creates `1.2.4-dev.1`

2. Merge `feat: add dark mode` to `dev`
   → Creates `1.3.0-dev.1` (minor bump resets patch)

3. Merge `feat!: redesign UI` to `beta`
   → Creates `2.0.0-beta.1` (major bump resets minor and patch)

#### How It Works

1. **Finds latest stable version** from git tags (e.g., `v1.2.3`)
2. **Analyzes commits** since last release OR **PR title** (for CHANGELOG workflow)
3. **Determines bump level**:
   - Scans for `!` → Major
   - Scans for `feat` → Minor
   - Everything else → Patch
4. **Calculates new version** (e.g., `1.3.0`)
5. **Adds channel suffix** if not main (e.g., `1.3.0-dev.1`)
6. **Auto-increments counter** for dev/beta releases

### No Manual Versioning Needed!

You don't need to update any VERSION file or manage version numbers manually. The system:
- ✅ Automatically determines version bumps from commit types
- ✅ Automatically increments prerelease counters
- ✅ Automatically tags and releases
- ✅ Automatically updates CHANGELOG

Just use the correct commit type in your PR title and the rest is handled automatically!

## Testing

Before submitting a PR:

1. **Build and run the app**
   ```bash
   open GhostKey.xcodeproj
   # Press ⌘R to build and run
   ```

2. **Test your changes**
   - Test the specific feature/fix you're working on
   - Test related functionality to ensure nothing broke
   - Check Console.app for any errors

3. **Test on a clean install** (optional but recommended)
   - Use the reset script from `DEVELOPMENT.md`
   - Install fresh and test

## Code Style

- **Swift**: Follow standard Swift conventions
- **SwiftUI**: Use declarative style, extract views when they get complex
- **Comments**: Add comments for non-obvious logic
- **Naming**: Use descriptive names, avoid abbreviations
- **File organization**: Keep related code together

## PR Review Process

1. **Automated checks** run on your PR:
   - PR title validation (conventional commits format)
   - Build check (ensures the app compiles)
   - CHANGELOG generation

2. **Code review** by maintainers:
   - Code quality and style
   - Functionality and correctness
   - Test coverage
   - Documentation

3. **Squash and merge**:
   - Your PR will be squash-merged (all commits become one)
   - The PR title becomes the commit message
   - This keeps the history clean and generates proper CHANGELOGs

## Questions?

- **Found a bug?** [Open an issue](https://github.com/rdpr/GhostKey/issues/new)
- **Have a question?** [Start a discussion](https://github.com/rdpr/GhostKey/discussions)
- **Want to chat?** Comment on a relevant issue

## License

By contributing to GhostKey, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to GhostKey! 🎉
