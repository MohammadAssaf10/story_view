import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';

import '../../utils/enum.dart';

class VideoContentView extends StatelessWidget {
  final LoadState videoLoadState;
  final BetterPlayerController playerController;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const VideoContentView({
    super.key,
    required this.videoLoadState,
    required this.playerController,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (videoLoadState == LoadState.success &&
        playerController.videoPlayerController!.value.initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio:
              playerController.videoPlayerController!.value.aspectRatio,
          child: BetterPlayer(controller: playerController),
        ),
      );
    } else if (videoLoadState == LoadState.loading) {
      return Center(
        child:
            loadingWidget ??
            const SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
      );
    } else if (videoLoadState == LoadState.failure) {
      return Center(
        child:
            errorWidget ??
            const Text(
              "Media failed to load.",
              style: TextStyle(color: Colors.white),
            ),
      );
    }
    return const SizedBox.shrink();
  }
}
