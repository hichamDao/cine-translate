import 'dart:io';
import 'package:flutter/material.dart';

import '../models/saved_video.dart';
import '../services/video_library_service.dart';
import '../services/app_settings.dart';
import '../widgets.dart';
import '../theme.dart';
import 'player_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<SavedVideo> _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final favorites = await VideoLibraryService.getFavorites();
    if (mounted) setState(() {
      _favorites = favorites;
      _loading = false;
    });
  }

  Future<void> _openPlayer(SavedVideo video) async {
    final backendUrl = await AppSettings.getBackendUrl();
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerScreen(
          videoUrl: video.videoUrl,
          backendBaseUrl: backendUrl,
          targetLang: video.targetLang,
          savedVideoId: video.id,
        ),
      ),
    );
    _load();
  }

  void _confirmRemove(SavedVideo video) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Retirer des favoris', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'Voulez-vous retirer "${video.title}" de vos favoris ?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await VideoLibraryService.toggleFavorite(video.id);
              _load();
            },
            child: const Text('Retirer', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Favoris'),
        backgroundColor: AppTheme.surface,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _favorites.isEmpty
                ? EmptyState(
                    icon: Icons.favorite_rounded,
                    title: 'Aucun favori',
                    subtitle: 'Ajoutez des vidéos à vos favoris pour les retrouver facilement',
                    actionLabel: 'Retour à l\'accueil',
                    onAction: () => Navigator.pop(context),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _favorites.length,
                      itemBuilder: (context, index) {
                        final video = _favorites[index];
                        return _FavoriteCard(
                          video: video,
                          onTap: () => _openPlayer(video),
                          onRemove: () => _confirmRemove(video),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final SavedVideo video;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriteCard({required this.video, required this.onTap, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onRemove,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppTheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 2 / 3,
                    child: video.thumbnailPath != null
                        ? Image.file(
                            File(video.thumbnailPath!),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppTheme.surface,
                              child: const Icon(Icons.movie_rounded, color: AppTheme.textSecondary),
                            ),
                          )
                        : Container(
                            color: AppTheme.surface,
                            child: const Icon(Icons.movie_rounded, color: AppTheme.textSecondary),
                          ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: AppTheme.error,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    video.targetLang.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
