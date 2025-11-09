import 'package:flutter/material.dart';
import 'package:mindlog/features/journal/presentation/pages/journal_page.dart';
import 'package:mindlog/core/storage/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindLog',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const JournalPage(),
    );
  }
}