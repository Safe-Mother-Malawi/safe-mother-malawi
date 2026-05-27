// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html; // ignore: deprecated_member_use
import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

Future<void> downloadReport(BuildContext context, Map<String, dynamic> report) async {
  final id = report['id']?.toString() ?? '';
  final name = report['name']?.toString() ?? 'report';
  if (id.isEmpty) return;
  try {
    final bytes = await ApiService.downloadReportPdf(id);
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', '$name.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e'), backgroundColor: Colors.red.shade700),
      );
    }
  }
}

Future<void> openReport(BuildContext context, Map<String, dynamic> report) async {
  final id = report['id']?.toString() ?? '';
  if (id.isEmpty) return;
  try {
    final bytes = await ApiService.downloadReportPdf(id);
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');
    Future.delayed(const Duration(seconds: 5), () => html.Url.revokeObjectUrl(url));
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open report: $e'), backgroundColor: Colors.red.shade700),
      );
    }
  }
}
