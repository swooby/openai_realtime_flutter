import 'package:flutter/material.dart';
import 'package:hello_world_flutter/push_to_talk_widget.dart';
import 'package:logging/logging.dart';
import 'package:openai_realtime_dart/openai_realtime_dart.dart';

final _log = Logger('main');

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      themeMode: ThemeMode.dark,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PttState pttState = PttState.disabled;
  bool isConnectingOrConnected = false;
  bool isConnected = false;
  bool isCancelingResponse = false;

  RealtimeClient? client;

  _MyHomePageState() {
    _tryInitializeRealtimeClient();
  }

  void _tryInitializeRealtimeClient() async {
    const String openaiApiKey = String.fromEnvironment('OPENAI_API_KEY');
    _log.info('_tryInitializeRealtimeClient: openaiApiKey: "$openaiApiKey"');
    client = RealtimeClient(
      transportType: RealtimeTransportType.webrtc,
      apiKey: openaiApiKey,
      debug: true,
    );
    await client!.updateSession(
      turnDetection: TurnDetection(
        type: TurnDetectionType.serverVad,
      ),
      inputAudioTranscription: InputAudioTranscriptionConfig(
        model: 'whisper-1',
      ),
    );
    client!.on(RealtimeEventType.all, (event) {
      switch (event.type) {
        case RealtimeEventType.sessionCreated:
          setState(() {
            isConnected = true;
          });
          break;
        default:
          // ignore
          break;
      }
    });
  }

  Future<void> connect() async {
    _log.info('connect()');
    setState(() {
      isConnectingOrConnected = true;
    });
    // Simulate connection delay...
    final client = this.client;
    if (client != null) {
      _log.info('connect: Real attempt to connect...');
      await client.connect();
    } else {
      _log.info('connect: Simulate connection...');
      Future.delayed(const Duration(milliseconds: 1500), () {
        bool success = true;
        if (success) {
          _log.info("Connection established!");
          setState(() {
            isConnected = true;
          });
        } else {
          _log.info("Connection failed!");
          disconnect();
        }
      });
    }
  }

  void disconnect() {
    _log.info('disconnect()');
    client?.disconnect();
    setState(() {
      pttState = PttState.disabled;
      isCancelingResponse = false;
      isConnected = false;
      isConnectingOrConnected = false;
    });
  }

  void startPushToTalk() {
    _log.info('startPushToTalk()');
    // Implement your logic to start push-to-talk
    setState(() {
      pttState = PttState.pressed;
    });
  }

  void stopPushToTalk() {
    _log.info('stopPushToTalk()');
    // Implement your logic to stop push-to-talk
    setState(() {
      pttState = PttState.idle;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          Switch(value: isConnectingOrConnected, onChanged: (bool newValue) {
            if (newValue) {
              connect();
            } else {
              disconnect();
            }
          })
        ],
      ),
      body: Center(
        child: Column(
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            PushToTalkWidget(
              pttState: pttState,
              isConnectingOrConnected: isConnectingOrConnected,
              isConnected: isConnected,
              isCancelingResponse: isCancelingResponse,
              onPushToTalkStart: startPushToTalk,
              onPushToTalkStop: stopPushToTalk,
            ),
          ],
        ),
      ),
    );
  }
}
