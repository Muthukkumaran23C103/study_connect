import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/database_service.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/post_provider.dart';
import '../providers/study_group_provider.dart';
import '../theme/app_theme.dart';
import '../../screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  await DatabaseService.instance.database;

  runApp(const StudyConnectApp());
}

class StudyConnectApp extends StatelessWidget {
  const StudyConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (context) => PostProvider()),
        ChangeNotifierProvider(create: (context) => StudyGroupProvider()),
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