# JARVIS 2.0

A Flutter Android assistant starter using an OpenAI-compatible OmniRoute endpoint.

## Included in this milestone
- New Android app identity: `com.jarvisai.jarvis_2_0` (JARVIS 2.0)
- OmniRoute chat connection and secure API-key storage
- English-first system instruction
- Local conversation history (up to 300 messages)
- Local saved memories with basic on-device phrase extraction and a memory manager
- Creation Studio screens outlining video, app and game generation integrations
- Settings screen documenting planned background and wake-word support

## Not yet implemented
Video generation needs a separate compatible video-generation provider/API and is not supplied by an OmniRoute chat-completions endpoint. Continuous wake-word listening and background task execution need Android foreground-service/notification handling, microphone permission, battery-policy testing and device testing. The current build deliberately does not pretend those functions are active; their controls are marked as planned.

## Build
GitHub Actions builds the APK on pushes to `main` or manual workflow dispatch. Download the `jarvis-2-0-release-apk` artifact from a successful run.

## OmniRoute settings
- Base URL: `http://127.0.0.1:20128/v1` when OmniRoute runs on the same Android phone and port.
- Model/combo: your configured OmniRoute combo name, e.g. `Ai`.
- Keep the OmniRoute process running in Termux while using the local endpoint.
