import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textOpacityAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Logo animations
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    ));

    // Text animations
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    _startAnimations();
  }

  void _startAnimations() async {
    // Load user session
    await Provider.of<AuthProvider>(context, listen: false).loadUserSession();

    // Start logo animation
    _logoController.forward();

    // Start text animation after delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _textController.forward();
      }
    });

    // Navigate after animations
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        _navigateToNext();
      }
    });
  }

  void _navigateToNext() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isAuthenticated) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Animation
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: Opacity(
                      opacity: _logoOpacityAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          size: 64,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Text Animation
              SlideTransition(
                position: _textSlideAnimation,
                child: FadeTransition(
                  opacity: _textOpacityAnimation,
                  child: Column(
                    children: [
                      Text(
                        'StudyConnect',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Connect • Study • Succeed',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 64),

              // Loading Animation
              SlideTransition(
                position: _textSlideAnimation,
                child: FadeTransition(
                  opacity: _textOpacityAnimation,
                  child: Column(
                    children: [
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
                      const SizedBox(height: 16),
                      Text(
                        'Loading...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}