import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ui/note_list_screen.dart';
import 'controllers/note_controller.dart';
import 'ui/design_system/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MindLog - Notes App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const NoteListScreen(),
      initialBinding: NoteBinding(),
    );
  }
}

class NoteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NoteController>(() => NoteController());
  }
}
