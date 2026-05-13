import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Diagnostic widget to test logo loading
class LogoDiagnostics extends StatefulWidget {
  const LogoDiagnostics({super.key});

  @override
  State<LogoDiagnostics> createState() => _LogoDiagnosticsState();
}

class _LogoDiagnosticsState extends State<LogoDiagnostics> {
  String _diagnosticResult = 'Testing logo assets...';
  
  @override
  void initState() {
    super.initState();
    _testAssets();
  }

  Future<void> _testAssets() async {
    final results = <String>[];
    
    // Test each logo asset
    final assets = [
      'assets/logo/LOGO5.png',
      'assets/logo/LOGO6.png',
      'assets/logo/logo 4.png',
    ];
    
    for (final asset in assets) {
      try {
        final data = await rootBundle.load(asset);
        results.add('✅ $asset: ${data.lengthInBytes} bytes');
      } catch (e) {
        results.add('❌ $asset: Failed to load - $e');
      }
    }
    
    setState(() {
      _diagnosticResult = results.join('\n');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logo Diagnostics')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Logo Asset Test Results:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              _diagnosticResult,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            const SizedBox(height: 32),
            const Text(
              'Logo Display Tests:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Test direct image loading
            Row(
              children: [
                Column(
                  children: [
                    const Text('LOGO5.png'),
                    Image.asset(
                      'assets/logo/LOGO5.png',
                      width: 100,
                      height: 100,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          color: Colors.red.withOpacity(0.3),
                          child: const Icon(Icons.error),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Column(
                  children: [
                    const Text('LOGO6.png'),
                    Image.asset(
                      'assets/logo/LOGO6.png',
                      width: 100,
                      height: 100,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          color: Colors.red.withOpacity(0.3),
                          child: const Icon(Icons.error),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}