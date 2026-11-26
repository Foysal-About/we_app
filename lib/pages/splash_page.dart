import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../widgets/common.dart';
import 'onboarding_page.dart';

/// Brief branded splash, then onboarding.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          transitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (_, _, _) => const OnboardingPage(),
          transitionsBuilder: (_, a, _, child) =>
              FadeTransition(opacity: a, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBeige,
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutBack,
          builder: (_, v, child) => Opacity(
            opacity: v.clamp(0, 1),
            child: Transform.scale(scale: 0.8 + 0.2 * v, child: child),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const WeLogo(width: 170),
              const SizedBox(height: 14),
              Text(
                'Build with confidence',
                style: urbanist(16, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
