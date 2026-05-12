import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class AppIconCreator {
  static Future<void> createIcon() async {
    // Create a custom painter for the icon
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(512, 512);
    
    // Background
    final backgroundPaint = Paint()..color = const Color(0xFF2196F3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(80),
      ),
      backgroundPaint,
    );
    
    // Woman figure
    final figurePaint = Paint()..color = Colors.white;
    
    // Head
    canvas.drawCircle(
      const Offset(256, 180),
      50,
      figurePaint,
    );
    
    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(216, 220, 80, 120),
        const Radius.circular(20),
      ),
      figurePaint,
    );
    
    // Arms
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(186, 240, 20, 70),
        const Radius.circular(10),
      ),
      figurePaint,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(306, 240, 20, 70),
        const Radius.circular(10),
      ),
      figurePaint,
    );
    
    // Baby
    final babyPaint = Paint()..color = const Color(0xFFFFB74D);
    canvas.drawCircle(
      const Offset(276, 270),
      18,
      babyPaint,
    );
    
    // Heart
    final heartPaint = Paint()..color = const Color(0xFFE91E63);
    canvas.drawCircle(const Offset(230, 260), 8, heartPaint);
    canvas.drawCircle(const Offset(242, 260), 8, heartPaint);
    
    // Heart bottom (triangle)
    final heartPath = Path();
    heartPath.moveTo(222, 265);
    heartPath.lineTo(250, 265);
    heartPath.lineTo(236, 280);
    heartPath.close();
    canvas.drawPath(heartPath, heartPaint);
    
    // Convert to image
    final picture = recorder.endRecording();
    final img = await picture.toImage(512, 512);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();
    
    // Save to file
    final file = File('assets/images/app_icon.png');
    await file.writeAsBytes(pngBytes);
    
    print('✅ App icon created: ${file.path}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppIconCreator.createIcon();
}