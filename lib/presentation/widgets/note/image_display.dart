import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:mindlog/presentation/widgets/note/image_gallery_screen.dart';

class ImageDisplay extends StatefulWidget {
  final String imagePath;
  final List<String>? allImages; // All images in the note for gallery view
  final int? imageIndex; // Index of this image in the note's image list
  final double? thumbnailHeight;
  final double? thumbnailWidth;
  final BoxFit? fit;

  const ImageDisplay({
    super.key,
    required this.imagePath,
    this.allImages,
    this.imageIndex,
    this.thumbnailHeight = 120.0,
    this.thumbnailWidth = 120.0,
    this.fit = BoxFit.cover,
  });

  @override
  State<ImageDisplay> createState() => _ImageDisplayState();
}

class _ImageDisplayState extends State<ImageDisplay> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Show image in fullscreen when tapped
        _showFullscreenImage(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: widget.thumbnailWidth,
        height: widget.thumbnailHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: _buildImage(),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Image.file(
      File(widget.imagePath),
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.broken_image, color: Colors.grey);
      },
    );
  }

  void _showFullscreenImage(BuildContext context) {
    if (widget.allImages != null && widget.allImages!.isNotEmpty) {
      // Show in gallery view with all images
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ImageGalleryScreen(
            imagePaths: widget.allImages!,
            initialIndex: widget.imageIndex ?? 0,
            appBarTitle: 'Image View',
          ),
        ),
      );
    } else {
      // Show single image with PhotoView
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Image View'),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            backgroundColor: Colors.black,
            body: Container(
              constraints: const BoxConstraints.expand(),
              child: PhotoView(
                imageProvider: FileImage(File(widget.imagePath)),
                initialScale: PhotoViewComputedScale.contained * 0.8,
                minScale: PhotoViewComputedScale.contained * 0.3,
                maxScale: PhotoViewComputedScale.covered * 3,
                heroAttributes: PhotoViewHeroAttributes(tag: widget.imagePath),
                filterQuality: FilterQuality.high,
                loadingBuilder: (context, event) => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}
