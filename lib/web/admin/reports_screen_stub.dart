import 'package:flutter/material.dart';

// Stub for mobile platforms - web-only feature
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Reports feature is only available on web platform'),
    );
  }
}

