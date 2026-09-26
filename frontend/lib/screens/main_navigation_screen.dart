import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildNavNavigator(0, const HomeScreen()),
          _buildNavNavigator(1, const HistoryScreen()),
          _buildNavNavigator(2, const PlayerScreenPlaceholder()),
          _buildNavNavigator(3, const FavoritesScreen()),
          _buildNavNavigator(4, const SettingsScreen()),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildNavNavigator(int index, Widget child) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (settings) => MaterialPageRoute(builder: (_) => child),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: Colors.white10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded, size: 24),
              activeIcon: Icon(Icons.home_rounded, size: 24, fill: 1.0),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded, size: 24),
              activeIcon: Icon(Icons.history_rounded, size: 24, fill: 1.0),
              label: 'Historique',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.movie_rounded, size: 24),
              activeIcon: Icon(Icons.movie_rounded, size: 24, fill: 1.0),
              label: 'Lecteur',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_rounded, size: 24),
              activeIcon: Icon(Icons.favorite_rounded, size: 24, fill: 1.0),
              label: 'Favoris',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded, size: 24),
              activeIcon: Icon(Icons.settings_rounded, size: 24, fill: 1.0),
              label: 'Réglages',
            ),
          ],
        ),
      ),
    );
  }
}

class PlayerScreenPlaceholder extends StatelessWidget {
  const PlayerScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Lecteur'),
        backgroundColor: AppTheme.surface,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.movie_filter_rounded,
                size: 40,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucune vidéo en cours',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Importez une vidéo depuis l\'accueil pour commencer',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Importer une vidéo',
              onPressed: () {
                // Navigate to home tab
              },
              icon: Icons.add_rounded,
              expanded: false,
            ),
          ],
        ),
      ),
    );
  }
}