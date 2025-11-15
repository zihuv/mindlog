import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindlog/ui/notebooks/notebook_list_screen.dart';
import 'package:mindlog/ui/calendar/calendar_screen.dart';
import 'package:mindlog/ui/settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const NotebookListScreen(),
    const CalendarScreen(),
    const SettingsScreen(),
  ];

  final List<String> _titles = ['Notebooks', 'Calendar', 'Settings'];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _selectedIndex == 0
            ? null  // No title for NotebookListScreen
            : Text(_titles[_selectedIndex]),
        toolbarHeight: _selectedIndex == 0 ? 48 : kToolbarHeight, // Compact toolbar when no title
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt_outlined),
            activeIcon: Icon(Icons.note_alt),
            label: 'Notebooks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
