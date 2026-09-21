import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vehicle_care/screens/home/home_screen.dart';

void main() {
  testWidgets(
    'VehicleCare home screen displays vehicle types',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomeScreen(
            userName: 'Aditi',
          ),
        ),
      );

      expect(find.text('VehicleCare'), findsOneWidget);
      expect(find.text('Hello, Aditi 👋'), findsOneWidget);
      expect(find.text('2 Wheeler'), findsOneWidget);
      expect(find.text('4 Wheeler'), findsOneWidget);
    },
  );
}