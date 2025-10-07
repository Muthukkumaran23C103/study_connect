import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_connect/core/providers/auth_provider.dart';
import 'package:study_connect/core/providers/chat_provider.dart';
import 'package:study_connect/core/providers/post_provider.dart';
import 'package:study_connect/core/providers/study_group_provider.dart';
import 'package:study_connect/services/database_service.dart';
import 'package:study_connect/core/theme/app_theme.dart';
import 'package:study_connect/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  await DatabaseService.instance.database;

  runApp(StudyConnectApp());
}

class StudyConnectApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ChatProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => PostProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => StudyGroupProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'StudyConnect',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: SplashScreen(),
      ),
    );
  }
}