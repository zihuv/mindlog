import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ui/home/home_screen.dart';
import 'controllers/note_controller.dart';
import 'controllers/notebooks/notebook_controller.dart';
import 'ui/design_system/app_theme.dart';
import 'utils/log_util.dart';
import 'features/notes/data/note_service.dart';
import 'features/notebooks/notebook_service.dart';
import 'database/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LogUtil().init();
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
      home: const HomeScreen(),
      initialBinding: AppBindings(),
    );
  }
}

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(DatabaseProvider());
    Get.put(NoteService());
    Get.put(NotebookService());
    Get.put<NoteController>(NoteController());
    Get.put<NotebookController>(NotebookController());
  }
}
