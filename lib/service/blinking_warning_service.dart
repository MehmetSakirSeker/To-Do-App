import 'package:flutter/material.dart';

class BlinkingWarning extends StatefulWidget {
  const BlinkingWarning({super.key});

  @override
  State<BlinkingWarning> createState() => _BlinkingWarningState();
}

class _BlinkingWarningState extends State<BlinkingWarning>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
    );
  }
}
