import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/profile/profile_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      // Splash Screen
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Authentication Routes
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main App Routes
      GoRoute(
        path: home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: profile,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],

    // Redirect logic
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = authProvider.isAuthenticated;
      final isOnSplash = state.matchedLocation == splash;
      final isOnAuth = state.matchedLocation == login || state.matchedLocation == register;

      // If user is not logged in and not on auth pages, redirect to login
      if (!isLoggedIn && !isOnAuth && !isOnSplash) {
        return login;
      }

      // If user is logged in and on auth pages, redirect to home
      if (isLoggedIn && isOnAuth) {
        return home;
      }

      return null; // No redirect needed
    },

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you requested could not be found.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go(home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}