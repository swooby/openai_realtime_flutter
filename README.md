# hello_world_flutter

A Hello World OpenAI Realtime (via WebRTC) Flutter project

Initially created 2025/03/18 following the guide at:
https://docs.flutter.dev/get-started/install/macos/mobile-android

Then add:
* https://github.com/flutter-webrtc/flutter-webrtc
  `flutter pub add flutter_webrtc`
* https://github.com/davidmigloz/langchain_dart/tree/main/packages/openai_realtime_dart
  `flutter pub add openai_realtime_dart`

My plan if for this to be a very light weight version of:
* https://github.com/swooby/AlfredAI
That is a non-trivial Android(Mobile) + Wear(Watch) remote control app that
uses a Foreground service to run in the background.

This app is planned to be much simpler, more similar to:
* https://github.com/swooby/openai-realtime-push-to-talk/
That is just a fairly simple web app that uses WebRTC to connect and use
OpenAI Realtime. 
