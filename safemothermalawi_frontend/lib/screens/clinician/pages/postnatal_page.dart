import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class ClinicianNeonatalPage extends StatelessWidget {
  const ClinicianNeonatalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Neonatal Visits', style: TextStyle(fontSize: 24, color: AppColors.g800)),
    );
  }
}
