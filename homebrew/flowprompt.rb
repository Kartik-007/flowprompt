cask "flowprompt" do
  version "1.0.0"
  sha256 "REPLACE_WITH_SHA256_OF_RELEASE_ZIP"

  url "https://github.com/kartikmehra/FlowPrompt/releases/download/v#{version}/FlowPrompt.zip"
  name "FlowPrompt"
  desc "Lightweight macOS menu bar app for storing and pasting prompts"
  homepage "https://github.com/kartikmehra/FlowPrompt"

  depends_on macos: ">= :ventura"

  app "FlowPrompt.app"

  zap trash: [
    "~/.flowprompt",
  ]
end
