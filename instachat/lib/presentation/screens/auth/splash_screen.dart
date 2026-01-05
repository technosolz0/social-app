import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/theme_constants.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _authCheckCompleted = false;
  bool _animationCompleted = false;
  String _statusText = 'Initializing...';

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    // Start animation
    _animationController.forward();

    // Start authentication check
    _checkAuthentication();

    // Listen for animation completion
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _animationCompleted = true);
        _tryNavigate();
      }
    });
  }

  Future<void> _checkAuthentication() async {
    try {
      setState(() => _statusText = 'Checking stored credentials...');

      // Check authentication status
      await ref.read(authNotifierProvider.notifier).checkAuthStatus();

      final authState = ref.read(authNotifierProvider);
      if (authState.isAuthenticated) {
        setState(() => _statusText = 'Welcome back!');
      } else {
        setState(() => _statusText = 'Please sign in');
      }
    } catch (e) {
      // Handle any errors during auth check
      debugPrint('Auth check error: $e');
      setState(() => _statusText = 'Preparing app...');
    } finally {
      if (mounted) {
        setState(() => _authCheckCompleted = true);
        _tryNavigate();
      }
    }
  }

  void _tryNavigate() {
    // Only navigate when both animation and auth check are completed
    if (_animationCompleted && _authCheckCompleted && mounted) {
      final authState = ref.read(authNotifierProvider);

      // Small delay for better UX
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          if (authState.isAuthenticated) {
            context.go('/home');
          } else {
            context.go('/login');
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo/Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppSizes.borderRadiusLarge,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.photo_camera,
                        size: 60,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),

                    const SizedBox(height: AppSizes.paddingLarge),

                    // App Name
                    const Text(
                      'Social App',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: AppSizes.paddingMedium),

                    // Tagline
                    Text(
                      'Connect & Share',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: AppSizes.paddingXLarge),

                    // Loading Indicator
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.8),
                        ),
                        strokeWidth: 3,
                      ),
                    ),

                    const SizedBox(height: AppSizes.paddingMedium),

                    // Status Text
                    AnimatedOpacity(
                      opacity: _authCheckCompleted ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _statusText,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
