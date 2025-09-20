// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../controller/story_controller.dart';
import '../utils/contrast_helper.dart';
import '../utils/enum.dart';
import 'image/story_image.dart';
import 'video/story_video.dart';

/// This is a representation of a story item (or page).
class StoryItem {
  /// Specifies how long the page should be displayed. It should be a reasonable
  /// amount of time greater than 0 milliseconds.
  final Duration duration;

  /// Has this page been shown already? This is used to indicate that the page
  /// has been displayed. If some pages are supposed to be skipped in a story,
  /// mark them as shown `shown = true`.
  ///
  /// However, during initialization of the story view, all pages after the
  /// last unshown page will have their `shown` attribute altered to false. This
  /// is because the next item to be displayed is taken by the last unshown
  /// story item.
  bool shown;

  /// The page content
  final Widget view;

  final StoryItemType type;
  final String url;

  StoryItem(
    this.view, {
    required this.duration,
    this.shown = false,
    required this.type,
    required this.url,
  });

  /// Short hand to create text-only page.
  ///
  /// [title] is the text to be displayed on [backgroundColor]. The text color
  /// alternates between [Colors.black] and [Colors.white] depending on the
  /// calculated contrast. This is to ensure readability of text.
  ///
  /// Works for inline and full-page stories. See [StoryView.inline] for more on
  /// what inline/full-page means.
  static StoryItem text({
    required String title,
    required Color backgroundColor,
    Key? key,
    TextStyle? textStyle,
    bool shown = false,
    bool roundedTop = false,
    bool roundedBottom = false,
    EdgeInsetsGeometry? textOuterPadding,
    Duration? duration,
  }) {
    double contrast = ContrastHelper.contrast(
      [backgroundColor.r, backgroundColor.g, backgroundColor.b],
      [255.0, 255.0, 255.0],
      /** white text */
    );

    return StoryItem(
      Container(
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
            EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Center(
          child: Text(
            title,
            style:
                textStyle?.copyWith(
                  color: contrast > 1.8 ? Colors.white : Colors.black,
                ) ??
                TextStyle(
                  color: contrast > 1.8 ? Colors.white : Colors.black,
                  fontSize: 18,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      shown: shown,
      duration: duration ?? Duration(seconds: 3),
      type: StoryItemType.text,
      url: title,
    );
  }

  /// Factory constructor for page images. [controller] should be same instance as
  /// one passed to the `StoryView`
  factory StoryItem.pageImage({
    required String url,
    required StoryController controller,
    Key? key,
    BoxFit imageFit = BoxFit.fitWidth,
    Widget? caption,
    Alignment? captionAlignment,
    bool shown = false,
    Map<String, dynamic>? requestHeaders,
    Widget? loadingWidget,
    Widget? errorWidget,
    EdgeInsetsGeometry? captionOuterPadding,
    EdgeInsetsGeometry? captionOuterMargin,
    Duration? duration,
  }) {
    return StoryItem(
      Container(
        key: key,
        color: Colors.black,
        child: Stack(
          children: <Widget>[
            StoryImage.url(
              url,
              controller: controller,
              fit: imageFit,
              requestHeaders: requestHeaders,
              loadingWidget: loadingWidget,
              errorWidget: errorWidget,
            ),
            SafeArea(
              child: Align(
                alignment: captionAlignment ?? Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  margin: captionOuterMargin ?? EdgeInsets.only(bottom: 24),
                  padding:
                      captionOuterPadding ??
                      EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: caption ?? const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
      shown: shown,
      duration: duration ?? Duration(seconds: 3),
      type: StoryItemType.image,
      url: url,
    );
  }

  /// Shorthand for creating inline image. [controller] should be same instance as
  /// one passed to the `StoryView`
  factory StoryItem.inlineImage({
    required String url,
    Widget? caption,
    Alignment? captionAlignment,
    required StoryController controller,
    Key? key,
    BoxFit imageFit = BoxFit.cover,
    Map<String, dynamic>? requestHeaders,
    bool shown = false,
    bool roundedTop = true,
    bool roundedBottom = false,
    Widget? loadingWidget,
    Widget? errorWidget,
    EdgeInsetsGeometry? captionOuterPadding,
    EdgeInsetsGeometry? captionOuterMargin,
    Duration? duration,
  }) {
    return StoryItem(
      ClipRRect(
        key: key,
        child: Container(
          color: Colors.grey[100],
          child: Container(
            color: Colors.black,
            child: Stack(
              children: <Widget>[
                StoryImage.url(
                  url,
                  controller: controller,
                  fit: imageFit,
                  requestHeaders: requestHeaders,
                  loadingWidget: loadingWidget,
                  errorWidget: errorWidget,
                ),
                Container(
                  margin: captionOuterMargin ?? EdgeInsets.only(bottom: 16),
                  padding:
                      captionOuterPadding ??
                      EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Align(
                    alignment: captionAlignment ?? Alignment.bottomLeft,
                    child: Container(
                      child: caption ?? const SizedBox.shrink(),
                      width: double.infinity,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(roundedTop ? 8 : 0),
          bottom: Radius.circular(roundedBottom ? 8 : 0),
        ),
      ),
      shown: shown,
      duration: duration ?? Duration(seconds: 3),
      type: StoryItemType.image,
      url: url,
    );
  }

  /// Shorthand for creating page video. [controller] should be same instance as
  /// one passed to the `StoryView`
  factory StoryItem.pageVideo(
    String url, {
    required StoryController controller,
    required Duration duration,
    Key? key,
    BoxFit imageFit = BoxFit.fitWidth,
    Widget? caption,
    Alignment? captionAlignment,
    EdgeInsetsGeometry? captionOuterMargin,
    EdgeInsetsGeometry? captionOuterPadding,
    bool shown = false,
    Map<String, dynamic>? requestHeaders,
    Widget? loadingWidget,
    Widget? errorWidget,
  }) {
    return StoryItem(
      Container(
        key: key,
        color: Colors.black,
        child: Stack(
          children: <Widget>[
            StoryVideo.url(
              url,
              controller: controller,
              requestHeaders: requestHeaders,
              loadingWidget: loadingWidget,
              errorWidget: errorWidget,
            ),
            SafeArea(
              child: Align(
                alignment: captionAlignment ?? Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  margin: captionOuterMargin ?? EdgeInsets.only(bottom: 24),
                  padding:
                      captionOuterPadding ??
                      EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: caption ?? const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
      shown: shown,
      duration: duration,
      type: StoryItemType.video,
      url: url,
    );
  }

  /// Shorthand for creating a story item from an image provider such as `AssetImage`
  /// or `NetworkImage`. However, the story continues to play while the image loads
  /// up.
  factory StoryItem.pageProviderImage(
    String url,
    ImageProvider image, {
    Key? key,
    BoxFit imageFit = BoxFit.fitWidth,
    String? caption,
    bool shown = false,
    Duration? duration,
  }) {
    return StoryItem(
      Container(
        key: key,
        color: Colors.black,
        child: Stack(
          children: <Widget>[
            Center(
              child: Image(
                image: image,
                height: double.infinity,
                width: double.infinity,
                fit: imageFit,
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 24),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  color: caption != null ? Colors.black54 : Colors.transparent,
                  child: caption != null
                      ? Text(
                          caption,
                          style: TextStyle(fontSize: 15, color: Colors.white),
                          textAlign: TextAlign.center,
                        )
                      : SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
      shown: shown,
      duration: duration ?? Duration(seconds: 3),
      type: StoryItemType.image,
      url: url,
    );
  }

  /// Shorthand for creating an inline story item from an image provider such as `AssetImage`
  /// or `NetworkImage`. However, the story continues to play while the image loads
  /// up.
  factory StoryItem.inlineProviderImage(
    String url,
    ImageProvider image, {
    Key? key,
    Text? caption,
    bool shown = false,
    bool roundedTop = true,
    bool roundedBottom = false,
    Duration? duration,
  }) {
    return StoryItem(
      Container(
        key: key,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(roundedTop ? 8 : 0),
            bottom: Radius.circular(roundedBottom ? 8 : 0),
          ),
          image: DecorationImage(image: image, fit: BoxFit.cover),
        ),
        child: Container(
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              child: caption == null ? SizedBox() : caption,
              width: double.infinity,
            ),
          ),
        ),
      ),
      shown: shown,
      duration: duration ?? Duration(seconds: 3),
      type: StoryItemType.image,
      url: url,
    );
  }

  StoryItem copyWith({Duration? duration}) {
    return StoryItem(
      this.view,
      duration: duration ?? this.duration,
      shown: this.shown,
      type: this.type,
      url: this.url,
    );
  }
}
