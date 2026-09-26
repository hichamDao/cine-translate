import 'package:flutter/material.dart';

import '../widgets.dart';
import '../theme.dart';
import 'player_screen.dart';
import 'import_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _targetLang = 'fr';
  final List<RecentMovie> _recentMovies = [
    RecentMovie(
      title: 'Interstellar',
      posterUrl: 'https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
      language: 'Français',
      progress: 0.82,
    ),
    RecentMovie(
      title: 'The Matrix',
      posterUrl: 'https://image.tmdb.org/t/p/w500/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg',
      language: 'Français',
      progress: 0.45,
    ),
    RecentMovie(
      title: 'Inception',
      posterUrl: 'https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg',
      language: 'Français',
      progress: 0.12,
    ),
  ];

  static final List<LanguageOption> _languages = [
    LanguageOption(code: 'fr', name: 'Français', flag: '🇫🇷'),
    LanguageOption(code: 'en', name: 'English', flag: '🇬🇧'),
    LanguageOption(code: 'es', name: 'Español', flag: '🇪🇸'),
    LanguageOption(code: 'de', name: 'Deutsch', flag: '🇩🇪'),
    LanguageOption(code: 'it', name: 'Italiano', flag: '🇮🇹'),
    LanguageOption(code: 'pt', name: 'Português', flag: '🇵🇹'),
    LanguageOption(code: 'ar', name: 'العربية', flag: '🇸🇦'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App bar
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'CINE-TRANSLATE',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () => _showLanguageModal(context),
                  icon: const Icon(Icons.translate_rounded, size: 24),
                ),
                const SizedBox(width: 8),
              ],
            ),
            // Content
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  // Hero section
                  Text(
                    'Traduisez vos films\ndans votre langue.',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Import video button
                  PrimaryButton(
                    label: 'Importer une vidéo',
                    onPressed: () => _navigateToImport(context),
                    icon: Icons.add_rounded,
                  ),
                  const SizedBox(height: 24),
                  // Language selector
                  LanguageSelector(
                    value: _targetLang,
                    options: _languages,
                    onChanged: (v) => setState(() => _targetLang = v),
                    label: 'Langue de traduction',
                    showFlag: true,
                  ),
                  const SizedBox(height: 32),
                  // Recent movies
                  if (_recentMovies.isNotEmpty) ...[
                    Row(
                      children: [
                        const Text(
                          'Films récents',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Voir tout'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _recentMovies.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final movie = _recentMovies[index];
                          return VideoCard(
                            title: movie.title,
                            posterUrl: movie.posterUrl,
                            language: movie.language,
                            progress: movie.progress,
                            onTap: () => _navigateToPlayer(context, movie),
                          );
                        },
                      ),
                    ),
                  ] else ...[
                    EmptyState(
                      icon: Icons.movie_rounded,
                      title: 'Aucun film récent',
                      subtitle: 'Importez votre première vidéo pour commencer',
                      actionLabel: 'Importer une vidéo',
                      onAction: () => _navigateToImport(context),
                    ),
                  ],
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LanguageSelectorModal(
        currentLanguage: _targetLang,
        languages: _languages,
        onSelect: (lang) => setState(() => _targetLang = lang),
      ),
    );
  }

  void _navigateToImport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ImportScreen()),
    );
  }

  void _navigateToPlayer(BuildContext context, RecentMovie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerScreen(
          videoUrl: movie.posterUrl ?? '',
          backendBaseUrl: 'ws://192.168.11.172:8000',
          targetLang: _targetLang,
        ),
      ),
    );
  }
}

class RecentMovie {
  final String title;
  final String? posterUrl;
  final String language;
  final double progress;

  RecentMovie({
    required this.title,
    this.posterUrl,
    required this.language,
    required this.progress,
  });
}