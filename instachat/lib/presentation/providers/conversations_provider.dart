import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/conversation_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/local_storage_service.dart';
import '../providers/auth_provider.dart';

// Conversations Provider with offline-first logic
final conversationsProvider = StateNotifierProvider<ConversationsNotifier, AsyncValue<List<ConversationModel>>>((ref) {
  final userId = ref.watch(authNotifierProvider).user?.id ?? '';
  return ConversationsNotifier(userId);
});

class ConversationsNotifier extends StateNotifier<AsyncValue<List<ConversationModel>>> {
  final ApiService _api = ApiService();
  final LocalStorageService _storage = LocalStorageService();
  final String _userId;

  ConversationsNotifier(this._userId) : super(const AsyncValue.loading()) {
    loadConversations();
  }

  Future<void> loadConversations({bool forceRefresh = false}) async {
    // 1. Load from local cache immediately
    final localConversations = _storage.getAllConversations();
    if (localConversations.isNotEmpty) {
      state = AsyncValue.data(localConversations);
    }

    // 2. Fetch from API
    try {
      if (localConversations.isEmpty) {
        state = const AsyncValue.loading();
      }

      final conversations = await _api.getConversations();
      final conversationModels = conversations.map((json) => ConversationModel.fromJson(json)).toList();

      // 3. Update local storage
      await _storage.saveConversations(conversationModels);

      // 4. Update state
      state = AsyncValue.data(_storage.getAllConversations());
    } catch (error, stackTrace) {
      if (state is AsyncLoading) {
        state = AsyncValue.error(error, stackTrace);
      }
      print('Error refreshing conversations: $error');
    }
  }

  Future<String?> createConversation(String userId) async {
    try {
      final conversationData = await _api.createConversation(userId);
      final conversation = ConversationModel.fromJson(conversationData);
      
      await _storage.saveConversation(conversation);
      await loadConversations(forceRefresh: true);

      return conversation.id;
    } catch (error) {
      print('Error creating conversation: $error');
      return null;
    }
  }

  Future<String?> createGroupConversation(List<String> participantIds, String name) async {
    try {
      final conversationData = await _api.createGroupConversation(participantIds, name);
      final conversation = ConversationModel.fromJson(conversationData);

      await _storage.saveConversation(conversation);
      await loadConversations(forceRefresh: true);

      return conversation.id;
    } catch (error) {
      print('Error creating group conversation: $error');
      return null;
    }
  }

  Future<bool> deleteConversation(String conversationId) async {
    try {
      await _api.customRequest(
        method: 'DELETE',
        path: '/chat/conversations/$conversationId/',
      );
      
      // Update local storage and state
      await _storage.deleteConversation(conversationId);
      await loadConversations();
      return true;
    } catch (error) {
      print('Error deleting conversation: $error');
      return false;
    }
  }

  // Refresh conversations (force API call)
  Future<void> refresh() async {
    await loadConversations(forceRefresh: true);
  }
}
