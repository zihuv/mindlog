import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindlog/presentation/widgets/note/image_gallery_screen.dart';

void main() {
  group('ImageGalleryScreen Test', () {
    testWidgets('ImageGalleryScreen builds correctly', (
      WidgetTester tester,
    ) async {
      const imagePaths = ['/path/to/image1.jpg', '/path/to/image2.jpg'];

      await tester.pumpWidget(
        MaterialApp(
          home: ImageGalleryScreen(
            imagePaths: imagePaths,
            initialIndex: 0,
            appBarTitle: 'Test Gallery',
          ),
        ),
      );

      // Check if the widget is built correctly
      expect(find.byType(ImageGalleryScreen), findsOneWidget);
    });

    testWidgets('ImageGalleryScreen shows correct image count in app bar', (
      WidgetTester tester,
    ) async {
      const imagePaths = [
        '/path/to/image1.jpg',
        '/path/to/image2.jpg',
        '/path/to/image3.jpg',
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: ImageGalleryScreen(
            imagePaths: imagePaths,
            initialIndex: 1, // Start at index 1 (second image)
            appBarTitle: 'Test Gallery',
          ),
        ),
      );

      // Check if the correct count (2/3) is displayed in the app bar
      expect(find.text('2 / 3'), findsOneWidget);
    });
  });
}
