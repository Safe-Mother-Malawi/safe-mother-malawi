import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a report by launching the URL in the default browser
Future<void> openReport(
    BuildContext context, Map<String, dynamic> report) async {
  final url = report['url'] as String?;
  if (url != null && url.isNotEmpty) {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Opening report: ${report['title'] ?? 'Report'}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ));
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Cannot open URL: $url'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.orange,
          ));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to open report: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ));
      }
    }
  } else {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No preview URL available for this report.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.orange,
      ));
    }
  }
}

/// Downloads a report by launching the URL for download
Future<void> downloadReport(
    BuildContext context, Map<String, dynamic> report) async {
  final url = report['url'] as String?;
  if (url != null && url.isNotEmpty) {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Downloading report: ${report['title'] ?? 'Report'}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ));
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Cannot download from URL: $url'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.orange,
          ));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to download report: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ));
      }
    }
  } else {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No download URL available for this report.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.orange,
      ));
    }
  }
}
