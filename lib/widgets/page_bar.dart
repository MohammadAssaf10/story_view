import 'package:flutter/material.dart';
import '../utils/page_data.dart';
import 'story_progress_indicator.dart';

/// Horizontal bar displaying a row of [StoryProgressIndicator] based on the
/// [pages] provided.
class PageBar extends StatelessWidget {
  final List<PageData> pages;
  final Animation<double>? animation;
  final double indicatorHeight;
  final Color? indicatorColor;
  final Color? indicatorForegroundColor;
  final bool isRtl;

  const PageBar(
    this.pages,
    this.animation, {
    super.key,
    this.isRtl = false, // Added default
    this.indicatorHeight = 5,
    this.indicatorColor,
    this.indicatorForegroundColor,
  });

  double _getSpacing(int count) {
    if (count > 15) return 2.0;
    if (count > 10) return 3.0;
    return 4.0;
  }

  @override
  Widget build(BuildContext context) {
    final spacing = _getSpacing(pages.length);
    
    // Find the index of the first page that hasn't been shown yet.
    // If all are shown, -1 indicates the story is complete.
    final activeIndex = pages.indexWhere((it) => !it.shown);

    return AnimatedBuilder(
      animation: animation ?? const AlwaysStoppedAnimation(0),
      builder: (context, child) {
        return Row(
          children: List.generate(pages.length, (index) {
            return Expanded(
              child: Padding(
                // Only add padding to the start of items after the first one
                padding: EdgeInsetsDirectional.only(
                  start: index == 0 ? 0 : spacing,
                ),
                child: StoryProgressIndicator(
                  _getIndicatorValue(index, activeIndex),
                  indicatorHeight: indicatorHeight,
                  indicatorColor: indicatorColor,
                  indicatorForegroundColor: indicatorForegroundColor,
                  isRtl: isRtl,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  double _getIndicatorValue(int index, int activeIndex) {
    // If the activeIndex is -1, it means all pages are shown (progress 1.0)
    // OR no pages are found. Assuming valid list:
    if (activeIndex == -1) return 1.0;

    if (index < activeIndex) {
      // Page already shown
      return 1.0;
    } else if (index == activeIndex) {
      // Currently playing page
      return animation?.value ?? 0.0;
    } else {
      // Future page
      return 0.0;
    }
  }
}