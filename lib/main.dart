import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/chat_provider.dart';
import 'core/providers/post_provider.dart';
import 'core/providers/study_group_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'screens/splash/splash_screen.dart';

void main() {
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
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        // FIXED: Added proper route generation
        onGenerateRoute: AppRoutes.generateRoute,
        initialRoute: AppRoutes.splash,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}