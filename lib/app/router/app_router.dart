import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/session_logger/presentation/screens/session_list_screen.dart';
import '../../features/session_logger/presentation/screens/session_create_screen.dart';
import '../../features/session_logger/presentation/screens/session_detail_screen.dart';
import '../../features/session_logger/presentation/screens/end_logger_screen.dart';
import '../../features/target_analyzer/presentation/screens/image_capture_screen.dart';
import '../../features/target_analyzer/presentation/screens/analyzer_result_screen.dart';
import '../../features/statistics/presentation/screens/stats_dashboard_screen.dart';
import '../../features/statistics/presentation/screens/grouping_heatmap_screen.dart';

/// Application router for navigation
class AppRouter {
  AppRouter._(); // Private constructor

  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String sessionList = '/sessions';
  static const String sessionDetail = '/session-detail';
  static const String sessionCreate = '/session-create';
  static const String endLogger = '/end-logger';
  static const String cameraCapture = '/camera-capture';
  static const String analyzerResult = '/analyzer-result';
  static const String profile = '/profile';
  static const String statistics = '/statistics';
  static const String statsDashboard = '/stats-dashboard';
  static const String groupingHeatmap = '/grouping-heatmap';

  /// Generate routes
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        // TODO: Replace with SplashScreen when ready
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case home:
      case sessionList:
        return MaterialPageRoute(
          builder: (_) => const SessionListScreen(),
        );

      case sessionCreate:
        return MaterialPageRoute(
          builder: (_) => const SessionCreateScreen(),
        );

      case sessionDetail:
        final sessionId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => SessionDetailScreen(sessionId: sessionId),
        );

      case endLogger:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => EndLoggerScreen(
            sessionId: args['sessionId'] as String,
            endNumber: args['endNumber'] as int,
          ),
        );

      case cameraCapture:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ImageCaptureScreen(
            sessionId: args['sessionId'] as String,
            endId: args['endId'] as String,
          ),
        );

      case analyzerResult:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => AnalyzerResultScreen(
            imagePath: args['imagePath'] as String,
            sessionId: args['sessionId'] as String,
            endId: args['endId'] as String,
          ),
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );

      case statsDashboard:
        return MaterialPageRoute(
          builder: (_) => const StatsDashboardScreen(),
        );

      case groupingHeatmap:
        return MaterialPageRoute(
          builder: (_) => const GroupingHeatmapScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  /// Navigate to login screen
  static void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(login);
  }

  /// Navigate to home screen
  static void navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(home);
  }

  /// Navigate to session detail
  static void navigateToSessionDetail(
    BuildContext context,
    String sessionId,
  ) {
    Navigator.of(context).pushNamed(
      sessionDetail,
      arguments: sessionId,
    );
  }

  /// Navigate to end logger
  static void navigateToEndLogger(
    BuildContext context,
    String sessionId,
    int endNumber,
  ) {
    Navigator.of(context).pushNamed(
      endLogger,
      arguments: {
        'sessionId': sessionId,
        'endNumber': endNumber,
      },
    );
  }

  /// Navigate to camera capture
  static void navigateToCameraCapture(
    BuildContext context,
    String sessionId,
    String endId,
  ) {
    Navigator.of(context).pushNamed(
      cameraCapture,
      arguments: {
        'sessionId': sessionId,
        'endId': endId,
      },
    );
  }
}
