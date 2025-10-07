import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/chat_provider.dart';
import 'core/providers/post_provider.dart';
import 'core/providers/study_group_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StudyConnectApp());
}

class StudyConnectApp extends StatelessWidget {
  const StudyConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider<ChatProvider>(
          create: (context) => ChatProvider(),
        ),
        ChangeNotifierProvider<PostProvider>(
          create: (context) => PostProvider(),
        ),
        ChangeNotifierProvider<StudyGroupProvider>(
          create: (context) => StudyGroupProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'StudyConnect',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
