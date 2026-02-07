import 'package:equatable/equatable.dart';

enum MediaType { image, video }

class SubStory extends Equatable {
  final int id;
  final MediaType type;
  final String original;
  final int? durationInMilliseconds;
  final bool isViewedBefore;
  final bool isLiked;
  final int likesCount;

  const SubStory({
    required this.id,
    required this.type,
    required this.original,
    required this.isViewedBefore,
    required this.isLiked,
    required this.likesCount,
    this.durationInMilliseconds,
  });

  @override
  List<Object?> get props => [
    id,
    isViewedBefore,
    isLiked,
    likesCount,
    type,
    original,
    durationInMilliseconds,
  ];

  SubStory copyWith({
    int? id,
    MediaType? type,
    String? original,
    int? durationInMilliseconds,
    bool? isViewedBefore,
    bool? isLiked,
    int? likesCount,
  }) {
    return SubStory(
      id: id ?? this.id,
      type: type ?? this.type,
      original: original ?? this.original,
      durationInMilliseconds:
          durationInMilliseconds ?? this.durationInMilliseconds,
      isViewedBefore: isViewedBefore ?? this.isViewedBefore,
      isLiked: isLiked ?? this.isLiked,
      likesCount: likesCount ?? this.likesCount,
    );
  }
}
