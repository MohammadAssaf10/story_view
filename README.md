# Story View

A Flutter package that lets you easily create beautiful, interactive story views similar to social media apps like Instagram, WhatsApp, and Facebook.

[![pub package](https://img.shields.io/pub/v/story_view.svg)](https://pub.dev/packages/story_view)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Screenshots

<p align="center">
  <img src="assets/android.png" width="300" alt="Android Screenshot"/>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="assets/iOS.png" width="300" alt="iOS Screenshot"/>
</p>

## Features

- 📱 **Instagram-like Stories**: Create engaging story views with images and videos
- 🎥 **Video Support**: Built-in video player with caching capabilities
- 🖼️ **Image Support**: Optimized image loading with caching
- ⏯️ **Playback Control**: Play, pause, next, and previous controls
- 📊 **Progress Indicators**: Customizable progress bars for each story
- 🎨 **Highly Customizable**: Control colors, positions, and behavior
- 👆 **Gesture Support**: Tap to navigate, swipe to dismiss
- 🌐 **Network & Caching**: Smart caching for media files
- 🔄 **Auto-continue**: Automatically advances through stories
- 📍 **RTL Support**: Right-to-left language support
- 💤 **Wakelock**: Keeps screen on during story viewing
- ✅ **Seen Status**: Track which stories have been viewed

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  story_view: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

class StoryScreen extends StatefulWidget {
  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final StoryController _controller = StoryController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoryView(
        storyItems: [
          StoryItem.image(
            url: 'https://example.com/image1.jpg',
            controller: _controller,
            caption: Text('Beautiful sunset'),
            header: Text('User Name'),
          ),
          StoryItem.video(
            url: 'https://example.com/video1.mp4',
            controller: _controller,
            storyDuration: Duration(seconds: 10),
            caption: Text('Amazing video'),
            header: Text('User Name'),
          ),
          StoryItem.text(
            title: 'Hello World!',
            backgroundColor: Colors.blue,
            caption: Text('Text story'),
            header: Text('User Name'),
          ),
        ],
        controller: _controller,
        onComplete: () {
          Navigator.pop(context);
        },
        onVerticalSwipeComplete: (direction) {
          if (direction == Direction.down) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
```

## Story Types

### Image Story

```dart
StoryItem.image(
  url: 'https://example.com/image.jpg',
  controller: controller,
  imageFit: BoxFit.cover,
  storyDuration: Duration(seconds: 5),
  requestHeaders: {'Authorization': 'Bearer token'},
  loadingWidget: CircularProgressIndicator(),
  errorWidget: Icon(Icons.error),
  caption: Text('Image caption'),
  header: Text('User Header'),
  isSeenBefore: false,
)
```

### Video Story

```dart
StoryItem.video(
  url: 'https://example.com/video.mp4',
  controller: controller,
  storyDuration: Duration(seconds: 15),
  requestHeaders: {'Authorization': 'Bearer token'},
  loadingWidget: CircularProgressIndicator(),
  errorWidget: Icon(Icons.error),
  caption: Text('Video caption'),
  header: Text('User Header'),
  isSeenBefore: false,
)
```

### Text Story

```dart
StoryItem.text(
  title: 'Hello World!',
  backgroundColor: Colors.blue,
  textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  storyDuration: Duration(seconds: 3),
  roundedTop: true,
  roundedBottom: true,
  textOuterPadding: EdgeInsets.all(20),
  caption: Text('Text caption'),
  header: Text('User Header'),
  isSeenBefore: false,
)
```

## Customization

### Progress Indicators

```dart
StoryView(
  storyItems: storyItems,
  controller: controller,
  progressPosition: ProgressPosition.top, // or ProgressPosition.bottom or ProgressPosition.none
  progressColor: Colors.grey,
  progressActiveColor: Colors.blue,
  progressHeight: 3.0,
  progressMargin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
)
```

### RTL Support

```dart
StoryView(
  storyItems: storyItems,
  controller: controller,
  isRtl: true, // Enable right-to-left layout
)
```

## Controller Methods

The `StoryController` provides methods to control story playback:

```dart
final controller = StoryController();

// Play the current story
controller.play();

// Pause the current story
controller.pause();

// Go to next story
controller.next();

// Go to previous story
controller.previous();

// Don't forget to dispose
controller.dispose();
```

## Callbacks

### On Complete

Called when all stories are finished:

```dart
StoryView(
  storyItems: storyItems,
  controller: controller,
  onComplete: () {
    print('All stories completed');
    Navigator.pop(context);
  },
)
```

### On Story Show

Called when a specific story is shown:

```dart
StoryView(
  storyItems: storyItems,
  controller: controller,
  onStoryShow: (storyItem, index) {
    print('Showing story at index: $index');
  },
)
```

### On Vertical Swipe

Called when user swipes vertically:

```dart
StoryView(
  storyItems: storyItems,
  controller: controller,
  onVerticalSwipeComplete: (direction) {
    if (direction == Direction.down) {
      Navigator.pop(context);
    } else if (direction == Direction.up) {
      // Show additional content
    }
  },
)
```

### On Move To Previous Page

Called when trying to go back from the first story:

```dart
StoryView(
  storyItems: storyItems,
  controller: controller,
  onMoveToPreviousPage: () {
    print('Trying to go back from first story');
    // Navigate to previous page or close
  },
)
```

## Gesture Controls

- **Tap left side**: Go to previous story
- **Tap right side**: Go to next story
- **Long press**: Pause story
- **Swipe down**: Dismiss story view (if callback is set)
- **Swipe up**: Custom action (if callback is set)

## Advanced Usage

### Multiple Story Pages

```dart
PageView.builder(
  controller: pageController,
  itemCount: stories.length,
  itemBuilder: (context, index) {
    return StoryView(
      controller: storyController,
      storyItems: stories[index].items,
      onComplete: () {
        if (index < stories.length - 1) {
          pageController.nextPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          Navigator.pop(context);
        }
      },
      onMoveToPreviousPage: index > 0
          ? () {
              pageController.previousPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          : null,
    );
  },
)
```

### Custom Headers and Captions

You can add custom widgets as headers and captions:

```dart
StoryItem.image(
  url: 'https://example.com/image.jpg',
  controller: controller,
  header: Row(
    children: [
      CircleAvatar(
        backgroundImage: NetworkImage('https://example.com/avatar.jpg'),
      ),
      SizedBox(width: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Username', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text('2 hours ago', style: TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    ],
  ),
  caption: Container(
    padding: EdgeInsets.all(16),
    color: Colors.black54,
    child: Text(
      'This is a custom caption with more details',
      style: TextStyle(color: Colors.white),
    ),
  ),
)
```

## Dependencies

This package uses the following dependencies:

- `better_player_plus`: For video playback
- `flutter_cache_manager`: For caching media files
- `wakelock_plus`: To keep screen awake during stories
- `percent_indicator`: For progress indicators
- `rxdart`: For reactive state management
- `collection`: For collection utilities

## Example

Check out the [example](example/story_view_example) directory for a complete working example.

## Platform Support

| Platform | Support |
|----------|---------|
| Android  | ✅      |
| iOS      | ✅      |
| Web      | ✅      |
| macOS    | ✅      |
| Windows  | ✅      |
| Linux    | ✅      |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

Created by [Mohammad Assaf](https://github.com/MohammadAssaf10)

## Issues and Feedback

Please file issues, bugs, or feature requests in our [issue tracker](https://github.com/MohammadAssaf10/story_view/issues).

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes.
