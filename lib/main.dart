import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// Simple theme for testing
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      textTheme: GoogleFonts.interTextTheme(),
      primarySwatch: Colors.blue,
    );
  }
}

void main() {
  runApp(const StudyConnectApp());
}

class StudyConnectApp extends StatelessWidget {
  const StudyConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyConnect',
      theme: AppTheme.lightTheme,
      home: const TestScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.school,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'StudyConnect',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Phase 1 - Setup Complete!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ready to implement full features!'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Test Button'),
            ),
          ],
        ),
      ),
    );
  }
}