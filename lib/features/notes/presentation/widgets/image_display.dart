import 'dart:io';
import 'package:flutter/material.dart';

class ImageDisplay extends StatefulWidget {
  final String imagePath;
  final double? thumbnailHeight;
  final double? thumbnailWidth;
  final BoxFit? fit;

  const ImageDisplay({
    super.key,
    required this.imagePath,
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
        return const Icon(
          Icons.broken_image,
          color: Colors.grey,
        );
      },
    );
  }

  void _showFullscreenImage(BuildContext context) {
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
              child: _buildImage(),
            ),
          ),
        ),
      ),
    );
  }
}