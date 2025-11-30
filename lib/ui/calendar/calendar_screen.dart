import 'dart:io';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindlog/controllers/note_controller.dart';
import 'package:mindlog/features/notes/domain/entities/note.dart';
import 'package:mindlog/features/notes/presentation/components/components/markdown_checklist.dart';
import 'package:mindlog/features/notes/presentation/screens/note_detail_screen.dart';
import 'package:mindlog/ui/design_system/design_system.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime? _currentDate;
  List<Note> _notesForSelectedDate = [];
  NoteController? _noteController;

  @override
  void initState() {
    super.initState();
    // Try to find the controller, and if not found, initialize it
    try {
      _noteController = Get.find<NoteController>();
    } catch (e) {
      // If the controller is not found, create and register it
      _noteController = Get.put(NoteController());
    }
    _currentDate = DateTime.now();
    // Load notes for the current date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotesForDate(_currentDate!);
    });
  }

  Future<void> _loadNotesForDate(DateTime date) async {
    if (_noteController?.isLoading ?? true) return;

    // Get notes specifically for the selected date using the controller's method
    final notesForDate = await _noteController!.getNotesByDate(date);

    setState(() {
      _notesForSelectedDate = notesForDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calendar',
          style: TextStyle(
            fontSize: AppFontSize.extraLarge,
            fontWeight: AppFontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Calendar picker
          Container(
            padding: const EdgeInsets.all(16),
            child: CalendarDatePicker2(
              config: CalendarDatePicker2Config(
                calendarType: CalendarDatePicker2Type.single,
                selectedDayHighlightColor: Theme.of(context).colorScheme.primary,
                weekdayLabelTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: AppFontWeight.medium,
                ),
                dayTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: AppFontWeight.normal,
                ),
              ),
              value: _currentDate != null ? [_currentDate!] : [],
              onValueChanged: (List<DateTime?> dates) {
                setState(() {
                  _currentDate = dates.first;
                });
                _loadNotesForDate(_currentDate!);
              },
            ),
          ),

          // Selected date header
          if (_currentDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_currentDate!.day} ${_currentDate!.month} ${_currentDate!.year}',
                    style: TextStyle(
                      fontSize: AppFontSize.medium,
                      fontWeight: AppFontWeight.semiBold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '${_notesForSelectedDate.length} note(s)',
                    style: TextStyle(
                      fontSize: AppFontSize.small,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

          // Notes list for selected date
          Expanded(
            child: (_noteController?.isLoading ?? true)
                ? const Center(child: CircularProgressIndicator())
                : _notesForSelectedDate.isEmpty
                    ? Center(
                        child: Text(
                          'No notes for this date',
                          style: TextStyle(
                            fontSize: AppFontSize.large,
                            fontWeight: AppFontWeight.normal,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await _loadNotesForDate(_currentDate!);
                          return; // Required for the refresh indicator
                        },
                        child: ListView.builder(
                          padding: AppPadding.small,
                          itemCount: _notesForSelectedDate.length,
                          itemBuilder: (context, index) {
                            final note = _notesForSelectedDate[index];
                            return Card(
                              margin: AppPadding.small,
                              child: Stack(
                                children: [
                                  // Full card tap gesture
                                  Positioned.fill(
                                    child: GestureDetector(
                                      onTap: () {
                                        Get.to(
                                          () => NoteDetailScreen(
                                            noteId: note.id,
                                          ),
                                        );
                                      },
                                      // This allows the gesture detector to be behind other widgets
                                      behavior: HitTestBehavior.translucent,
                                    ),
                                  ),
                                  // Content and images
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Content area (always shown)
                                      Container(
                                        padding: AppPadding
                                            .small, // Reduced padding
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              constraints: const BoxConstraints(
                                                maxHeight:
                                                    60, // Limit height to 2 lines
                                              ),
                                              child: MarkdownChecklist(
                                                text:
                                                    note.content.length > 50
                                                    ? '${note.content.substring(0, 50)}...'
                                                    : note.content,
                                                style: TextStyle(
                                                  fontSize:
                                                      AppFontSize.body,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                                ),
                                                onTextChange: (updatedText) {
                                                  // Don't allow changes from this view
                                                },
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 2,
                                            ), // Reduced spacing
                                            Text(
                                              _formatDateTime(
                                                note.createTime,
                                              ),
                                              style: TextStyle(
                                                fontSize: AppFontSize
                                                    .small, // Smaller font size
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Image thumbnails grid if available (up to 9 images in 3x3 grid)
                                      if (note.images.isNotEmpty)
                                        FutureBuilder<List<String>>(
                                          future: _getImagePaths(
                                            note.id,
                                            note.images.take(9).toList(),
                                          ), // Limit to first 9 images
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData &&
                                                snapshot.data!.isNotEmpty) {
                                              final imagePaths =
                                                  snapshot.data!;
                                              return Container(
                                                padding:
                                                    const EdgeInsets.all(
                                                      8.0,
                                                    ),
                                                child: _buildImagesGrid(
                                                  imagePaths,
                                                ),
                                              );
                                            } else {
                                              // If image paths couldn't be retrieved, don't show any images
                                              return const SizedBox.shrink();
                                            }
                                          },
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'No date';
    }
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Convert image names to full file paths
  Future<List<String>> _getImagePaths(
    String noteId,
    List<String> imageNames,
  ) async {
    final paths = <String>[];
    for (final imageName in imageNames) {
      try {
        // According to MediaService implementation, images are stored in {appDir}/images/{noteId}/{imageName}
        final appDir = await getApplicationDocumentsDirectory();
        String imagePath = path.join(appDir.path, 'images', noteId, imageName);
        paths.add(imagePath);
      } catch (e) {
        // If we can't get the path, return the original path as fallback
        paths.add(imageName);
      }
    }
    return paths;
  }

  Future<bool> _isFileAccessible(String imagePath) async {
    try {
      final file = File(imagePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  Widget _buildImagesGrid(List<String> imagePaths) {
    // Show up to 9 images in a grid with consistent 3x3 layout
    final imagesToShow = imagePaths.length > 9
        ? imagePaths.take(9).toList()
        : imagePaths;

    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(), // Disable scrolling in the grid
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Always use 3 columns for consistent layout
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
        childAspectRatio: 1.0, // Square aspect ratio
      ),
      itemCount: imagesToShow.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            // Show image in fullscreen when tapped (not navigating to note detail)
            _showFullscreenImage(context, imagesToShow[index]);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 0.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: FutureBuilder<bool>(
                future: _isFileAccessible(imagesToShow[index]),
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return Image.file(
                      File(imagesToShow[index]),
                      fit: BoxFit.cover,
                    );
                  } else {
                    return Container(
                      color: Theme.of(context).dividerColor,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFullscreenImage(BuildContext context, String imagePath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Image View'),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          backgroundColor: Colors.black,
          body: InteractiveViewer(
            minScale: 0.1,
            maxScale: 5.0,
            child: Container(
              constraints: const BoxConstraints.expand(),
              child: FutureBuilder<bool>(
                future: _isFileAccessible(imagePath),
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return Image.file(File(imagePath), fit: BoxFit.contain);
                  } else {
                    return const Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 50,
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}