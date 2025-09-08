import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A widget that provides a subtle pattern background
class PatternBackground extends StatelessWidget {
  const PatternBackground({
    super.key,
    required this.child,
    this.patternType = PatternType.grid,
    this.patternOpacity = 0.03,
  });

  final Widget child;
  final PatternType patternType;
  final double patternOpacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: CustomPaint(
        painter: PatternPainter(
          patternType: patternType,
          opacity: patternOpacity,
        ),
        child: child,
      ),
    );
  }
}

/// Types of patterns available
enum PatternType {
  grid,
  dots,
  diagonal,
  none,
}

/// Custom painter for drawing patterns
class PatternPainter extends CustomPainter {
  PatternPainter({
    required this.patternType,
    required this.opacity,
  });

  final PatternType patternType;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (patternType == PatternType.none) return;

    final paint = Paint()
      ..color = AppColors.onBackground.withValues(alpha: opacity)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    switch (patternType) {
      case PatternType.grid:
        _drawGrid(canvas, size, paint);
        break;
      case PatternType.dots:
        _drawDots(canvas, size, paint);
        break;
      case PatternType.diagonal:
        _drawDiagonal(canvas, size, paint);
        break;
      case PatternType.none:
        break;
    }
  }

  void _drawGrid(Canvas canvas, Size size, Paint paint) {
    const double spacing = 20.0;
    
    // Draw vertical lines
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  void _drawDots(Canvas canvas, Size size, Paint paint) {
    const double spacing = 15.0;
    paint.style = PaintingStyle.fill;
    
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  void _drawDiagonal(Canvas canvas, Size size, Paint paint) {
    const double spacing = 20.0;
    paint.style = PaintingStyle.stroke;
    
    // Draw diagonal lines at 45 degrees
    for (double i = -size.height; i <= size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
