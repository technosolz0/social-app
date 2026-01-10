
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/auth/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/main/main_screen.dart';
import '../../presentation/screens/main/activity_screen.dart';
import '../../presentation/screens/post/create_post_screen.dart';
import '../../presentation/screens/post/post_detail_screen.dart';
import '../../presentation/screens/post/edit_post_screen.dart';
import '../../presentation/screens/post/post_comments_screen.dart';
import '../../presentation/screens/profile/edit_profile_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/settings/account_settings_screen.dart';
import '../../presentation/screens/settings/privacy_settings_screen.dart';
import '../../presentation/screens/settings/notification_settings_screen.dart';
import '../../presentation/screens/settings/help_screen.dart';
import '../../presentation/screens/camera/camera_screen.dart';
import '../../presentation/screens/post/media_selection_screen.dart';
import '../../presentation/screens/post/image_editor_screen.dart';
import '../../presentation/screens/chat/chats_list_screen.dart';
import '../../presentation/screens/chat/chat_room_screen.dart';
import '../../presentation/screens/chat/create_group_screen.dart';
import '../../presentation/screens/chat/chat_settings_screen.dart';
import '../../presentation/screens/chat/edit_group_screen.dart';
import '../../presentation/screens/reels/create_reel_screen.dart';
import '../../presentation/screens/live/live_stream_screen.dart';
import '../../presentation/screens/live/live_streaming_screen.dart';
import '../../presentation/screens/live/live_viewer_screen.dart';
import '../../presentation/screens/gamification/badges_screen.dart';
import '../../presentation/screens/gamification/leaderboard_screen.dart';
import '../../presentation/screens/gamification/points_screen.dart';
import '../../presentation/screens/gamification/quests_screen.dart';
import '../../presentation/screens/profile/user_profile_screen.dart';
import '../../presentation/screens/profile/followers_screen.dart';
import '../../presentation/screens/profile/following_screen.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authNotifierProvider,
      (_, __) => notifyListeners(),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final listenable = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: listenable,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final isAuthenticated = authState.isAuthenticated;
      final isSplashScreen = state.matchedLocation == '/';
      final isLoggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';

      // 1. If currently checking auth, stay on Splash
      // We return null to allow staying on the current route (Splash)
      if (authState.isLoading) return null;

      // 2. If not authenticated
      if (!isAuthenticated) {
        // Allow login/register screens
        if (isLoggingIn) return null;
        
        // If on splash, allow it (let the Splash screen manually navigate to /login when ready)
        // OR enforce it?
        // Since we fixed the provider recreation, manual navigation from SplashScreen should work fine.
        // But as a fallback, if we are NOT on Splash and NOT on login, force login.
        if (isSplashScreen) return null;
        
        return '/login';
      }

      // 3. If authenticated
      if (isAuthenticated) {
        // If trying to access login screens, go to home
        if (isLoggingIn) return '/home';
        
        // If on splash, allow (let Splash navigate) or redirect?
        // Redirecting to home is safe if we are authenticated.
        // But Splash wants to play animation.
        if (isSplashScreen) return null;
        
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const MainScreen()),
      GoRoute(
        path: '/activity',
        builder: (context, state) => const ActivityScreen(),
      ),
      GoRoute(
        path: '/create-post',
        builder: (context, state) => const CreatePostScreen(),
      ),
      GoRoute(
        path: '/post/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PostDetailScreen(postId: id);
        },
      ),
      GoRoute(
        path: '/post/:id/edit',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EditPostScreen(postId: id);
        },
      ),
      GoRoute(
        path: '/post/:id/comments',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PostCommentsScreen(postId: id);
        },
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return UserProfileScreen(userId: id);
        },
      ),
      GoRoute(
        path: '/profile/:id/followers',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return FollowersScreen(userId: id);
        },
      ),
      GoRoute(
        path: '/profile/:id/following',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return FollowingScreen(userId: id);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/account-settings',
        builder: (context, state) => const AccountSettingsScreen(),
      ),
      GoRoute(
        path: '/privacy-settings',
        builder: (context, state) => const PrivacySettingsScreen(),
      ),
      GoRoute(
        path: '/notification-settings',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const HelpScreen(),
      ),
      GoRoute(
        path: '/camera',
        builder: (context, state) => const CameraScreen(),
      ),
      GoRoute(
        path: '/edit-image',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final imageFile = extra?['imageFile'] as File?;
          if (imageFile != null) {
            return ImageEditorScreen(imageFile: imageFile);
          }
          return const Scaffold(body: Center(child: Text('No image provided')));
        },
      ),
      GoRoute(
        path: '/edit-video',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final videoFile = extra?['videoFile'] as File?;
          if (videoFile != null) {
            // Return video editor screen when implemented
            return Scaffold(
              appBar: AppBar(title: const Text('Edit Video')),
              body: const Center(child: Text('Video Editor Coming Soon')),
            );
          }
          return const Scaffold(body: Center(child: Text('No video provided')));
        },
      ),
      GoRoute(
        path: '/chats',
        builder: (context, state) => const ChatsListScreen(),
      ),
      GoRoute(
        path: '/create-reel',
        builder: (context, state) => const CreateReelScreen(),
      ),
      GoRoute(
        path: '/live/create',
        builder: (context, state) => const LiveStreamScreen(),
      ),
      GoRoute(
        path: '/live/view/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return LiveViewerScreen(streamId: id);
        },
      ),
      GoRoute(
        path: '/live-streaming',
        builder: (context, state) => const LiveStreamingScreen(),
      ),
      GoRoute(
        path: '/create-group',
        builder: (context, state) => const CreateGroupScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ChatRoomScreen(conversationId: id);
        },
      ),
      GoRoute(
        path: '/chat-settings/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ChatSettingsScreen(conversationId: id);
        },
      ),
      GoRoute(
        path: '/edit-group/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EditGroupScreen(conversationId: id);
        },
      ),
      GoRoute(
        path: '/badges',
        builder: (context, state) => const BadgesScreen(),
      ),
      GoRoute(
        path: '/leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: '/points',
        builder: (context, state) => const PointsScreen(),
      ),
      GoRoute(
        path: '/quests',
        builder: (context, state) => const QuestsScreen(),
      ),
    ],
  );
});
