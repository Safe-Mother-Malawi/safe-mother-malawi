import 'package:flutter/material.dart';

/// App logo — always clipped to a perfect circle.
/// On dark backgrounds pass darkBackground: true for the text fallback colours.
class AppLogo extends StatelessWidget {
  final double size;
  final bool darkBackground;

  const AppLogo({super.key, this.size = 80, this.darkBackground = false});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        'assets/baby/logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _TextLogo(size: size, darkBackground: darkBackground),
      ),
    );
  }
}

class _TextLogo extends StatelessWidget {
  final double size;
  final bool darkBackground;
  const _TextLogo({required this.size, required this.darkBackground});

  @override
  Widget build(BuildContext context) {
    final fontSize = size * 0.28;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: darkBackground
                ? Colors.white.withValues(alpha: 0.15)
                : const Color(0xFFFCE4EC),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.favorite,
            size: size * 0.45,
            color: darkBackground ? Colors.white : const Color(0xFFE91E8C),
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Safe',
                style: TextStyle(
                  color: darkBackground ? Colors.white : const Color(0xFFE91E8C),
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: 'Mother',
                style: TextStyle(
                  color: darkBackground
                      ? const Color(0xFFFFCDD2)
                      : const Color(0xFFFF80AB),
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
