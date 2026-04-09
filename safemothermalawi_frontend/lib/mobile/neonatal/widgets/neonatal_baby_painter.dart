import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Draws a simple swaddled newborn baby illustration as a fallback
/// when no real photo is available.
class NeonatalBabyPainter extends StatelessWidget {
  final double size;
  const NeonatalBabyPainter({super.key, this.size = 170});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BabyPainter()),
    );
  }
}

class _BabyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    // ── Swaddle body ─────────────────────────────────────────────────────────
    final swaddlePaint = Paint()..color = const Color(0xFFB3E5FC);
    final swaddleRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, size.height * 0.68),
        width: size.width * 0.72,
        height: size.height * 0.52,
      ),
      const Radius.circular(999),
    );
    canvas.drawRRect(swaddleRect, swaddlePaint);

    // Swaddle fold lines
    final foldPaint = Paint()
      ..color = const Color(0xFF81D4FA)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx, size.height * 0.57),
        width: size.width * 0.55,
        height: size.height * 0.18,
      ),
      math.pi * 0.15,
      math.pi * 0.7,
      false,
      foldPaint,
    );

    // ── Head ─────────────────────────────────────────────────────────────────
    final headPaint = Paint()..color = const Color(0xFFFFCBA4);
    canvas.drawCircle(
      Offset(cx, size.height * 0.34),
      size.width * 0.26,
      headPaint,
    );

    // Cheeks
    final cheekPaint = Paint()..color = const Color(0xFFFFAB91).withValues(alpha: 0.55);
    canvas.drawCircle(Offset(cx - size.width * 0.14, size.height * 0.37), size.width * 0.07, cheekPaint);
    canvas.drawCircle(Offset(cx + size.width * 0.14, size.height * 0.37), size.width * 0.07, cheekPaint);

    // Eyes (closed — sleeping baby)
    final eyePaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final eyeY = size.height * 0.33;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx - size.width * 0.1, eyeY), width: 12, height: 8),
      math.pi, math.pi, false, eyePaint,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx + size.width * 0.1, eyeY), width: 12, height: 8),
      math.pi, math.pi, false, eyePaint,
    );

    // Smile
    final smilePaint = Paint()
      ..color = const Color(0xFFBF360C)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx, size.height * 0.39),
        width: size.width * 0.12,
        height: size.height * 0.06,
      ),
      0,
      math.pi,
      false,
      smilePaint,
    );

    // Nose dot
    final nosePaint = Paint()..color = const Color(0xFFBF360C).withValues(alpha: 0.4);
    canvas.drawCircle(Offset(cx, size.height * 0.36), 2.5, nosePaint);

    // Hair wisps
    final hairPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final hairPath = Path()
      ..moveTo(cx - 6, size.height * 0.10)
      ..quadraticBezierTo(cx - 10, size.height * 0.06, cx - 4, size.height * 0.08)
      ..moveTo(cx, size.height * 0.09)
      ..quadraticBezierTo(cx, size.height * 0.04, cx + 3, size.height * 0.07)
      ..moveTo(cx + 6, size.height * 0.10)
      ..quadraticBezierTo(cx + 10, size.height * 0.06, cx + 4, size.height * 0.08);
    canvas.drawPath(hairPath, hairPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
