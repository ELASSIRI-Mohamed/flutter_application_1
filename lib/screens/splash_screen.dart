import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ✅ FIXED: Use relative import instead of package


class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();

    // Navigate to home screen after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      // ✅ FIXED: Guard against dead context
      if (!mounted) return;
      context.go('/home');
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              // ✅ FIXED: withOpacity → withAlpha
              Theme.of(context).colorScheme.primary.withAlpha((255 * 0.2).round()),
              // ✅ FIXED: background → surface
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Icon(
                      Icons.grid_3x3,
                      size: 100,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              AnimatedOpacity(
                opacity: _animationController.value,
                duration: const Duration(milliseconds: 1000),
                child: Text(
                  'Tic Tac Toe',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    // ✅ FIXED: onBackground → onSurface
                    color: Theme.of(context).colorScheme.onSurface,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              AnimatedOpacity(
                opacity: _animationController.value * 0.7,
                duration: const Duration(milliseconds: 1200),
                child: Text(
                  'X O Game',
                  style: TextStyle(
                    fontSize: 18,
                    // ✅ FIXED: onBackground → onSurface
                    color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.7).round()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}