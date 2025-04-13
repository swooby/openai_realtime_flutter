import 'package:flutter/material.dart';
import 'package:hello_world_flutter/home_page_view_model.dart';
import 'package:hello_world_flutter/push_to_talk_widget.dart';
import 'package:openai_realtime_dart/openai_realtime_dart.dart';

//final _log = Logger('home_page');

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomePageViewModel _homePageViewModel = HomePageViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          ValueListenableBuilder<RealtimeConnectionState>(
            valueListenable: _homePageViewModel.connectionState,
            builder: (context, connectionState, child) {
              return Switch(
                value: _homePageViewModel.isConnectingOrConnected,
                onChanged: (bool newValue) async {
                  if (newValue) {
                    await _homePageViewModel.connect();
                  } else {
                    await _homePageViewModel.disconnect();
                  }
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Center(
                child: ValueListenableBuilder<RealtimeConnectionState>(
                  valueListenable: _homePageViewModel.connectionState,
                  builder: (context, connectionState, child) {
                    return PushToTalkWidget(
                      pttState: _homePageViewModel.pttState.value,
                      isConnectingOrConnected:
                          _homePageViewModel.isConnectingOrConnected,
                      isConnected: !_homePageViewModel.isDisconnected,
                      isCancelingResponse:
                          _homePageViewModel.isCancelingResponse,
                      onPushToTalkStart: _homePageViewModel.startPushToTalk,
                      onPushToTalkStop: _homePageViewModel.stopPushToTalk,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
