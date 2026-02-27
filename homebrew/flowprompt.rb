cask "flowprompt" do
  version "1.0.0"
  sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"

  url "https://github.com/Kartik-007/FlowPrompt/releases/download/v#{version}/FlowPrompt.zip"
  name "FlowPrompt"
  desc "Lightweight macOS menu bar app for storing and pasting prompts"
  homepage "https://github.com/Kartik-007/FlowPrompt"

  depends_on macos: ">= :ventura"

  app "FlowPrompt.app"

  zap trash: [
    "~/.flowprompt",
  ]
end
