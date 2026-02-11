# Story View Example

A simple Flutter example app demonstrating how to use the `story_view` package to create Instagram-like stories.

## Features Demonstrated

- 📸 **Image Stories** - Display images from network URLs
- 🎥 **Video Stories** - Play videos with automatic playback
- 📊 **Custom Progress Indicators** - Orange progress bars with custom styling
- 👆 **Gesture Controls** - Tap to navigate, swipe down to dismiss
- 🔄 **Multiple Story Pages** - Navigate between different story collections
- 🌐 **RTL Support** - Automatic right-to-left layout based on locale
- ⚙️ **Custom Loading Widget** - Orange circular progress indicator

## Running the Example

1. Make sure you have Flutter installed on your machine
2. Navigate to the example directory:
   ```bash
   cd example/story_view_example
   ```
3. Get the dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## What You'll See

The example app includes:

- A home screen with a button to view stories
- Story view with multiple media items:
  - An image from Unsplash
  - A short video of a bee (5 seconds)
  - A longer movie trailer (52 seconds)
- Custom orange progress bars
- Swipe down to dismiss functionality
- Automatic progression through stories

## Code Overview

### Main Components

- **`main.dart`** - App entry point with navigation to story view
- **`story_view_page.dart`** - Main story view implementation with PageView
- **`story.dart`** - Story model representing a collection of substories
- **`sub_story.dart`** - Individual story item model (image or video)

### Key Features in Code

```dart
StoryView(
  progressHeight: 3,
  progressColor: Colors.grey,
  progressActiveColor: Colors.orange,
  controller: _storiesViewController,
  onVerticalSwipeComplete: (direction) {
    if (direction == Direction.down) {
      Navigator.pop(context);
    }
  },
  storyItems: [ /* your story items */ ],
)
```

## Learning Points

This example teaches you how to:

1. Create story items from images and videos
2. Handle story navigation with PageController
3. Customize progress indicator appearance
4. Handle swipe gestures
5. Navigate between multiple story collections
6. Implement automatic story progression

## More Information

For more details about the `story_view` package, check out the main [package documentation](https://pub.dev/packages/story_view).
