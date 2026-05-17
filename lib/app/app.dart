import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';

/// Root application widget
class ArcheryApp extends StatelessWidget {
  const ArcheryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Height Banana - Archery Analytics',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

/// Temporary splash screen while Firebase initializes
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.gps_fixed,
              size: 80,
              color: AppTheme.primaryGold,
            ),
            const SizedBox(height: 24),
            Text(
              'Height Banana',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Archery Analytics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryGold,
                  ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: AppTheme.primaryGold,
            ),
          ],
        ),
      ),
    );
  }
}
