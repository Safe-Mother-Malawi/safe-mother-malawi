import 'package:flutter/material.dart';
import '../utils/validators.dart';

/// Widget to display password strength indicator
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final bool showLabel;
  final double height;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.showLabel = true,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final score = Validators.calculatePasswordStrength(password);
    final label = Validators.getPasswordStrengthLabel(score);
    final colorHex = Validators.getPasswordStrengthColor(score);
    final color = Color(int.parse(colorHex.replaceFirst('#', '0xff')));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Strength bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 100,
            minHeight: height,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Strength: $label',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
              Text(
                '$score/100',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

