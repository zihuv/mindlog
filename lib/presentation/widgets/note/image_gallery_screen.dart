import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:mindlog/presentation/widgets/common/custom_header_bar.dart';

class ImageGalleryScreen extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;
  final String appBarTitle;

  const ImageGalleryScreen({
    super.key,
    required this.imagePaths,
    this.initialIndex = 0,
    this.appBarTitle = 'Image Gallery',
  });

  @override
  State<ImageGalleryScreen> createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomHeaderBar(
        title: widget.appBarTitle,
        showBackButton: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          Text(
            '${_currentIndex + 1} / ${widget.imagePaths.length}',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(width: 16),
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              final imagePath = widget.imagePaths[index];
              return PhotoViewGalleryPageOptions(
                imageProvider: FileImage(File(imagePath)),
                initialScale: PhotoViewComputedScale.contained * 0.8,
                minScale: PhotoViewComputedScale.contained * 0.3,
                maxScale: PhotoViewComputedScale.covered * 3,
                heroAttributes: PhotoViewHeroAttributes(tag: imagePath),
                filterQuality: FilterQuality.high,
              );
            },
            itemCount: widget.imagePaths.length,
            loadingBuilder: (context, event) => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            pageController: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
}
