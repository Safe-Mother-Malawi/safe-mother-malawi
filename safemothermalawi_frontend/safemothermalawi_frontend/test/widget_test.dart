import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safemothermalawi_frontend/main.dart';

void main() {
  testWidgets('App launches and shows login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SafeMotherApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
