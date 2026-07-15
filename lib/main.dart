import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const YMixApp());
}

class YMixApp extends StatelessWidget {
  const YMixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Y MIX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}
