import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// Mock implementation to test snackbar functionality only
class MockWebDAVSettingsScreen extends StatefulWidget {
  const MockWebDAVSettingsScreen({super.key});

  @override
  State<MockWebDAVSettingsScreen> createState() =>
      _MockWebDAVSettingsScreenState();
}

class _MockWebDAVSettingsScreenState extends State<MockWebDAVSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Test the snackbar functionality
            Get.snackbar(
              "Test",
              "Test message",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
            );
          },
          child: const Text('Show Snackbar'),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('Get.snackbar works properly with GetMaterialApp', (
    WidgetTester tester,
  ) async {
    // Wrap the test widget with GetMaterialApp to ensure Overlay is available
    await tester.pumpWidget(
      GetMaterialApp(home: const MockWebDAVSettingsScreen()),
    );

    // Tap the button to trigger the snackbar
    await tester.tap(find.text('Show Snackbar'));
    await tester.pump(); // Trigger the snackbar

    // The snackbar should be shown without any overlay errors
    expect(find.text('Test message'), findsOneWidget);
  });
}
