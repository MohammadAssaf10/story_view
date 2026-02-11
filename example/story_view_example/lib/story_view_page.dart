import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

import 'story.dart';
import 'sub_story.dart';

class StoryViewPage extends StatefulWidget {
  final int storyIndex;
  const StoryViewPage({super.key, this.storyIndex = 0});

  @override
  State<StoryViewPage> createState() => _StoryViewPageState();
}

class _StoryViewPageState extends State<StoryViewPage> {
  final StoryController _storiesViewController = StoryController();
  final PageController _storiesPageController = PageController();

  @override
  void initState() {
    super.initState();
    // Set the initial page of the postsPageController
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _storiesPageController.jumpToPage(widget.storyIndex);
    });
  }

  bool _isEnglishLocale(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'en';

  List<Story> _getStories() {
    return [
      Story(
        publisherId: 1,
        isAllStoriesWatched: false,
        publisherImage: '',
        publisherName: 'Publisher 1',
        publisherIsAdmin: false,
        stories: [
          SubStory(
            id: 1,
            type: MediaType.image,
            original:
                'https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d',
            isViewedBefore: false,
            isLiked: false,
            likesCount: 0,
          ),
          SubStory(
            id: 2,
            type: MediaType.video,
            original:
                'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
            isViewedBefore: false,
            durationInMilliseconds: 5000,
            isLiked: false,
            likesCount: 0,
          ),
          SubStory(
            id: 3,
            type: MediaType.video,
            original:
                'https://fra1.digitaloceanspaces.com/moalem/al_moalem/production/20805/image_picker_7FBAB971-7581-4524-A022-BC79DD74D4B2-22955-000009BFECE119E8M---R1.mp4',
            isViewedBefore: false,
            durationInMilliseconds: 15040,
            isLiked: false,
            likesCount: 0,
          ),
          SubStory(
            id: 4,
            type: MediaType.video,
            original: 'https://media.w3.org/2010/05/sintel/trailer.mp4',
            isViewedBefore: false,
            durationInMilliseconds: 52000,
            isLiked: false,
            likesCount: 0,
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.black,
      ),
      body: PageView.builder(
        controller: _storiesPageController,
        itemCount: _getStories().length,
        itemBuilder: (context, index) {
          return StoryView(
            progressHeight: 3,
            progressColor: Colors.grey,
            progressActiveColor: Colors.orange,
            progressMargin: const EdgeInsets.only(top: 15, right: 10, left: 10),
            controller: _storiesViewController,
            isRtl: !_isEnglishLocale(context),
            onVerticalSwipeComplete: (direction) {
              if (direction == Direction.down) {
                Navigator.pop(context);
              }
            },
            onMoveToPreviousPage: index > 0
                ? () {
                    _storiesPageController.previousPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            onComplete: () {
              if (index < _getStories().length - 1) {
                _storiesPageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              } else {
                Navigator.pop(context);
              }
            },
            onStoryShow: (storyItem, storyItemIndex) {
              debugPrint(
                'Showing a story item: $storyItemIndex of story ${_getStories()[index].publisherId}',
              );
            },
            storyItems: _getStories()[index].stories
                .map(
                  (story) => story.type == MediaType.image
                      ? StoryItem.image(
                          url: story.original,
                          controller: _storiesViewController,
                          isSeenBefore: story.isViewedBefore,
                          loadingWidget: _Loader(),
                          // header: StoryHeader(
                          //   story: widget.stories[index],
                          //   subStory: story,
                          //   storyController: _storiesViewController,
                          // ),
                        )
                      : StoryItem.video(
                          url: story.original,
                          controller: _storiesViewController,
                          isSeenBefore: story.isViewedBefore,
                          loadingWidget: _Loader(),
                          storyDuration: Duration(
                            milliseconds: story.durationInMilliseconds ?? 10000,
                          ),
                          // header: StoryHeader(
                          //   story: widget.stories[index],
                          //   subStory: story,
                          //   storyController: _storiesViewController,
                          // ),
                        ),
                )
                .toList(),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _storiesViewController.dispose();
    _storiesPageController.dispose();
    super.dispose();
  }
}

class _Loader extends StatelessWidget {
  const _Loader();

  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator(color: Colors.orange));
  }
}
