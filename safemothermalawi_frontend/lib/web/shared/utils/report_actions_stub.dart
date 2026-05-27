import 'package:flutter/material.dart';

/// Stub for non-web platforms — PDF download is not supported on mobile/desktop.
Future<void> downloadReport(BuildContext context, Map<String, dynamic> report) async {
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF download is only available on the web.')),
    );
  }
}

Future<void> openReport(BuildContext context, Map<String, dynamic> report) async {
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF preview is only available on the web.')),
    );
  }
}
