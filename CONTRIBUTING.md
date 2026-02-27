# Contributing to FlowPrompt

Thanks for your interest in contributing! This guide will help you get started.

## Code of Conduct

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Getting Started

### Prerequisites

- macOS 13.0 (Ventura) or later
- Xcode 15+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

### Setup

1. Fork the repository on GitHub
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/FlowPrompt.git
   cd FlowPrompt
   ```
3. Generate the Xcode project:
   ```bash
   xcodegen generate
   ```
4. Open in Xcode:
   ```bash
   open FlowPrompt.xcodeproj
   ```
5. Build and run with `Cmd+R`

### Accessibility Permission

FlowPrompt requires Accessibility permission for auto-paste and text capture. On first run, grant it via **System Settings > Privacy & Security > Accessibility > FlowPrompt**.

## Making Changes

1. Create a branch from `main`:
   ```bash
   git checkout -b your-feature-name
   ```
2. Make your changes
3. Test thoroughly on macOS 13+
4. Commit with a clear message:
   ```bash
   git commit -m "Add: brief description of what changed"
   ```
5. Push to your fork:
   ```bash
   git push origin your-feature-name
   ```
6. Open a Pull Request against `main`

## Pull Request Guidelines

- Keep PRs focused — one feature or fix per PR
- Include a clear description of what changed and why
- Test on macOS 13+ before submitting
- Update the README if your change affects user-facing behavior
- Fill out the PR template completely

## Reporting Bugs

Use the [bug report template](https://github.com/kartikmehra/FlowPrompt/issues/new?template=bug_report.md) and include:

- macOS version
- FlowPrompt version
- Steps to reproduce
- Expected vs. actual behavior

## Suggesting Features

Use the [feature request template](https://github.com/kartikmehra/FlowPrompt/issues/new?template=feature_request.md). Describe the problem you're solving, not just the solution you want.

## Code Style

- Follow standard Swift conventions
- Use meaningful variable and function names
- Keep functions short and focused
- Prefer SwiftUI views over AppKit where possible

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
