import 'package:flutter/material.dart';
import 'package:hello_world_flutter/push_to_talk_widget.dart';

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
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
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

  void connect() {
    print('connect()');
    setState(() {
      isConnectingOrConnected = true;
    });
    // Simulate connection delay...
    Future.delayed(const Duration(milliseconds: 1500), () {
      bool success = true;
      if (success) {
        print("Connection established!");
        setState(() {
          isConnected = true;
        });
      } else {
        print("Connection failed!");
        disconnect();
      }
    });
  }

  void disconnect() {
    print('disconnect()');
    setState(() {
      pttState = PttState.disabled;
      isCancelingResponse = false;
      isConnected = false;
      isConnectingOrConnected = false;
    });
  }

  void startPushToTalk() {
    print('startPushToTalk()');
    // Implement your logic to start push-to-talk
    setState(() {
      pttState = PttState.pressed;
    });
  }

  void stopPushToTalk() {
    print('stopPushToTalk()');
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
          Switch(value: isConnected, onChanged: (bool newValue) {
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
