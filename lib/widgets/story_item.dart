import 'package:flutter/material.dart';

import '../story_view.dart';

class StoryItem {
  final Duration storyDuration;
  bool isSeenBefore;
  final Widget view;
  final StoryItemType type;
  final String url;

  StoryItem({
    required this.view,
    required this.storyDuration,
    required this.type,
    required this.url,
    this.isSeenBefore = false,
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
    );
  }

  factory StoryItem.image({
    required String url,
    required StoryController controller,
    Key? key,
    BoxFit imageFit = BoxFit.fitWidth,
    Widget? caption,
    Widget? header,
    bool isSeenBefore = false,
    Map<String, String>? requestHeaders,
    Widget? loadingWidget,
    Widget? errorWidget,
    Duration storyDuration = defaultStoryDuration,
  }) {
    return StoryItem(
      view: _buildStoryView(
        caption: caption,
        header: header,
        child: StoryImage(
          key: key,
          imageUrl: url,
          controller: controller,
          fit: imageFit,
          loader: loadingWidget,
          errorView: errorWidget,
          storyDuration: storyDuration,
          requestHeaders: requestHeaders,
        ),
      ),
      isSeenBefore: isSeenBefore,
      storyDuration: storyDuration,
      type: StoryItemType.image,
      url: url,
    );
  }

  factory StoryItem.pageVideo(
    String url, {
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
      view: _buildStoryView(
        caption: caption,
        header: header,
        child: StoryVideo.url(
          url,
          key: key,
          controller: controller,
          requestHeaders: requestHeaders,
          loadingWidget: loadingWidget,
          errorWidget: errorWidget,
        ),
      ),
      isSeenBefore: isSeenBefore,
      storyDuration: storyDuration,
      type: StoryItemType.video,
      url: url,
    );
  }

  static Widget _buildStoryView({
    required Widget child,
    Widget? caption,
    Widget? header,
  }) {
    return Container(
      color: Colors.black,
      child: Stack(
        children: <Widget>[
          child,
          if (header != null)
            SafeArea(
              child: Align(alignment: Alignment.topCenter, child: header),
            ),
          if (caption != null)
            SafeArea(
              child: Align(alignment: Alignment.bottomCenter, child: caption),
            ),
        ],
      ),
    );
  }
}
