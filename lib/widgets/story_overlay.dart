import 'package:flutter/material.dart';
import '../flutter_story_view.dart';

class StoryOverlay extends StatelessWidget {
  final Widget? caption;
  final Widget? header;
  final Widget? progress;
  final ProgressPosition progressPosition;
  final void Function(TapDownDetails)? onTapDown;
  final void Function()? onTapCancel;
  final void Function(TapUpDetails, bool)? onTapUp;
  final void Function(DragUpdateDetails)? onVerticalDragUpdate;
  final void Function(DragEndDetails)? onVerticalDragEnd;
  const StoryOverlay({
    super.key,
    required this.caption,
    required this.header,
    required this.progress,
    required this.progressPosition,
    this.onTapDown,
    this.onTapCancel,
    this.onTapUp,
    this.onVerticalDragUpdate,
    this.onVerticalDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          if (progressPosition == ProgressPosition.top && progress != null)
            progress!,
          if (header != null) header!,
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTapDown: onTapDown,
                    onTapCancel: onTapCancel,
                    onTapUp: (details) {
                      if (onTapUp != null) {
                        onTapUp!(details, true);
                      }
                    },
                    onVerticalDragUpdate: onVerticalDragUpdate,
                    onVerticalDragEnd: onVerticalDragEnd,
                    behavior: HitTestBehavior.translucent,
                    child: Container(height: double.infinity),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTapDown: onTapDown,
                    onTapCancel: onTapCancel,
                    onTapUp: (details) {
                      if (onTapUp != null) {
                        onTapUp!(details, false);
                      }
                    },
                    onVerticalDragUpdate: onVerticalDragUpdate,
                    onVerticalDragEnd: onVerticalDragEnd,
                    behavior: HitTestBehavior.translucent,
                    child: Container(height: double.infinity),
                  ),
                ),
              ],
            ),
          ),
          if (caption != null) caption!,
          if (progressPosition == ProgressPosition.bottom && progress != null)
            progress!,
        ],
      ),
    );
  }
}
