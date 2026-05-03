import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';

enum BadgeType { success, warning, critical, info, neutral }

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;

  const StatusBadge({super.key, required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    final colors = _colors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.$2,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: colors.$1,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  (Color, Color) _colors() {
    switch (type) {
      case BadgeType.success:
        return (AppColors.successText, AppColors.successBg);
      case BadgeType.warning:
        return (AppColors.warningText, AppColors.warningBg);
      case BadgeType.critical:
        return (AppColors.criticalText, AppColors.criticalBg);
      case BadgeType.info:
        return (AppColors.infoText, AppColors.infoBg);
      case BadgeType.neutral:
        return (AppColors.mutedText, AppColors.surfaceContainerLow);
    }
  }
}
