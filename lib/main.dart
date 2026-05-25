import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/responsive_layout.dart';
import 'features/home/home_screen.dart';
import 'features/materials/materials_screen.dart';
import 'features/quiz/quiz_screen.dart';
import 'features/profile/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- SUPABASE INITIALIZATION WITH SAFE MOCK FALLBACK ---
  bool supabaseConfigured = false;
  try {
    const String supabaseUrl = String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://placeholder.supabase.co',
    );
    const String supabaseKey = String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'placeholder',
    );

    if (supabaseUrl != 'https://placeholder.supabase.co') {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseKey,
      );
      supabaseConfigured = true;
    }
  } catch (e) {
    debugPrint('Supabase failed to initialize. Falling back to offline mock mode.');
  }

  runApp(SantAcademyApp(isDbConfigured: supabaseConfigured));
}

class SantAcademyApp extends StatefulWidget {
  final bool isDbConfigured;
  const SantAcademyApp({super.key, required this.isDbConfigured});

  @override
  State<SantAcademyApp> createState() => _SantAcademyAppState();
}

class _SantAcademyAppState extends State<SantAcademyApp> {
  ThemeMode _themeMode = ThemeMode.dark; // Default to dark mode for premium look
  String _selectedBoard = 'BSEB';       // BSEB (Bihar Board) or CBSE
  String _selectedClass = '10th';       // 9th, 10th, 11th, 12th

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void updateSettings(String board, String classLevel) {
    setState(() {
      _selectedBoard = board;
      _selectedClass = classLevel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sant Academy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: ResponsiveLayout(
        tabNames: const ['Home', 'Study Notes', 'Practice Test', 'Profile'],
        screens: [
          HomeScreen(selectedBoard: _selectedBoard, selectedClass: _selectedClass),
          MaterialsScreen(selectedBoard: _selectedBoard, selectedClass: _selectedClass),
          QuizScreen(selectedBoard: _selectedBoard, selectedClass: _selectedClass),
          ProfileScreen(
            selectedBoard: _selectedBoard, 
            selectedClass: _selectedClass,
            onSettingsChanged: updateSettings,
          ),
        ],
        headerActions: IconButton(
          icon: Icon(
            _themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
            size: 20,
          ),
          onPressed: toggleTheme,
        ),
      ),
    );
  }
}
