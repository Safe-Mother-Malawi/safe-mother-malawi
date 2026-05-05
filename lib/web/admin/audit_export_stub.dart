import 'package:flutter/material.dart';

// Stub for mobile platforms - web-only feature
class AuditExport extends StatefulWidget {
  const AuditExport({super.key});

  @override
  State<AuditExport> createState() => _AuditExportState();
}

class _AuditExportState extends State<AuditExport> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Audit Export feature is only available on web platform'),
    );
  }
}
