import 'package:go_router/go_router.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/chat/chat_screen.dart';         // NEW
import '../../screens/posts/post_feed_screen.dart';   // NEW
import '../../screens/profile/profile_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String chat = '/chat';         // NEW
  static const String postFeed = '/posts';    // NEW
  static const String profile = '/profile';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      // Existing routes
      GoRoute(path: splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
      GoRoute(path: register, builder: (context, state) => const RegisterScreen()),
      GoRoute(path: home, builder: (context, state) => const HomeScreen()),
      GoRoute(path: profile, builder: (context, state) => const ProfileScreen()),

      // Phase 2 NEW routes
      GoRoute(
        path: chat,
        builder: (context, state) {
          final groupId = state.uri.queryParameters['groupId'] ?? '';
          return ChatScreen(groupId: groupId);
        },
      ),
      GoRoute(
        path: postFeed,
        builder: (context, state) {
          final groupId = state.uri.queryParameters['groupId'] ?? '';
          return PostFeedScreen(groupId: groupId);
        },
      ),
    ],
  );
}
