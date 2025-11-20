import 'package:flutter/material.dart';
import 'package:mindlog/ui/design_system/design_system.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(
          'Calendar functionality coming soon',
          style: TextStyle(
            fontSize: AppFontSize.large,
            fontWeight: AppFontWeight.normal,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
