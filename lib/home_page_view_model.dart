import 'package:flutter/material.dart';
import 'package:hello_world_flutter/push_to_talk_widget.dart';
import 'package:logging/logging.dart';
import 'package:openai_realtime_dart/openai_realtime_dart.dart';
import 'package:permission_handler/permission_handler.dart';

final _log = Logger('home_page_view_model');

class HomePageViewModel {
  final pttState = ValueNotifier<PttState>(PttState.disabled);
  final connectionState = ValueNotifier<RealtimeConnectionState>(
    RealtimeConnectionState.disconnected,
  );

  /// Check if the transport is disconnected
  bool get isDisconnected =>
      connectionState.value == RealtimeConnectionState.disconnected;

  /// Check if the transport is connecting or connected (ie: not disconnected)
  bool get isConnectingOrConnected => !isDisconnected;

  /// Check if the transport data channel is opened
  bool get isDataChannelOpened =>
      connectionState.value == RealtimeConnectionState.dataChannelOpened;

  bool isCancelingResponse = false;

  RealtimeClient? client;

  Future<bool> _tryInitRealtimeClient() async {
    final micPermission = await Permission.microphone.request();
    if (micPermission.isDenied) {
      _log.warning('Microphone permission denied');
      return false;
    }

    const String openaiApiKey = String.fromEnvironment('OPENAI_API_KEY');
    //_log.info('_tryInitializeRealtimeClient: openaiApiKey: "$openaiApiKey"');

    client = RealtimeClient(
      transportType: RealtimeTransportType.webrtc,
      apiKey: openaiApiKey,
      debug: true,
    );
    await client!.updateSession(
      turnDetection: TurnDetection(type: TurnDetectionType.serverVad),
      inputAudioTranscription: InputAudioTranscriptionConfig(
        model: 'whisper-1',
      ),
    );
    client!.on(RealtimeEventType.all, (event) {
      switch (event.type) {
        case RealtimeEventType.sessionCreated:
          connectionState.value = RealtimeConnectionState.connected;
          break;
        default:
          // ignore
          break;
      }
    });

    return true;
  }

  Future<void> connect() async {
    _log.info('connect()');
    if (isConnectingOrConnected) {
      _log.info('connect: Already connecting or connected');
      return;
    }
    if (client == null && !(await _tryInitRealtimeClient())) {
      _log.warning(
        'connect: tryInitializeRealtimeClient() return false; not connecting',
      );
      return;
    }
    _log.info('connect: Attempting to connect...');
    if (await client!.connect()) {
      connectionState.value = RealtimeConnectionState.connecting;
    }
  }

  Future<void> disconnect() async {
    _log.info('disconnect()');
    await client?.disconnect();
    pttState.value = PttState.disabled;
    connectionState.value = RealtimeConnectionState.disconnected;
  }

  void startPushToTalk() async {
    _log.info('startPushToTalk()');
    await pushToTalk(true);
    pttState.value = PttState.pressed;
  }

  void stopPushToTalk() async {
    _log.info('stopPushToTalk()');
    await pushToTalk(false);
    pttState.value = PttState.idle;
  }

  Future<void> pushToTalk(bool enable) async {
    _log.info('pushToTalk($enable)');
    if (enable) {
      // js muteSpeaker();
      // js interruptAssistant();
      await client?.send(
        RealtimeEvent.inputAudioBufferClear(
          eventId: RealtimeUtils.generateId(),
        ),
      );
      // js microphoneStream.current.enabled = true;
    } else {
      // js microphoneStream.current.enabled = false;
      await client?.send(
        RealtimeEvent.inputAudioBufferCommit(
          eventId: RealtimeUtils.generateId(),
        ),
      );
      await client?.send(
        RealtimeEvent.responseCreate(eventId: RealtimeUtils.generateId()),
      );
    }
  }
}
