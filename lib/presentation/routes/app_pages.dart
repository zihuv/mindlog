import 'package:get/get.dart';
import 'package:mindlog/presentation/views/checkin/checkin_screen.dart';
import 'package:mindlog/presentation/views/home/home_screen.dart';
import 'package:mindlog/presentation/views/note/note_detail_screen.dart';
import 'package:mindlog/presentation/views/notebooks/notebook_notes_screen.dart';
import 'app_routes.dart';
import 'checkin_binding.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
    GetPage(
      name: AppRoutes.noteDetail,
      page: () => const NoteDetailScreen(noteId: ''),
    ),
    GetPage(
      name: AppRoutes.notebookNotes,
      page: () => const NotebookNotesScreen(notebookId: ''),
    ),
    GetPage(
      name: AppRoutes.checkIn,
      page: () => const CheckInScreen(),
      binding: CheckInBinding(),
    ),
  ];
}
