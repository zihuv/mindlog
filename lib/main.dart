import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/journal/presentation/pages/journal_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Think Track',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const JournalPage(),
      debugShowCheckedModeBanner: false,
      supportedLocales: const [
        Locale('zh', 'CN'), // Chinese (Simplified)
        Locale('en', 'US'), // English
      ],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
    );
  }
}