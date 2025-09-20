import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

// ✅ RENAMED: ConfettiWidget → GameConfettiWidget to avoid conflict
class GameConfettiWidget extends StatefulWidget {
  final bool isVisible;
  final VoidCallback? onFinished;

  const GameConfettiWidget({
    Key? key,
    required this.isVisible,
    this.onFinished,
  }) : super(key: key);

  @override
  State<GameConfettiWidget> createState() => _GameConfettiWidgetState();
}

class _GameConfettiWidgetState extends State<GameConfettiWidget> {
  late ConfettiController _controllerCenter;

  @override
  void initState() {
    super.initState();
    _controllerCenter = ConfettiController(duration: const Duration(seconds: 3));
    
    if (widget.isVisible) {
      Future.delayed(Duration.zero, () {
        _controllerCenter.play();
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && widget.onFinished != null) {
            widget.onFinished!();
          }
        });
      });
    }
  }

  @override
  void didUpdateWidget(covariant GameConfettiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isVisible && widget.isVisible) {
      _controllerCenter.play();
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && widget.onFinished != null) {
          widget.onFinished!();
        }
      });
    }
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();
    
    // ✅ Now we can safely use ConfettiWidget from the package
    return ConfettiWidget(
      confettiController: _controllerCenter,
      blastDirectionality: BlastDirectionality.explosive,
      particleDrag: 0.05,
      emissionFrequency: 0.05,
      numberOfParticles: 10,
      gravity: 0.3,
      shouldLoop: false,
      colors: const [
        Colors.green,
        Colors.blue,
        Colors.pink,
        Colors.orange,
        Colors.purple,
      ],
    );
  }
}