import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'pages/splash_page.dart';

void main() {
  runApp(const MyApp());
}

final messengerKey = GlobalKey<ScaffoldMessengerState>();

/// Clears any floating message when the user moves to another page so it
/// never covers a primary button there.
class _ClearMessages extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      messengerKey.currentState?.clearSnackBars();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      messengerKey.currentState?.clearSnackBars();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WE',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: messengerKey,
      navigatorObservers: [_ClearMessages()],
      theme: buildTheme(),
      home: const SplashPage(),
    );
  }
}
