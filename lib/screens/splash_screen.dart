import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/session.dart';
import '../widgets/ymix_logo.dart';
import 'auth/login_screen.dart';
import 'chats/chat_list_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Session.instance.load();
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => Session.instance.isLoggedIn
            ? const ChatListScreen()
            : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: const Center(child: YMixLogo(fontSize: 44)),
    );
  }
}
