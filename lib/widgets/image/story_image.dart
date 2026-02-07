import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

import '../../utils/media_loader.dart';
import 'image_content_view.dart';

class StoryImage extends StatefulWidget {
  final String imageUrl;
  final BoxFit? fit;
  final StoryController controller;
  final Widget? loader;
  final Widget? errorView;
  final Duration storyDuration;
  final Map<String, String>? requestHeaders;

  const StoryImage({
    super.key,
    required this.imageUrl,
    required this.controller,
    required this.storyDuration,
    this.fit,
    this.loader,
    this.errorView,
    this.requestHeaders,
  });

  @override
  State<StoryImage> createState() => _StoryImageState();
}

class _StoryImageState extends State<StoryImage> {
  late final MediaLoader _imageLoader;

  @override
  void initState() {
    super.initState();
    widget.controller.pause();
    _imageLoader = MediaLoader(
      mediaUrl: widget.imageUrl,
      requestHeaders: widget.requestHeaders,
      storyDuration: widget.storyDuration,
      storyController: widget.controller,
      onLoaded: () {
        if (!mounted) return;
        setState(() {
          widget.controller.play();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ImageContentView(
        imageLoader: _imageLoader,
        fit: widget.fit,
        loadingWidget: widget.loader,
        errorWidget: widget.errorView,
      ),
    );
  }

  @override
  void dispose() {
    _imageLoader.dispose();
    super.dispose();
  }
}
