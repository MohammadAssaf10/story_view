import 'package:flutter/material.dart';

import '../story_view.dart';

class StoryItem {
  final Duration storyDuration;
  bool isSeenBefore;
  final Widget view;
  final StoryItemType type;
  final String url;
  final Widget? caption;
  final Widget? header;

  StoryItem({
    required this.view,
    required this.storyDuration,
    required this.type,
    required this.url,
    this.isSeenBefore = false,
    required this.header,
    required this.caption,
  });

  factory StoryItem.text({
    required String title,
    required Color backgroundColor,
    Key? key,
    TextStyle? textStyle,
    bool isSeenBefore = false,
    bool roundedTop = false,
    bool roundedBottom = false,
    EdgeInsetsGeometry? textOuterPadding,
    Duration? storyDuration,
    Widget? caption,
    Widget? header,
  }) {
    final bool isDark = backgroundColor.computeLuminance() < 0.5;
    final Color textColor = isDark ? Colors.white : Colors.black;

    return StoryItem(
      view: Container(
        key: key,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(roundedTop ? 8 : 0),
            bottom: Radius.circular(roundedBottom ? 8 : 0),
          ),
        ),
        padding:
            textOuterPadding ??
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style:
                textStyle?.copyWith(color: textColor) ??
                TextStyle(color: textColor, fontSize: 18),
          ),
        ),
      ),
      isSeenBefore: isSeenBefore,
      storyDuration: storyDuration ?? const Duration(seconds: 3),
      type: StoryItemType.text,
      url: title,
      caption: caption,
      header: header,
    );
  }

  factory StoryItem.image({
    required String url,
    required StoryController controller,
    Key? key,
    BoxFit imageFit = BoxFit.fitWidth,
    bool isSeenBefore = false,
    Map<String, String>? requestHeaders,
    Widget? loadingWidget,
    Widget? errorWidget,
    Duration storyDuration = defaultStoryDuration,
    Widget? caption,
    Widget? header,
  }) {
    return StoryItem(
      view: StoryImage(
        key: key,
        imageUrl: url,
        controller: controller,
        fit: imageFit,
        loader: loadingWidget,
        errorView: errorWidget,
        storyDuration: storyDuration,
        requestHeaders: requestHeaders,
      ),
      isSeenBefore: isSeenBefore,
      storyDuration: storyDuration,
      type: StoryItemType.image,
      url: url,
      caption: caption,
      header: header,
    );
  }

  factory StoryItem.video({
    required String url,
    required StoryController controller,
    required Duration storyDuration,
    Key? key,
    Widget? caption,
    Widget? header,
    bool isSeenBefore = false,
    Map<String, String>? requestHeaders,
    Widget? loadingWidget,
    Widget? errorWidget,
  }) {
    return StoryItem(
      view: StoryVideo(
        storyController: controller,
        key: key,
        loader: loadingWidget,
        errorView: errorWidget,
        videoUrl: url,
        storyDuration: storyDuration,
        requestHeaders: requestHeaders,
      ),
      isSeenBefore: isSeenBefore,
      storyDuration: storyDuration,
      type: StoryItemType.video,
      url: url,
      caption: caption,
      header: header,
    );
  }
}
