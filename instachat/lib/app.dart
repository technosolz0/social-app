import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'presentation/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';

class SocialApp extends ConsumerWidget {
  const SocialApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch routes provider (it won't rebuild constantly now)
    final router = ref.watch(routerProvider);
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
}
