import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/story_model.dart';
import '../../data/services/api_service.dart';

// Story Provider
final storyProvider = StateNotifierProvider<StoryNotifier, AsyncValue<List<StoryModel>>>((ref) {
  return StoryNotifier();
});

class StoryNotifier extends StateNotifier<AsyncValue<List<StoryModel>>> {
  final ApiService _api = ApiService();

  StoryNotifier() : super(const AsyncValue.loading()) {
    loadStories();
  }

  Future<void> loadStories() async {
    try {
      final storiesData = await _api.getStories();
      final stories = storiesData.map((json) => StoryModel.fromJson(json)).toList();
      state = AsyncValue.data(stories);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> loadMyStories() async {
    try {
      final storiesData = await _api.getMyStories();
      final stories = storiesData.map((json) => StoryModel.fromJson(json)).toList();
      state = AsyncValue.data(stories);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> loadHighlights() async {
    try {
      final storiesData = await _api.getStoryHighlights();
      final stories = storiesData.map((json) => StoryModel.fromJson(json)).toList();
      state = AsyncValue.data(stories);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<StoryModel?> createStory({
    required String mediaUrl,
    required String mediaType,
    int duration = 15,
  }) async {
    try {
      final storyData = await _api.createStory(
        mediaUrl: mediaUrl,
        mediaType: mediaType,
        duration: duration,
      );
      final story = StoryModel.fromJson(storyData);

      // Add to current stories
      final currentStories = state.value ?? [];
      state = AsyncValue.data([story, ...currentStories]);

      return story;
    } catch (e) {
      return null;
    }
  }

  Future<void> viewStory(String storyId) async {
    try {
      await _api.viewStory(storyId);
      // Update view count in local state
      final currentStories = state.value ?? [];
      state = AsyncValue.data(
        currentStories.map((story) {
          if (story.id == storyId) {
            return story.copyWith(viewsCount: story.viewsCount + 1);
          }
          return story;
        }).toList(),
      );
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteStory(String storyId) async {
    try {
      await _api.deleteStory(storyId);
      // Remove from local state
      final currentStories = state.value ?? [];
      state = AsyncValue.data(
        currentStories.where((story) => story.id != storyId).toList(),
      );
    } catch (e) {
      // Handle error
    }
  }

  Future<void> refresh() async {
    await loadStories();
  }
}