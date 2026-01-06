import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'presentation/screens/auth/splash_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/main/main_screen.dart';
import 'presentation/screens/main/activity_screen.dart';
import 'presentation/screens/post/create_post_screen.dart';
import 'presentation/screens/post/post_detail_screen.dart';
import 'presentation/screens/profile/edit_profile_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/settings/account_settings_screen.dart';
import 'presentation/screens/settings/privacy_settings_screen.dart';
import 'presentation/screens/settings/notification_settings_screen.dart';
import 'presentation/screens/settings/help_screen.dart';
import 'presentation/screens/camera/camera_screen.dart';
import 'presentation/screens/chat/chats_list_screen.dart';
import 'presentation/screens/chat/chat_room_screen.dart';
import 'presentation/screens/chat/create_group_screen.dart';
import 'presentation/screens/chat/chat_settings_screen.dart';
import 'presentation/screens/chat/edit_group_screen.dart';
import 'presentation/screens/gamification/badges_screen.dart';
import 'presentation/screens/gamification/leaderboard_screen.dart';
import 'presentation/screens/gamification/points_screen.dart';
import 'presentation/screens/gamification/quests_screen.dart';

import 'presentation/screens/profile/user_profile_screen.dart';
import 'presentation/screens/profile/followers_screen.dart';
import 'presentation/screens/profile/following_screen.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';

class SocialApp extends ConsumerWidget {
  const SocialApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = _createRouter(ref);
    final appThemeMode = ref.watch(themeNotifierProvider);

    return MaterialApp.router(
      title: 'Social App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appThemeMode == AppThemeMode.light
          ? ThemeMode.light
          : appThemeMode == AppThemeMode.dark
              ? ThemeMode.dark
              : ThemeMode.system,
      routerConfig: router,
    );
  }

  GoRouter _createRouter(WidgetRef ref) {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final authState = ref.read(authNotifierProvider);
        final isAuthenticated = authState.isAuthenticated;
        final isSplashScreen = state.matchedLocation == '/';
        final isLoggingIn =
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';

        // 1. If currently checking auth, stay on Splash
        if (authState.isLoading || isSplashScreen) return null;

        // 2. If not authenticated and not on login/register, go to login
        if (!isAuthenticated && !isLoggingIn) {
          return '/login';
        }

        // 3. If authenticated and on login/register, go to home
        if (isAuthenticated && isLoggingIn) {
          return '/home';
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
          path: '/chats',
          builder: (context, state) => const ChatsListScreen(),
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
  }
}
