cask "flowprompt" do
  version "1.0.0"
  sha256 "53f1c67199247672e89562b49fbd382029e7ddea65636c565e1fef786dcb8fc1"

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
