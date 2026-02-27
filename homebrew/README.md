# Homebrew Tap Setup

This directory contains the Cask file for distributing FlowPrompt via Homebrew.

## How to set up the tap

1. Create a new GitHub repo named `homebrew-flowprompt` under your account
2. Inside that repo, create `Casks/flowprompt.rb` with the contents of `flowprompt.rb` from this directory
3. After pushing a release tag (e.g. `v1.0.0`) to the main FlowPrompt repo, download the `.zip` from the GitHub Release and get its SHA256:
   ```bash
   shasum -a 256 FlowPrompt.zip
   ```
4. Replace `REPLACE_WITH_SHA256_OF_RELEASE_ZIP` in the Cask file with the actual hash
5. Push the Cask file to the `homebrew-flowprompt` repo

Users can then install with:
```bash
brew tap kartikmehra/flowprompt
brew install --cask flowprompt
```

## Updating for new releases

For each new release, update `version` and `sha256` in the Cask file and push to the tap repo.
