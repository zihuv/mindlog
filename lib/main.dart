import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'presentation/views/home/home_screen.dart';
import 'presentation/controllers/note_controller.dart';
import 'presentation/controllers/notebook_controller.dart';
import 'core/design_system/app_theme.dart';
import 'utils/log_util.dart';
import 'data/services/note_service.dart';
import 'data/services/notebook_service.dart';
import 'data/database/app_database.dart';

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
