import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../controller/story_controller.dart';
import '../../utils/enum.dart';
import '../../utils/image_loader.dart';
import 'image_content_view.dart';

/// Widget to display animated gifs or still images. Shows a loader while image
/// is being loaded. Listens to playback states from [controller] to pause and
/// forward animated media.
class StoryImage extends StatefulWidget {
  final ImageLoader imageLoader;
  final BoxFit? fit;
  final StoryController? controller;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const StoryImage(
    this.imageLoader, {
    super.key,
    this.controller,
    this.fit,
    this.loadingWidget,
    this.errorWidget,
  });

  /// Use this shorthand to fetch images/gifs from the provided [url]
  factory StoryImage.url(
    String url, {
    StoryController? controller,
    Map<String, String>? requestHeaders,
    BoxFit fit = BoxFit.fitWidth,
    Widget? loadingWidget,
    Widget? errorWidget,
    Key? key,
  }) {
    return StoryImage(
      ImageLoader(url, requestHeaders: requestHeaders),
      controller: controller,
      fit: fit,
      loadingWidget: loadingWidget,
      errorWidget: errorWidget,
      key: key,
    );
  }

  @override
  State<StoryImage> createState() => _StoryImageState();
}

class _StoryImageState extends State<StoryImage> {
  ui.Image? _currentFrame;
  Timer? _frameTimer;
  StreamSubscription<PlaybackState>? _streamSubscription;

  // Track local state to avoid accessing stream.value directly
  PlaybackState _currentPlaybackState = PlaybackState.play;

  @override
  void initState() {
    super.initState();
    _setupControllerListener();
    _loadImage();
  }

  @override
  void dispose() {
    widget.imageLoader.dispose();
    _frameTimer?.cancel();
    _streamSubscription?.cancel();
    super.dispose();
  }

  void _setupControllerListener() {
    if (widget.controller == null) return;

    // Initially pause until loaded
    widget.controller!.pause();

    _streamSubscription = widget.controller!.playbackNotifier.listen((status) {
      _currentPlaybackState = status;

      // If it's a static image (no frames), we don't need animation logic
      if (widget.imageLoader.frames == null) return;

      if (status == PlaybackState.pause) {
        _frameTimer?.cancel();
      } else {
        _animate();
      }
    });
  }

  void _loadImage() {
    widget.imageLoader.loadImage(() async {
      if (!mounted) return;

      if (widget.imageLoader.state == LoadState.success) {
        widget.controller?.play();
        _animate();
      } else {
        // Refresh to show errorWidget
        setState(() {});
      }
    });
  }

  Future<void> _animate() async {
    _frameTimer?.cancel();

    // Don't animate if paused or if there are no frames to animate
    if (_currentPlaybackState == PlaybackState.pause ||
        widget.imageLoader.frames == null) {
      return;
    }

    final nextFrame = await widget.imageLoader.frames!.getNextFrame();

    if (!mounted) return;

    setState(() {
      _currentFrame = nextFrame.image;
    });

    if (nextFrame.duration > Duration.zero) {
      _frameTimer = Timer(nextFrame.duration, _animate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ImageContentView(
        imageLoader: widget.imageLoader,
        fit: widget.fit,
        currentFrame: _currentFrame,
        loadingWidget: widget.loadingWidget,
        errorWidget: widget.errorWidget,
      ),
    );
  }
}
