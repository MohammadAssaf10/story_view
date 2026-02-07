import 'package:equatable/equatable.dart';

import 'sub_story.dart';

class Story extends Equatable {
  final List<SubStory> stories;
  final String? publisherImage;
  final String publisherName;
  final int publisherId;
  final bool publisherIsAdmin;
  final bool isAllStoriesWatched;

  const Story({
    required this.stories,
    required this.isAllStoriesWatched,
    required this.publisherImage,
    required this.publisherName,
    required this.publisherId,
    required this.publisherIsAdmin,
  });

  @override
  List<Object?> get props => [
    stories,
    isAllStoriesWatched,
    publisherImage,
    publisherName,
    publisherId,
    publisherIsAdmin,
  ];

  Story copyWith({
    List<SubStory>? stories,
    String? publisherImage,
    String? publisherName,
    int? publisherId,
    bool? publisherIsAdmin,
    bool? isAllStoriesWatched,
  }) {
    return Story(
      stories: stories ?? this.stories,
      publisherImage: publisherImage ?? this.publisherImage,
      publisherName: publisherName ?? this.publisherName,
      publisherId: publisherId ?? this.publisherId,
      publisherIsAdmin: publisherIsAdmin ?? this.publisherIsAdmin,
      isAllStoriesWatched: isAllStoriesWatched ?? this.isAllStoriesWatched,
    );
  }
}
