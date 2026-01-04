import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/message_model.dart';
import '../models/activity_model.dart';
import '../models/notification_model.dart';
import '../services/local_storage_service.dart';
import '../../core/constants/api_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  String? _authToken;
  String? _csrfToken;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.apiBaseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.addAll([
      _csrfInterceptor(),
      _authInterceptor(),
      _loggingInterceptor(),
      _errorInterceptor(),
    ]);
  }

  // ===========================================================================
  // INTERCEPTORS
  // ===========================================================================
  
  Interceptor _csrfInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_csrfToken != null) {
          options.headers['X-CSRFToken'] = _csrfToken;
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Extract CSRF token from Set-Cookie header if present
        final cookies = response.headers['set-cookie'];
        if (cookies != null) {
          for (var cookie in cookies) {
            if (cookie.contains('csrftoken=')) {
              // Extract the token value
              final regExp = RegExp(r'csrftoken=([^;]+)');
              final match = regExp.firstMatch(cookie);
              if (match != null) {
                _csrfToken = match.group(1);
                if (kDebugMode) {
                  print('🔑 CSRF Token updated: $_csrfToken');
                }
              }
            }
          }
        }
        return handler.next(response);
      },
    );
  }

  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        return handler.next(options);
      },
    );
  }

  Interceptor _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        if (kDebugMode) {
          print('🌐 API Request: ${options.method} ${options.uri}');
          print('📤 Headers: ${options.headers}');
          if (options.data != null) {
            print('📤 Data: ${options.data}');
          }
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('✅ API Response: ${response.statusCode} ${response.requestOptions.uri}');
          print('📥 Data: ${response.data}');
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          print('❌ API Error: ${error.response?.statusCode} ${error.requestOptions.uri}');
          print('❌ Error: ${error.message}');
          if (error.response?.data != null) {
            print('❌ Response Data: ${error.response?.data}');
          }
        }
        return handler.next(error);
      },
    );
  }

  Interceptor _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired, try refresh
          try {
            await _refreshToken();
            // Retry the original request
            final response = await _retryRequest(error.requestOptions);
            return handler.resolve(response);
          } catch (e) {
            // Refresh failed, logout user
            _authToken = null;
            // You might want to emit an event to logout the user
          }
        }
        return handler.next(error);
      },
    );
  }

  // ===========================================================================
  // AUTHENTICATION METHODS
  // ===========================================================================

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    // If we don't have a CSRF token yet, try to get one from a simple GET request
    if (_csrfToken == null) {
      try {
        await _dio.get(ApiConstants.baseUrl);
      } catch (e) {
        // Ignore errors, we're just trying to pick up a cookie
      }
    }

    final response = await _dio.post(
      ApiConstants.login,
      data: {
        'identifier': identifier,  // Can be username or email
        'password': password,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> register({
    required String identifier,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConstants.register,
      data: {
        'identifier': identifier,
        'password': password,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      ApiConstants.refreshToken,
      data: {'refresh': refreshToken},
    );
    return response.data;
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _dio.get(ApiConstants.getCurrentUser);
    return UserModel.fromJson(response.data);
  }

  // ===========================================================================
  // USER METHODS
  // ===========================================================================

  Future<List<UserModel>> searchUsers(String query, {int limit = 20}) async {
    final response = await _dio.get(
      ApiConstants.searchUsers,
      queryParameters: {'q': query, 'limit': limit},
    );
    final List<dynamic> data = response.data;
    return data.map((json) => UserModel.fromJson(json)).toList();
  }

  Future<UserModel> getUserById(String userId) async {
    final response = await _dio.get(ApiConstants.userById(userId));
    return UserModel.fromJson(response.data);
  }

  Future<void> followUser(String userId) async {
    await _dio.post(ApiConstants.followUser(userId));
  }

  Future<void> unfollowUser(String userId) async {
    await _dio.post(ApiConstants.unfollowUser(userId));
  }

  Future<List<UserModel>> getUserFollowers(String userId, {int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.userFollowers(userId),
      queryParameters: {'page': page},
    );
    final List<dynamic> data = response.data['results'] ?? response.data;
    return data.map((json) => UserModel.fromJson(json)).toList();
  }

  Future<List<UserModel>> getUserFollowing(String userId, {int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.userFollowing(userId),
      queryParameters: {'page': page},
    );
    final List<dynamic> data = response.data['results'] ?? response.data;
    return data.map((json) => UserModel.fromJson(json)).toList();
  }

  // ===========================================================================
  // POST METHODS
  // ===========================================================================

  Future<List<PostModel>> getFeed({int page = 1, int limit = 20}) async {
    final response = await _dio.get(
      ApiConstants.posts,
      queryParameters: {'page': page, 'limit': limit},
    );
    final List<dynamic> data = response.data['results'] ?? response.data;
    return data.map((json) => PostModel.fromJson(json)).toList();
  }

  Future<List<PostModel>> getUserPosts(String userId, {int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.userById(userId) + '/posts',
      queryParameters: {'page': page},
    );
    final List<dynamic> data = response.data['results'] ?? response.data;
    return data.map((json) => PostModel.fromJson(json)).toList();
  }

  Future<PostModel> getPostById(String postId) async {
    final response = await _dio.get(ApiConstants.postById(postId));
    return PostModel.fromJson(response.data);
  }

  Future<PostModel> createPost({
    required String postType,
    String? caption,
    required String mediaUrl,
    List<String>? hashtags,
  }) async {
    final response = await _dio.post(
      ApiConstants.posts,
      data: {
        'postType': postType,
        'caption': caption,
        'mediaUrl': mediaUrl,
        'hashtags': hashtags ?? [],
      },
    );
    return PostModel.fromJson(response.data);
  }

  Future<void> likePost(String postId) async {
    await _dio.post(ApiConstants.likePost(postId));
  }

  Future<void> unlikePost(String postId) async {
    await _dio.delete(ApiConstants.likePost(postId));
  }

  Future<void> deletePost(String postId) async {
    await _dio.delete(ApiConstants.postById(postId));
  }

  // ===========================================================================
  // COMMENT METHODS
  // ===========================================================================

  Future<List<dynamic>> getPostComments(String postId, {int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.postComments(postId),
      queryParameters: {'page': page},
    );
    return response.data['results'] ?? response.data;
  }

  Future<Map<String, dynamic>> addComment(String postId, String text, {String? parentId}) async {
    final response = await _dio.post(
      ApiConstants.postComments(postId),
      data: {
        'text': text,
        if (parentId != null) 'parent': parentId,
      },
    );
    return response.data;
  }

  Future<void> likeComment(String commentId) async {
    await _dio.post('/api/v1/comments/$commentId/like');
  }

  // ===========================================================================
  // CHAT METHODS
  // ===========================================================================

  Future<List<dynamic>> getConversations({int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.conversations,
      queryParameters: {'page': page},
    );
    return response.data['results'] ?? response.data;
  }

  Future<dynamic> getConversationById(String conversationId) async {
    final response = await _dio.get(ApiConstants.conversationById(conversationId));
    return response.data;
  }

  Future<List<MessageModel>> getConversationMessages(String conversationId, {int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.conversationMessages(conversationId),
      queryParameters: {'page': page},
    );
    final List<dynamic> data = response.data['results'] ?? response.data;
    return data.map((json) => MessageModel.fromJson(json)).toList();
  }

  Future<MessageModel> sendMessage(String conversationId, {
    required String messageType,
    String? content,
    String? mediaUrl,
  }) async {
    final response = await _dio.post(
      ApiConstants.sendMessage(conversationId),
      data: {
        'conversation': conversationId,
        'message_type': messageType,
        'content': content,
        'media_url': mediaUrl,
      },
    );
    return MessageModel.fromJson(response.data);
  }

  Future<dynamic> createConversation(String otherUserId) async {
    final response = await _dio.post(
      '${ApiConstants.conversations}create_direct_message/',
      data: {
        'user_id': otherUserId,
      },
    );
    return response.data;
  }

  Future<dynamic> createGroupConversation(List<String> participantIds, String name) async {
    final response = await _dio.post(
      '${ApiConstants.conversations}create_group/',
      data: {
        'participant_ids': participantIds,
        'name': name,
      },
    );
    return response.data;
  }

  // ===========================================================================
  // ACTIVITY METHODS
  // ===========================================================================

  Future<List<ActivityModel>> getActivities({int page = 1, String? type}) async {
    final response = await _dio.get(
      ApiConstants.activities,
      queryParameters: {
        'page': page,
        if (type != null) 'activity_type': type,
      },
    );
    final List<dynamic> data = response.data['results'] ?? response.data;
    return data.map((json) => ActivityModel.fromJson(json)).toList();
  }

  Future<void> trackActivity({
    required String activityType,
    Map<String, dynamic>? metadata,
    String? postId,
    String? storyId,
    String? targetUserId,
  }) async {
    await _dio.post(
      ApiConstants.activities,
      data: {
        'activityType': activityType,
        'metadata': metadata ?? {},
        if (postId != null) 'postId': postId,
        if (storyId != null) 'storyId': storyId,
        if (targetUserId != null) 'targetUserId': targetUserId,
      },
    );
  }

  // ===========================================================================
  // NOTIFICATION METHODS
  // ===========================================================================

  Future<List<NotificationModel>> getNotifications({int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.notifications,
      queryParameters: {'page': page},
    );
    final List<dynamic> data = response.data['results'] ?? response.data;
    return data.map((json) => NotificationModel.fromJson(json)).toList();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _dio.patch(ApiConstants.markNotificationRead(notificationId));
  }

  // ===========================================================================
  // SEARCH METHODS
  // ===========================================================================

  Future<Map<String, dynamic>> search(String query, {String type = 'all'}) async {
    final response = await _dio.get(
      ApiConstants.search,
      queryParameters: {'q': query, 'type': type},
    );
    return response.data;
  }

  // ===========================================================================
  // FILE UPLOAD METHODS
  // ===========================================================================

  Future<String> uploadFile(File file, {String type = 'image'}) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
      'type': type,
    });

    final response = await _dio.post(
      type == 'image' ? ApiConstants.uploadImage : ApiConstants.uploadVideo,
      data: formData,
    );

    return response.data['url'];
  }

  // ===========================================================================
  // PRIVATE HELPER METHODS
  // ===========================================================================

  Future<void> _refreshToken() async {
    try {
      final storage = LocalStorageService();
      final refresh = await storage.getRefreshToken();
      
      if (refresh == null) throw Exception('No refresh token found');

      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {'refresh': refresh},
      );

      final String newToken = response.data['access'];
      _authToken = newToken;
      await storage.saveAuthToken(newToken);
      
      if (kDebugMode) {
        print('🔄 Token refreshed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to refresh token: $e');
      }
      rethrow;
    }
  }

  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    
    // Update auth header with new token
    if (_authToken != null) {
      options.headers?['Authorization'] = 'Bearer $_authToken';
    }

    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  // ===========================================================================
  // FASTAPI FEED METHODS
  // ===========================================================================

  Future<Map<String, dynamic>> getForYouFeed({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      ApiConstants.forYouFeed,
      queryParameters: {'page': page, 'limit': limit},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getTrendingFeed({
    int page = 1,
    int limit = 20,
    String timeWindow = '24h',
  }) async {
    final response = await _dio.get(
      ApiConstants.trendingFeed,
      queryParameters: {
        'page': page,
        'limit': limit,
        'time_window': timeWindow,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getExploreFeed({
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      ApiConstants.exploreFeed,
      queryParameters: {
        if (category != null) 'category': category,
        'page': page,
        'limit': limit,
      },
    );
    return response.data;
  }

  // ===========================================================================
  // FASTAPI RECOMMENDATIONS METHODS
  // ===========================================================================

  Future<Map<String, dynamic>> getUserRecommendations({int limit = 20}) async {
    final response = await _dio.get(
      ApiConstants.userRecommendations,
      queryParameters: {'limit': limit},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getContentRecommendations({int limit = 20}) async {
    final response = await _dio.get(
      ApiConstants.contentRecommendations,
      queryParameters: {'limit': limit},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getHashtagRecommendations({int limit = 10}) async {
    final response = await _dio.get(
      ApiConstants.hashtagRecommendations,
      queryParameters: {'limit': limit},
    );
    return response.data;
  }

  // ===========================================================================
  // CUSTOM REQUEST METHODS
  // ===========================================================================

  Future<Response> customRequest({
    required String method,
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final options = Options(method: method);
    return _dio.request(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
