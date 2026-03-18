import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'user_selection_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://mmlpmiqzwbpuntpstrdz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1tbHBtaXF6d2JwdW50cHN0cmR6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg5MzIwNTIsImV4cCI6MjA4NDUwODA1Mn0.1UHDyI9qmD-6Pjm_E9o7Hq6A9BuXRipCgQ6Hf8LWZEc',
  );

  // Restore navigation buttons but configure their appearance for the theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vehicle & Driver Elite',
      theme: AppTheme.themeData,
      home: const UserSelectionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
