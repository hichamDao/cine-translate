import 'package:flutter/material.dart';

import '../widgets.dart';
import '../theme.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  static final List<FavoriteMovie> _favorites = [
    FavoriteMovie(
      title: 'Interstellar',
      posterUrl: 'https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
      language: 'Français',
      addedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    FavoriteMovie(
      title: 'The Matrix',
      posterUrl: 'https://image.tmdb.org/t/p/w500/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg',
      language: 'Français',
      addedAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    FavoriteMovie(
      title: 'Inception',
      posterUrl: 'https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg',
      language: 'Français',
      addedAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Favoris'),
        backgroundColor: AppTheme.surface,
      ),
      body: SafeArea(
        child: _favorites.isEmpty
            ? EmptyState(
                icon: Icons.favorite_rounded,
                title: 'Aucun favori',
                subtitle: 'Ajoutez des films à vos favoris pour les retrouver facilement',
                actionLabel: 'Découvrir des films',
                onAction: () {},
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _favorites.length,
                itemBuilder: (context, index) {
                  final movie = _favorites[index];
                  return _FavoriteCard(movie: movie);
                },
              ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final FavoriteMovie movie;

  const _FavoriteCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to player
      },
      onLongPress: () {
        _showRemoveDialog(context);
      },
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
                    child: movie.posterUrl != null
                        ? Image.network(
                            movie.posterUrl!,
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
                    onTap: () => _showRemoveDialog(context),
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
                    movie.title,
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
                    movie.language,
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

  void _showRemoveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Retirer des favoris', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'Voulez-vous retirer "${movie.title}" de vos favoris ?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${movie.title} retiré des favoris'),
                  backgroundColor: AppTheme.primaryViolet,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: const Text('Retirer', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

class FavoriteMovie {
  final String title;
  final String? posterUrl;
  final String language;
  final DateTime addedAt;

  FavoriteMovie({
    required this.title,
    this.posterUrl,
    required this.language,
    required this.addedAt,
  });
}