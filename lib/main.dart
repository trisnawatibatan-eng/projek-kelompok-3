import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'screens/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://syvdyvrgqulrncwwqspf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN5dmR5dnJncXVscm5jd3dxc3BmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc3MjQwOTcsImV4cCI6MjA5MzMwMDA5N30.Sfdg4W5tOzmhxgBSXc80ii4bzezKIZh9xcGqobuNPP0',
  );
  
  runApp(const FisioCareApp());
}

class FisioCareApp extends StatelessWidget {
  const FisioCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FisioCare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}
