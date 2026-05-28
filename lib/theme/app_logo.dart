import 'package:flutter/material.dart';

/// Centralized Logo Component
/// Used across web, mobile, and all modules
/// Supports multiple sizes and themes
class AppLogoWidget extends StatelessWidget {
  final double size;
  final bool darkBackground;
  final bool showText;
  final TextStyle? textStyle;

  const AppLogoWidget({
    super.key,
    this.size = 80,
    this.darkBackground = false,
    this.showText = false,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final asset = darkBackground ? 'assets/logo/LOGO5.png' : 'assets/logo/LOGO6.png';
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          asset,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              _TextLogo(size: size, darkBackground: darkBackground),
        ),
        if (showText) ...[
          const SizedBox(height: 8),
          _LogoText(
            darkBackground: darkBackground,
            textStyle: textStyle,
          ),
        ],
      ],
    );
  }
}

/// Logo with text (for headers)
class AppLogoWithText extends StatelessWidget {
  final double logoSize;
  final bool darkBackground;
  final double spacing;
  final TextStyle? textStyle;

  const AppLogoWithText({
    super.key,
    this.logoSize = 50,
    this.darkBackground = false,
    this.spacing = 12,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLogoWidget(
          size: logoSize,
          darkBackground: darkBackground,
        ),
        SizedBox(width: spacing),
        _LogoText(
          darkBackground: darkBackground,
          textStyle: textStyle,
        ),
      ],
    );
  }
}

/// Logo text component
class _LogoText extends StatelessWidget {
  final bool darkBackground;
  final TextStyle? textStyle;

  const _LogoText({
    required this.darkBackground,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Safe Mother',
          style: textStyle ??
              TextStyle(
                color: darkBackground ? Colors.white : const Color(0xFF1A237E),
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
        ),
        Text(
          'Malawi',
          style: TextStyle(
            color: darkBackground
                ? Colors.white70
                : const Color(0xFF1A237E).withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

/// Fallback text logo
class _TextLogo extends StatelessWidget {
  final double size;
  final bool darkBackground;

  const _TextLogo({
    required this.size,
    required this.darkBackground,
  });

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
                ? Colors.white.withOpacity(0.15)
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

/// Logo sizes preset
class LogoSize {
  static const double small = 40;
  static const double medium = 60;
  static const double large = 80;
  static const double extraLarge = 120;
  static const double header = 50;
  static const double sidebar = 40;
  static const double splash = 150;
}
