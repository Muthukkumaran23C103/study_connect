import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// Core imports
import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/chat_provider.dart';
import 'core/providers/post_provider.dart';
import 'core/providers/study_group_provider.dart';
import 'services/database_service.dart';

// Screen imports
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/posts/post_feed_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  final databaseService = DatabaseService();
  await databaseService.initializeDatabase();

  runApp(StudyConnectApp(databaseService: databaseService));
}

class StudyConnectApp extends StatelessWidget {
  final DatabaseService databaseService;

  const StudyConnectApp({
    super.key,
    required this.databaseService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Database Service
        Provider<DatabaseService>.value(value: databaseService),

        // Auth Provider
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(databaseService),
        ),

        // Phase 2 Providers
        ChangeNotifierProvider<ChatProvider>(
          create: (context) => ChatProvider(databaseService),
        ),

        ChangeNotifierProvider<PostProvider>(
          create: (context) => PostProvider(databaseService),
        ),

        ChangeNotifierProvider<StudyGroupProvider>(
          create: (context) => StudyGroupProvider(databaseService),
        ),
      ],
      child: MaterialApp(
        title: 'StudyConnect',
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
        onGenerateRoute: (settings) {
          // Handle dynamic routes
          if (settings.name?.startsWith('/chat/') == true) {
            final groupIdStr = settings.name?.split('/').last;
            final groupId = int.tryParse(groupIdStr ?? '');
            if (groupId != null) {
              return MaterialPageRoute(
                builder: (context) => ChatScreen(groupId: groupId),
              );
            }
          }

          if (settings.name?.startsWith('/posts/') == true) {
            final groupIdStr = settings.name?.split('/').last;
            final groupId = int.tryParse(groupIdStr ?? '');
            if (groupId != null) {
              return MaterialPageRoute(
                builder: (context) => PostFeedScreen(groupId: groupId),
              );
            }
          }

          return null;
        },
      ),
    );
  }
}
