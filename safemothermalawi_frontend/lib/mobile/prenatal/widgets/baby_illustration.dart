import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Shows a real asset image if available, otherwise falls back to painted illustration.
class BabyIllustration extends StatelessWidget {
  final int week;
  final String assetPath;
  final double size;
  final bool cover;

  const BabyIllustration({
    super.key,
    required this.week,
    required this.assetPath,
    this.size = 160,
    this.cover = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: cover ? BoxFit.cover : BoxFit.contain,
        errorBuilder: (_, __, ___) => CustomPaint(
          size: Size(size, size),
          painter: _BabyPainter(week: week),
        ),
      ),
    );
  }
}

/// Public fallback — renders the painted fetal illustration directly.
class BabyFallbackPainter extends StatelessWidget {
  final int week;
  final double size;
  const BabyFallbackPainter({super.key, required this.week, this.size = 190});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _BabyPainter(week: week),
    );
  }
}

// ─── Private painter ─────────────────────────────────────────────────────────

class _BabyPainter extends CustomPainter {
  final int week;
  _BabyPainter({required this.week});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final scale = (week / 40.0).clamp(0.15, 1.0);
    final r = (size.width * 0.18 * scale).clamp(8.0, size.width * 0.18);

    final bodyPaint = Paint()..color = const Color(0xFFFFB6C1);
    final skinPaint = Paint()..color = const Color(0xFFFFCDD2);
    final outlinePaint = Paint()
      ..color = const Color(0xFFE91E8C).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final eyePaint = Paint()..color = const Color(0xFF880E4F);

    if (week <= 6) {
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: r * 2, height: r * 2.5), bodyPaint);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: r * 2, height: r * 2.5), outlinePaint);
    } else if (week <= 12) {
      _drawEarlyFetus(canvas, cx, cy, r, bodyPaint, outlinePaint, eyePaint);
    } else if (week <= 24) {
      _drawMidFetus(canvas, cx, cy, r, bodyPaint, skinPaint, outlinePaint, eyePaint);
    } else {
      _drawLateFetus(canvas, cx, cy, r, bodyPaint, skinPaint, outlinePaint, eyePaint);
    }
  }

  void _drawEarlyFetus(Canvas canvas, double cx, double cy, double r,
      Paint body, Paint outline, Paint eye) {
    canvas.drawCircle(Offset(cx, cy - r * 0.8), r * 0.9, body);
    canvas.drawCircle(Offset(cx, cy - r * 0.8), r * 0.9, outline);
    final path = Path()
      ..moveTo(cx - r * 0.5, cy)
      ..quadraticBezierTo(cx - r * 1.0, cy + r * 1.5, cx, cy + r * 2.0)
      ..quadraticBezierTo(cx + r * 1.0, cy + r * 1.5, cx + r * 0.5, cy)
      ..close();
    canvas.drawPath(path, body);
    canvas.drawPath(path, outline);
    canvas.drawCircle(Offset(cx - r * 0.25, cy - r * 0.9), r * 0.12, eye);
    canvas.drawCircle(Offset(cx + r * 0.25, cy - r * 0.9), r * 0.12, eye);
  }

  void _drawMidFetus(Canvas canvas, double cx, double cy, double r,
      Paint body, Paint skin, Paint outline, Paint eye) {
    canvas.drawCircle(Offset(cx, cy - r * 0.6), r * 0.85, body);
    canvas.drawCircle(Offset(cx, cy - r * 0.6), r * 0.85, outline);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + r * 0.5), width: r * 1.4, height: r * 1.8), skin);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + r * 0.5), width: r * 1.4, height: r * 1.8), outline);
    _drawArm(canvas, cx - r * 0.7, cy + r * 0.2, -0.4, r, body, outline);
    _drawArm(canvas, cx + r * 0.7, cy + r * 0.2, 0.4, r, body, outline);
    _drawLeg(canvas, cx - r * 0.35, cy + r * 1.3, r, body, outline);
    _drawLeg(canvas, cx + r * 0.35, cy + r * 1.3, r, body, outline);
    canvas.drawCircle(Offset(cx - r * 0.28, cy - r * 0.7), r * 0.1, eye);
    canvas.drawCircle(Offset(cx + r * 0.28, cy - r * 0.7), r * 0.1, eye);
    final smilePaint = Paint()
      ..color = const Color(0xFFE91E8C).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy - r * 0.5), width: r * 0.4, height: r * 0.2),
      0, math.pi, false, smilePaint,
    );
  }

  void _drawLateFetus(Canvas canvas, double cx, double cy, double r,
      Paint body, Paint skin, Paint outline, Paint eye) {
    canvas.drawCircle(Offset(cx, cy - r * 0.55), r * 0.9, body);
    canvas.drawCircle(Offset(cx, cy - r * 0.55), r * 0.9, outline);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + r * 0.55), width: r * 1.5, height: r * 2.0), skin);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + r * 0.55), width: r * 1.5, height: r * 2.0), outline);
    _drawArm(canvas, cx - r * 0.75, cy + r * 0.1, -0.5, r, body, outline);
    _drawArm(canvas, cx + r * 0.75, cy + r * 0.1, 0.5, r, body, outline);
    _drawLeg(canvas, cx - r * 0.4, cy + r * 1.4, r, body, outline);
    _drawLeg(canvas, cx + r * 0.4, cy + r * 1.4, r, body, outline);
    canvas.drawCircle(Offset(cx - r * 0.3, cy - r * 0.65), r * 0.11, eye);
    canvas.drawCircle(Offset(cx + r * 0.3, cy - r * 0.65), r * 0.11, eye);
    final smilePaint = Paint()
      ..color = const Color(0xFFE91E8C).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy - r * 0.42), width: r * 0.45, height: r * 0.22),
      0, math.pi, false, smilePaint,
    );
    canvas.drawCircle(Offset(cx - r * 0.5, cy - r * 0.5),
        r * 0.15, Paint()..color = const Color(0xFFFF80AB).withValues(alpha: 0.5));
    canvas.drawCircle(Offset(cx + r * 0.5, cy - r * 0.5),
        r * 0.15, Paint()..color = const Color(0xFFFF80AB).withValues(alpha: 0.5));
  }

  void _drawArm(Canvas canvas, double x, double y, double angle, double r,
      Paint body, Paint outline) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 0.45, height: r * 0.9), body);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 0.45, height: r * 0.9), outline);
    canvas.restore();
  }

  void _drawLeg(Canvas canvas, double x, double y, double r,
      Paint body, Paint outline) {
    canvas.drawOval(Rect.fromCenter(center: Offset(x, y), width: r * 0.55, height: r * 0.9), body);
    canvas.drawOval(Rect.fromCenter(center: Offset(x, y), width: r * 0.55, height: r * 0.9), outline);
  }

  @override
  bool shouldRepaint(_BabyPainter old) => old.week != week;
}
