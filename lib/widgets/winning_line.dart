import 'package:flutter/material.dart';

class WinningLine extends StatelessWidget {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  const WinningLine({
    Key? key,
    required this.points,
    this.color = Colors.green,
    this.strokeWidth = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: LinePainter(points: points, color: color, strokeWidth: strokeWidth),
      size: Size.infinite,
    );
  }
}

class LinePainter extends CustomPainter {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  LinePainter({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw line connecting all points
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    
    canvas.drawPath(path, paint);
    
    // Add circles at each point for emphasis
    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    for (final point in points) {
      canvas.drawCircle(point, strokeWidth / 2 + 2, circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) {
    return oldDelegate.points != points || 
           oldDelegate.color != color || 
           oldDelegate.strokeWidth != strokeWidth;
  }
}