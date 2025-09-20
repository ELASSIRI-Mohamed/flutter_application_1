import 'package:flutter/material.dart';

class AnimatedXO extends StatefulWidget {
  final String? symbol;
  final bool isActive;
  final VoidCallback? onTap;
  final bool isWinningCell;

  const AnimatedXO({
    Key? key,
    this.symbol,
    this.isActive = false,
    this.onTap,
    this.isWinningCell = false,
  }) : super(key: key);

  @override
  State<AnimatedXO> createState() => _AnimatedXOState();
}

class _AnimatedXOState extends State<AnimatedXO> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.symbol != null) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedXO oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.symbol != widget.symbol && widget.symbol != null) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.symbol == null ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.symbol != null ? _scaleAnimation.value : 1.0,
            child: Opacity(
              opacity: widget.symbol != null ? _opacityAnimation.value : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.isWinningCell 
                      ? Theme.of(context).colorScheme.primary.withAlpha((255 * 0.2).round())
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: widget.symbol != null
                      ? Text(
                          widget.symbol!,
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.shortestSide * 0.12,
                            fontWeight: FontWeight.bold,
                            color: widget.symbol == 'X' 
                                ? Theme.of(context).colorScheme.error 
                                : Theme.of(context).colorScheme.primary,
                          ),
                        )
                      : widget.isActive
                          ? Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.3).round()),
                              ),
                            )
                          : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}