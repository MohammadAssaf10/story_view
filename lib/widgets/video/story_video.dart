import 'dart:async';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';

import '../../controller/story_controller.dart';
import '../../utils/enum.dart';
import '../../utils/video_loader.dart';
import 'video_content_view.dart';

class StoryVideo extends StatefulWidget {
  final StoryController? storyController;
  final VideoLoader videoLoader;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  StoryVideo(
    this.videoLoader, {
    Key? key,
    this.storyController,
    this.loadingWidget,
    this.errorWidget,
  }) : super(key: key ?? UniqueKey());

  static StoryVideo url(
    String url, {
    StoryController? controller,
    Map<String, dynamic>? requestHeaders,
    Key? key,
    Widget? loadingWidget,
    Widget? errorWidget,
  }) {
    return StoryVideo(
      VideoLoader(url, requestHeaders: requestHeaders),
      storyController: controller,
      key: key,
      loadingWidget: loadingWidget,
      errorWidget: errorWidget,
    );
  }

  @override
  State<StatefulWidget> createState() {
    return StoryVideoState();
  }
}

class StoryVideoState extends State<StoryVideo> {
  Future<void>? playerLoader;

  StreamSubscription? _streamSubscription;

  BetterPlayerController? playerController;

  @override
  void initState() {
    super.initState();

    widget.storyController!.pause();

    widget.videoLoader.loadVideo(
      () {
        if (widget.videoLoader.state == LoadState.success) {
          this.playerController = BetterPlayerController(
            betterPlayerDataSource: BetterPlayerDataSource.file(
              widget.videoLoader.videoFile!.path,
            ),
            BetterPlayerConfiguration(
              autoPlay: false,
              autoDispose: false,
              fit: BoxFit.contain,
              aspectRatio: 0.1,
              controlsConfiguration: BetterPlayerControlsConfiguration(
                showControls: false,
                loadingWidget: widget.loadingWidget,
              ),
            ),
          );

          playerController!.addEventsListener((event) {
            if (event.betterPlayerEventType ==
                BetterPlayerEventType.initialized && mounted) {
              setState(() {});
              widget.storyController!.play();
            }
          });

          if (widget.storyController != null) {
            _streamSubscription = widget.storyController!.playbackNotifier
                .listen((playbackState) {
                  if (playbackState == PlaybackState.pause) {
                    playerController!.pause();
                  } else {
                    playerController!.play();
                  }
                });
          }
        } else {
          setState(() {});
        }
      },
      () {
        if (mounted) {
          setState(() {
            widget.videoLoader.showLoading();
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      height: double.infinity,
      width: double.infinity,
      child: VideoContentView(
        videoLoadState: widget.videoLoader.state,
        playerController: playerController,
        loadingWidget: widget.loadingWidget,
        errorWidget: widget.errorWidget,
      ),
    );
  }

  @override
  void dispose() {
    playerController?.pause();
    playerController?.videoPlayerController?.pause();
    playerController?.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }
}
