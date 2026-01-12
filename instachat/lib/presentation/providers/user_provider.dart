import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/cache_service.dart';

final userProvider =
    StateNotifierProvider.family<UserNotifier, AsyncValue<UserModel>, String>((
      ref,
      userId,
    ) {
      final cacheService = CacheService();
      return UserNotifier(cacheService, userId);
    });

class UserNotifier extends StateNotifier<AsyncValue<UserModel>> {
  final ApiService _apiService = ApiService();
  final CacheService _cacheService;
  final String _userId;

  UserNotifier(this._cacheService, this._userId)
    : super(const AsyncValue.loading()) {
    loadUser();
  }

  Future<void> loadUser({bool forceRefresh = false}) async {
    final cacheKey = CacheService.userKey(_userId);

    // 1. Try Cache
    if (!forceRefresh && _cacheService.hasValidCache(cacheKey)) {
      final cachedData = _cacheService.get(cacheKey);
      if (cachedData != null) {
        try {
          final user = UserModel.fromJson(cachedData);
          state = AsyncValue.data(user);
          return;
        } catch (e) {
          // Fall through
        }
      }
    }

    // 2. Fetch from API
    try {
      state = const AsyncValue.loading();
      final user = await _apiService.getUserById(_userId);

      // 3. Update Cache
      await _cacheService.set(
        cacheKey,
        user.toJson(),
        duration: const Duration(hours: 1),
      );

      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> follow() async {
    try {
      await _apiService.followUser(_userId);
      // Update local state optimistically
      if (state.hasValue) {
        final currentUser = state.value!;
        state = AsyncValue.data(
          currentUser.copyWith(followersCount: currentUser.followersCount + 1),
        );
      }
      // Refresh from server in background
      loadUser(forceRefresh: true);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> unfollow() async {
    try {
      await _apiService.unfollowUser(_userId);
      // Update local state optimistically
      if (state.hasValue) {
        final currentUser = state.value!;
        state = AsyncValue.data(
          currentUser.copyWith(
            followersCount: currentUser.followersCount - 1,
            isFollowing: false,
          ),
        );
      }
      // Refresh from server in background
      loadUser(forceRefresh: true);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> toggleFollow() async {
    if (!state.hasValue) return;
    final isFollowing = state.value!.isFollowing ?? false;
    if (isFollowing) {
      await unfollow();
    } else {
      await follow();
    }
  }
}
