import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindlog/features/notes/presentation/widgets/image_display.dart';

void main() {
  testWidgets('ImageDisplay widget test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ImageDisplay(
            imagePath: 'nonexistent_image.jpg', // This doesn't exist but will show error icon
          ),
        ),
      ),
    );

    // Verify that the ImageDisplay widget is created
    expect(find.byType(GestureDetector), findsOneWidget);

    // Verify that the error icon is shown when image doesn't exist
    expect(find.byType(Icon), findsOneWidget);
    expect(find.byIcon(Icons.broken_image), findsOneWidget);
  });
}