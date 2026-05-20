import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Utility to create a programmatic logo
class LogoCreator {
  static Widget createSafeMotherLogo({
    double size = 200,
    bool darkBackground = false,
  }) {
    return CustomPaint(
      size: Size(size, size),
      painter: SafeMotherLogoPainter(darkBackground: darkBackground),
    );
  }
}

class SafeMotherLogoPainter extends CustomPainter {
  final bool darkBackground;
  
  SafeMotherLogoPainter({required this.darkBackground});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;
    
    // Background circle
    final bgPaint = Paint()
      ..color = darkBackground 
          ? Colors.white.withOpacity(0.9)
          : const Color(0xFFE91E8C).withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, bgPaint);
    
    // Border circle
    final borderPaint = Paint()
      ..color = darkBackground ? Colors.white : const Color(0xFFE91E8C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawCircle(center, radius, borderPaint);
    
    // Heart shape in center
    final heartPaint = Paint()
      ..color = darkBackground ? const Color(0xFFE91E8C) : const Color(0xFFE91E8C)
      ..style = PaintingStyle.fill;
    
    _drawHeart(canvas, center, radius * 0.5, heartPaint);
    
    // Mother and baby silhouette
    final silhouettePaint = Paint()
      ..color = darkBackground ? Colors.white70 : const Color(0xFFE91E8C).withOpacity(0.7)
      ..style = PaintingStyle.fill;
    
    _drawMotherBabySilhouette(canvas, center, radius * 0.3, silhouettePaint);
  }
  
  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    
    // Heart shape using bezier curves
    path.moveTo(center.dx, center.dy + size * 0.3);
    
    // Left curve
    path.cubicTo(
      center.dx - size * 0.5, center.dy - size * 0.1,
      center.dx - size * 0.5, center.dy - size * 0.5,
      center.dx, center.dy - size * 0.2,
    );
    
    // Right curve
    path.cubicTo(
      center.dx + size * 0.5, center.dy - size * 0.5,
      center.dx + size * 0.5, center.dy - size * 0.1,
      center.dx, center.dy + size * 0.3,
    );
    
    canvas.drawPath(path, paint);
  }
  
  void _drawMotherBabySilhouette(Canvas canvas, Offset center, double size, Paint paint) {
    // Simple mother figure
    canvas.drawCircle(
      Offset(center.dx - size * 0.2, center.dy - size * 0.8), 
      size * 0.15, 
      paint
    );
    
    // Mother body
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - size * 0.2, center.dy - size * 0.4),
        width: size * 0.3,
        height: size * 0.6,
      ),
      paint,
    );
    
    // Baby figure
    canvas.drawCircle(
      Offset(center.dx + size * 0.3, center.dy - size * 0.6), 
      size * 0.1, 
      paint
    );
    
    // Baby body
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + size * 0.3, center.dy - size * 0.3),
        width: size * 0.2,
        height: size * 0.4,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

