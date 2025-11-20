import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mindlog/controllers/note_controller.dart';
import 'package:mindlog/controllers/notebooks/notebook_controller.dart';
import 'package:mindlog/ui/notebooks/notebook_notes_screen.dart';

void main() {
  group('NotebookNotesScreen Test', () {
    setUp(() {
      // Register mock controllers for testing
      Get.put(NoteController(), permanent: true);
      Get.put(NotebookController(), permanent: true);
    });

    tearDown(() {
      Get.reset();
    });

    testWidgets(
      'NotebookNotesScreen builds without AppBar and has proper layout',
      (WidgetTester tester) async {
        // Build our app and trigger a frame
        await tester.pumpWidget(
          GetMaterialApp(home: NotebookNotesScreen(notebookId: 'test-id')),
        );

        // Verify that there is no AppBar in the screen
        expect(find.byType(AppBar), findsNothing);

        // Verify that the notebook title is displayed in a header (when loading)
        // This will be visible while the loading indicator is shown
        expect(find.byType(Column), findsOneWidget);

        // The screen should show a loading indicator initially
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Verify that the FAB is present
        expect(find.byType(FloatingActionButton), findsOneWidget);
      },
    );
  });
}
