import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/chat_provider.dart';        // NEW
import 'core/providers/post_provider.dart';        // NEW
import 'core/providers/study_group_provider.dart'; // NEW
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
        // Existing provider
        ChangeNotifierProvider(create: (context) => AuthProvider()),

        // Phase 2 NEW providers
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (context) => PostProvider()),
        ChangeNotifierProvider(create: (context) => StudyGroupProvider()),
      ],
      child: MaterialApp.router(
        title: 'StudyConnect',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: AppRoutes.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
