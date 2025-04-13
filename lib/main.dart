import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hello_world_flutter/home_page.dart';
import 'package:logging/logging.dart';

final _debug = kDebugMode || true;
final _log = Logger('main');

void _loggingInit() {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    if (_debug && record.level >= Logger.root.level) {
      // ignore: avoid_print
      print('${record.loggerName}: ${record.message} ${record.error ?? ""}');
    }
  });
}

void main() {
  _loggingInit();
  _log.info('+main()');
  runApp(const MyApp());
  _log.info('-main()');
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
      home: const HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
