import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

class StoriesPage extends StatefulWidget {
  const StoriesPage({super.key});

  @override
  State<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
  final StoryController _storyController = StoryController();

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StoryView(
        storyItems: [
          StoryItem.pageImage(
            url:
                'https://img.freepik.com/free-photo/closeup-scarlet-macaw-from-side-view-scarlet-macaw-closeup-head_488145-3540.jpg?semt=ais_incoming&w=740&q=80',
            controller: _storyController,
          ),
          StoryItem.pageImage(
            url:
                'https://raw.githubusercontent.com/Comfy-Org/example_workflows/refs/heads/main/image_to_image/workflow.png',
            controller: _storyController,
          ),
          StoryItem.pageImage(
            url:
                'https://img.freepik.com/free-photo/closeup-scarlet-macaw-from-side-view-scarlet-macaw-closeup-head_488145-3540.jpg?semt=ais_incoming&w=740&q=80',
            controller: _storyController,
          ),
          StoryItem.pageImage(
            url:
                'https://raw.githubusercontent.com/Comfy-Org/example_workflows/refs/heads/main/image_to_image/workflow.png',
            controller: _storyController,
          ),
        ],
        controller: _storyController,
      ),
    );
  }
}
