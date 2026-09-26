import 'package:flutter/material.dart';

import '../models/saved_video.dart';
import '../services/video_library_service.dart';
import '../services/app_settings.dart';
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
  List<SavedVideo> _videos = [];
  bool _loading = true;

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
  void initState() {
    super.initState();
    _loadTargetLang();
    _loadVideos();
  }

  Future<void> _loadTargetLang() async {
    final lang = await AppSettings.getTargetLanguage();
    if (mounted) setState(() => _targetLang = lang);
  }

  Future<void> _loadVideos() async {
    final videos = await VideoLibraryService.getAll();
    if (mounted) setState(() {
      _videos = videos;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadVideos,
          child: CustomScrollView(
            slivers: [
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
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),
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
                    PrimaryButton(
                      label: 'Importer une vidéo',
                      onPressed: () => _navigateToImport(context),
                      icon: Icons.add_rounded,
                    ),
                    const SizedBox(height: 24),
                    LanguageSelector(
                      value: _targetLang,
                      options: _languages,
                      onChanged: (v) {
                        setState(() => _targetLang = v);
                        AppSettings.setTargetLanguage(v);
                      },
                      label: 'Langue de traduction',
                      showFlag: true,
                    ),
                    const SizedBox(height: 32),
                    if (_loading) ...[
                      const Center(child: CircularProgressIndicator()),
                    ] else if (_videos.isNotEmpty) ...[
                      Row(
                        children: [
                          const Text(
                            'Mes vidéos',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${_videos.length}',
                            style: const TextStyle(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 220,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _videos.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final video = _videos[index];
                            final progress = video.lastPositionSeconds > 0
                                ? (video.lastPositionSeconds / 3600).clamp(0.0, 1.0)
                                : null;
                            return VideoCard(
                              title: video.title,
                              posterFilePath: video.thumbnailPath,
                              language: video.targetLang.toUpperCase(),
                              progress: progress,
                              isFavorite: video.isFavorite,
                              onTap: () => _navigateToPlayer(context, video),
                              onLongPress: () => _showVideoOptions(context, video),
                            );
                          },
                        ),
                      ),
                    ] else ...[
                      EmptyState(
                        icon: Icons.movie_rounded,
                        title: 'Aucune vidéo',
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
        onSelect: (lang) {
          setState(() => _targetLang = lang);
          AppSettings.setTargetLanguage(lang);
        },
      ),
    );
  }

  void _showVideoOptions(BuildContext context, SavedVideo video) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(
                video.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: AppTheme.error,
              ),
              title: Text(
                video.isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () async {
                await VideoLibraryService.toggleFavorite(video.id);
                if (context.mounted) Navigator.pop(context);
                _loadVideos();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: AppTheme.error),
              title: const Text('Supprimer', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () async {
                await VideoLibraryService.remove(video.id);
                if (context.mounted) Navigator.pop(context);
                _loadVideos();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _navigateToImport(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ImportScreen()),
    );
    _loadVideos();
  }

  void _navigateToPlayer(BuildContext context, SavedVideo video) async {
    final backendUrl = await AppSettings.getBackendUrl();
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerScreen(
          videoUrl: video.videoUrl,
          backendBaseUrl: backendUrl,
          targetLang: video.targetLang,
          savedVideoId: video.id,
        ),
      ),
    ).then((_) => _loadVideos());
  }
}
