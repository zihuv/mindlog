import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ui/note_list_screen.dart';
import 'controllers/note_controller.dart';

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
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
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
