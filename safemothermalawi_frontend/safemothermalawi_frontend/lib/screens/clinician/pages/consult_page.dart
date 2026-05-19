import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class ClinicianConsultPage extends StatelessWidget {
  const ClinicianConsultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          const Row(children: [
            Icon(Icons.favorite_border, color: AppColors.navy, size: 22),
            SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Health Data',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                      color: AppColors.g800)),
              Text('Patient health records and clinical data.',
                  style: TextStyle(fontSize: 13, color: AppColors.g400)),
            ]),
          ]),
          const SizedBox(height: 24),

          // Banner image placeholder
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.navyL,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.g200),
              image: const DecorationImage(
                image: AssetImage('assets/images/health_data_bg.png'),
                fit: BoxFit.cover,
                onError: _ignoreError,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.navy.withOpacity(0.85),
                    AppColors.navy.withOpacity(0.3),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Health Data Module',
                      style: TextStyle(color: Colors.white, fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    'Track vital signs, lab results, and clinical records\nfor all registered patients.',
                    style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: const Text('Coming Soon',
                        style: TextStyle(color: Colors.white, fontSize: 12,
                            fontWeight: FontWeight.w600, letterSpacing: 1)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Feature cards
          Wrap(spacing: 16, runSpacing: 16, children: [
            _featureCard(Icons.monitor_heart_outlined, 'Vital Signs',
                'Blood pressure, temperature, pulse and oxygen levels.'),
            _featureCard(Icons.science_outlined, 'Lab Results',
                'Blood tests, urinalysis and other diagnostic results.'),
            _featureCard(Icons.medication_outlined, 'Medications',
                'Prescribed drugs, dosage and treatment history.'),
            _featureCard(Icons.note_alt_outlined, 'Clinical Notes',
                'Clinician observations and consultation summaries.'),
          ]),
        ]),
      ),
    );
  }

  Widget _featureCard(IconData icon, String title, String desc) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.g200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
              color: AppColors.navyL, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppColors.navy, size: 20),
        ),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
            color: AppColors.g800)),
        const SizedBox(height: 6),
        Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.g400, height: 1.5)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
              color: AppColors.g100, borderRadius: BorderRadius.circular(10)),
          child: const Text('Coming Soon',
              style: TextStyle(fontSize: 10, color: AppColors.g600,
                  fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

// Silently ignore missing background image
void _ignoreError(Object e, StackTrace? s) {}
