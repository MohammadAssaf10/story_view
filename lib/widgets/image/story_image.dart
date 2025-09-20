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

  StoryImage(
    this.imageLoader, {
    Key? key,
    this.controller,
    this.fit,
    this.loadingWidget,
    this.errorWidget,
  }) : super(key: key ?? UniqueKey());

  /// Use this shorthand to fetch images/gifs from the provided [url]
  factory StoryImage.url(
    String url, {
    StoryController? controller,
    Map<String, dynamic>? requestHeaders,
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
  State<StatefulWidget> createState() => StoryImageState();
}

class StoryImageState extends State<StoryImage> {
  ui.Image? currentFrame;

  Timer? _timer;

  StreamSubscription<PlaybackState>? _streamSubscription;

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      this._streamSubscription = widget.controller!.playbackNotifier.listen((
        playbackState,
      ) {
        // for the case of gifs we need to pause/play
        if (widget.imageLoader.frames == null) {
          return;
        }

        if (playbackState == PlaybackState.pause) {
          this._timer?.cancel();
        } else {
          forward();
        }
      });
    }

    widget.controller?.pause();

    widget.imageLoader.loadImage(() async {
      if (mounted) {
        if (widget.imageLoader.state == LoadState.success) {
          widget.controller?.play();
          forward();
        } else {
          // refresh to show error
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _streamSubscription?.cancel();

    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void forward() async {
    this._timer?.cancel();

    if (widget.controller != null &&
        widget.controller!.playbackNotifier.stream.value ==
            PlaybackState.pause) {
      return;
    }

    final nextFrame = await widget.imageLoader.frames!.getNextFrame();

    this.currentFrame = nextFrame.image;

    if (nextFrame.duration > Duration(milliseconds: 0)) {
      this._timer = Timer(nextFrame.duration, forward);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: ImageContentView(
        imageLoader: widget.imageLoader,
        fit: widget.fit,
        currentFrame: this.currentFrame,
        loadingWidget: widget.loadingWidget,
        errorWidget: widget.errorWidget,
      ),
    );
  }
}
