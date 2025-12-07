import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mindlog/data/models/note.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        // Using InkWell to make the entire card tappable
        onTap: onEdit, // Tap anywhere on the card to edit
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Note content as plain text
              Text(
                note.content,
                style: const TextStyle(fontSize: 14.0),
              ),
              const Gap(8), // Add spacing between content and images
              // Display attached images as thumbnails if any (grid format)
              if (note.images.isNotEmpty)
                FutureBuilder<List<String>>(
                  future: _getImagePaths(
                    note.id,
                    note.images.take(9).toList(),
                  ), // Limit to first 9 images
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      final imagePaths = snapshot.data!;
                      return Container(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildImagesGrid(imagePaths),
                      );
                    } else {
                      // If image paths couldn't be retrieved, don't show any images
                      return const SizedBox.shrink();
                    }
                  },
                ),
              const Gap(2), // Add spacing between images and creation time
              // Creation time at the bottom
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    _formatDateTime(note.createTime),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'No date';
    }
    return dateTime.toString().split(
      '.',
    )[0]; // Formats as 'YYYY-MM-DD HH:MM:SS'
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
