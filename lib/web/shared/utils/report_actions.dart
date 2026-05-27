import 'package:flutter/material.dart';

/// Opens a report — shows a snackbar since web PDF preview requires a URL
/// from the backend. Extend this when the backend returns a download URL.
Future<void> openReport(
    BuildContext context, Map<String, dynamic> report) async {
  final url = report['url'] as String?;
  if (url != null && url.isNotEmpty) {
    // TODO: launch(url) when url_launcher is available
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Opening: $url'),
      behavior: SnackBarBehavior.floating,
    ));
  } else {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('No preview URL available for this report.'),
      behavior: SnackBarBehavior.floating,
    ));
  }
}

/// Downloads a report — shows a snackbar with the download URL.
Future<void> downloadReport(
    BuildContext context, Map<String, dynamic> report) async {
  final url = report['url'] as String?;
  if (url != null && url.isNotEmpty) {
    // TODO: launch(url) when url_launcher is available
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Downloading: $url'),
      behavior: SnackBarBehavior.floating,
    ));
  } else {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('No download URL available for this report.'),
      behavior: SnackBarBehavior.floating,
    ));
  }
}

