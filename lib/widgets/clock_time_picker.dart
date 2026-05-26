import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A clock-based time picker widget that allows users to select time visually
class ClockTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay) onTimeChanged;

  const ClockTimePicker({
    super.key,
    required this.initialTime,
    required this.onTimeChanged,
  });

  @override
  State<ClockTimePicker> createState() => _ClockTimePickerState();
}

class _ClockTimePickerState extends State<ClockTimePicker> {
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Clock display
        Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF1A237E), width: 2),
            color: const Color(0xFFF5F7FF),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Clock face
              CustomPaint(
                size: const Size(280, 280),
                painter: _ClockPainter(_selectedTime),
              ),
              // Center dot
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1A237E),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Time display
        Text(
          _selectedTime.format(context),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E),
          ),
        ),
        const SizedBox(height: 20),
        // Hour and Minute selectors
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hour selector
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_drop_up, size: 28),
                  onPressed: () {
                    setState(() {
                      _selectedTime = _selectedTime.replacing(
                        hour: (_selectedTime.hour + 1) % 24,
                      );
                      widget.onTimeChanged(_selectedTime);
                    });
                  },
                ),
                Text(
                  _selectedTime.hour.toString().padLeft(2, '0'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_drop_down, size: 28),
                  onPressed: () {
                    setState(() {
                      _selectedTime = _selectedTime.replacing(
                        hour: (_selectedTime.hour - 1 + 24) % 24,
                      );
                      widget.onTimeChanged(_selectedTime);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(width: 20),
            const Text(':', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(width: 20),
            // Minute selector
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_drop_up, size: 28),
                  onPressed: () {
                    setState(() {
                      _selectedTime = _selectedTime.replacing(
                        minute: (_selectedTime.minute + 5) % 60,
                      );
                      widget.onTimeChanged(_selectedTime);
                    });
                  },
                ),
                Text(
                  _selectedTime.minute.toString().padLeft(2, '0'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_drop_down, size: 28),
                  onPressed: () {
                    setState(() {
                      _selectedTime = _selectedTime.replacing(
                        minute: (_selectedTime.minute - 5 + 60) % 60,
                      );
                      widget.onTimeChanged(_selectedTime);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Custom painter for the clock face
class _ClockPainter extends CustomPainter {
  final TimeOfDay time;

  _ClockPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Draw clock circle
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Draw hour markers
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * 3.14159 / 180;
      final x1 = center.dx + (radius - 15) * math.cos(angle);
      final y1 = center.dy + (radius - 15) * math.sin(angle);
      final x2 = center.dx + (radius - 5) * math.cos(angle);
      final y2 = center.dy + (radius - 5) * math.sin(angle);

      canvas.drawLine(
        Offset(x1, y1),
        Offset(x2, y2),
        Paint()
          ..color = const Color(0xFF1A237E)
          ..strokeWidth = 2,
      );

      // Draw hour numbers
      final textPainter = TextPainter(
        text: TextSpan(
          text: (i == 0 ? 12 : i).toString(),
          style: const TextStyle(
            color: Color(0xFF1A237E),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      final x = center.dx + (radius - 30) * math.cos(angle) - textPainter.width / 2;
      final y = center.dy + (radius - 30) * math.sin(angle) - textPainter.height / 2;
      textPainter.paint(canvas, Offset(x, y));
    }

    // Draw hour hand
    final hourAngle = ((time.hour % 12) * 30 + time.minute * 0.5 - 90) * 3.14159 / 180;
    final hourX = center.dx + (radius * 0.5) * math.cos(hourAngle);
    final hourY = center.dy + (radius * 0.5) * math.sin(hourAngle);
    canvas.drawLine(
      center,
      Offset(hourX, hourY),
      Paint()
        ..color = const Color(0xFF1A237E)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // Draw minute hand
    final minuteAngle = (time.minute * 6 - 90) * 3.14159 / 180;
    final minuteX = center.dx + (radius * 0.7) * math.cos(minuteAngle);
    final minuteY = center.dy + (radius * 0.7) * math.sin(minuteAngle);
    canvas.drawLine(
      center,
      Offset(minuteX, minuteY),
      Paint()
        ..color = const Color(0xFF3949AB)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ClockPainter oldDelegate) => oldDelegate.time != time;
}
