import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Diary Entry Model
class DiaryEntry {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final String? mood;

  DiaryEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.mood,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'mood': mood,
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      date: DateTime.parse(map['date']),
      mood: map['mood'],
    );
  }

  String toJson() => json.encode(toMap());

  factory DiaryEntry.fromJson(String source) => DiaryEntry.fromMap(json.decode(source));
}

// Main App
void main() {
  runApp(const DiaryApp());
}

class DiaryApp extends StatelessWidget {
  const DiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Diary',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const DiaryHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DiaryHomePage extends StatefulWidget {
  const DiaryHomePage({super.key});

  @override
  State<DiaryHomePage> createState() => _DiaryHomePageState();
}

class _DiaryHomePageState extends State<DiaryHomePage> {
  List<DiaryEntry> diaryEntries = [];
  final DiaryService diaryService = DiaryService();

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await diaryService.loadEntries();
    setState(() {
      diaryEntries = entries;
    });
  }

  Future<void> _addEntry(DiaryEntry entry) async {
    await diaryService.addEntry(entry);
    _loadEntries();
  }

  Future<void> _updateEntry(DiaryEntry entry) async {
    await diaryService.updateEntry(entry);
    _loadEntries();
  }

  Future<void> _deleteEntry(String id) async {
    await diaryService.deleteEntry(id);
    _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Diary'),
        centerTitle: true,
      ),
      body: diaryEntries.isEmpty
          ? const Center(
              child: Text(
                'No entries yet.\nTap + to create your first entry.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: diaryEntries.length,
              itemBuilder: (context, index) {
                final entry = diaryEntries[index];
                return DiaryEntryCard(
                  entry: entry,
                  onEdit: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateDiaryEntryPage(
                          entry: entry,
                          onSave: _updateEntry,
                        ),
                      ),
                    );
                  },
                  onDelete: () => _deleteEntry(entry.id),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateDiaryEntryPage(
                onSave: _addEntry,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DiaryEntryCard extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DiaryEntryCard({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM dd, yyyy').format(entry.date);
    String moodEmoji = '😊';
    
    // Set mood emoji based on mood selection
    switch (entry.mood) {
      case 'happy':
        moodEmoji = '😊';
        break;
      case 'sad':
        moodEmoji = '😢';
        break;
      case 'excited':
        moodEmoji = '🤩';
        break;
      case 'calm':
        moodEmoji = '😌';
        break;
      case 'angry':
        moodEmoji = '😠';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    moodEmoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                entry.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => FocusScope.of(context).unfocus(),
                    child: const Text(''),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateDiaryEntryPage extends StatefulWidget {
  final DiaryEntry? entry;
  final Function(DiaryEntry) onSave;

  const CreateDiaryEntryPage({
    super.key,
    this.entry,
    required this.onSave,
  });

  @override
  State<CreateDiaryEntryPage> createState() => _CreateDiaryEntryPageState();
}

class _CreateDiaryEntryPageState extends State<CreateDiaryEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _selectedMood;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    
    if (widget.entry != null) {
      _titleController.text = widget.entry!.title;
      _contentController.text = widget.entry!.content;
      _selectedMood = widget.entry!.mood;
      _selectedDate = widget.entry!.date;
    } else {
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      final entry = DiaryEntry(
        id: widget.entry?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        content: _contentController.text,
        date: _selectedDate!,
        mood: _selectedMood,
      );

      await widget.onSave(entry);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry != null ? 'Edit Entry' : 'New Entry'),
        actions: [
          TextButton(
            onPressed: _saveEntry,
            child: const Text(
              'Save',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12.0),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'How are you feeling?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children: [
                  MoodOption(
                    mood: 'happy',
                    label: '😊',
                    isSelected: _selectedMood == 'happy',
                    onTap: () => setState(() => _selectedMood = 'happy'),
                  ),
                  MoodOption(
                    mood: 'sad',
                    label: '😢',
                    isSelected: _selectedMood == 'sad',
                    onTap: () => setState(() => _selectedMood = 'sad'),
                  ),
                  MoodOption(
                    mood: 'excited',
                    label: '🤩',
                    isSelected: _selectedMood == 'excited',
                    onTap: () => setState(() => _selectedMood = 'excited'),
                  ),
                  MoodOption(
                    mood: 'calm',
                    label: '😌',
                    isSelected: _selectedMood == 'calm',
                    onTap: () => setState(() => _selectedMood = 'calm'),
                  ),
                  MoodOption(
                    mood: 'angry',
                    label: '😠',
                    isSelected: _selectedMood == 'angry',
                    onTap: () => setState(() => _selectedMood = 'angry'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Date',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextButton(
                  onPressed: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    
                    if (pickedDate != null) {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_selectedDate ?? DateTime.now()),
                      );
                      
                      if (pickedTime != null) {
                        setState(() {
                          _selectedDate = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      } else if (pickedDate != null) {
                        // Only date was selected, keep current time
                        setState(() {
                          _selectedDate = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            _selectedDate?.hour ?? DateTime.now().hour,
                            _selectedDate?.minute ?? DateTime.now().minute,
                          );
                        });
                      }
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate != null
                            ? DateFormat('MMM dd, yyyy - HH:mm').format(_selectedDate!)
                            : 'Select date and time',
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'What\'s on your mind?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: 'Write your thoughts here...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please write something';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MoodOption extends StatelessWidget {
  final String mood;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const MoodOption({
    required this.mood,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color selectedColor = Colors.grey.shade300;

    switch (mood) {
      case 'happy':
        selectedColor = Colors.yellow.shade100;
        break;
      case 'sad':
        selectedColor = Colors.blue.shade100;
        break;
      case 'excited':
        selectedColor = Colors.orange.shade100;
        break;
      case 'calm':
        selectedColor = Colors.green.shade100;
        break;
      case 'angry':
        selectedColor = Colors.red.shade100;
        break;
    }

    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 20)),
      selected: isSelected,
      selectedColor: selectedColor,
      onSelected: (selected) => onTap(),
      side: BorderSide(
        color: isSelected ? Colors.grey : Colors.transparent,
        width: 1.0,
      ),
    );
  }
}

class DiaryService {
  static const String _key = 'diary_entries';

  Future<void> addEntry(DiaryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await loadEntries();
    
    // Check if entry already exists (for update)
    final existingIndex = entries.indexWhere((e) => e.id == entry.id);
    if (existingIndex != -1) {
      entries[existingIndex] = entry;
    } else {
      entries.add(entry);
    }
    
    // Sort entries by date (newest first)
    entries.sort((a, b) => b.date.compareTo(a.date));
    
    final jsonList = entries.map((entry) => entry.toJson()).toList();
    await prefs.setStringList(_key, jsonList);
  }

  Future<List<DiaryEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    
    return jsonList
        .map((json) => DiaryEntry.fromJson(json))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> updateEntry(DiaryEntry entry) async {
    await addEntry(entry); // Same logic as add for update
  }

  Future<void> deleteEntry(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await loadEntries();
    
    final filteredEntries = entries.where((e) => e.id != id).toList();
    final jsonList = filteredEntries.map((entry) => entry.toJson()).toList();
    
    await prefs.setStringList(_key, jsonList);
  }
}