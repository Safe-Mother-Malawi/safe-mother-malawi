import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class ClinicianConsultPage extends StatelessWidget {
  const ClinicianConsultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('New Consultation', style: TextStyle(fontSize: 24, color: AppColors.g800)),
    );
  }
}
