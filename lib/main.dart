import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  // Note: firebase_options.dart will be generated after Firebase setup
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Register Hive adapters
  // TODO: Register adapters after code generation
  // Hive.registerAdapter(UserAdapter());
  // Hive.registerAdapter(TrainingSessionAdapter());
  // Hive.registerAdapter(EndAdapter());
  // Hive.registerAdapter(ArrowAdapter());
  // Hive.registerAdapter(TargetFaceAdapter());

  // Open Hive boxes
  await Hive.openBox(AppConstants.cacheBoxName);

  // Run the app
  runApp(
    const ProviderScope(
      child: ArcheryApp(),
    ),
  );
}
