import 'package:flutter/material.dart';

import 'theme.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  runApp(const CineTranslateApp());
}

class CineTranslateApp extends StatelessWidget {
  const CineTranslateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cine-Translate',
      theme: AppTheme.darkTheme,
      home: const MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
