import 'package:flutter/material.dart';

import '../widgets.dart';
import '../theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  static final List<HistoryItem> _history = [
    HistoryItem(
      title: 'Interstellar',
      posterUrl: 'https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
      language: 'Français',
      progress: 0.82,
      lastWatched: DateTime.now().subtract(const Duration(days: 2)),
    ),
    HistoryItem(
      title: 'The Matrix',
      posterUrl: 'https://image.tmdb.org/t/p/w500/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg',
      language: 'Français',
      progress: 0.45,
      lastWatched: DateTime.now().subtract(const Duration(days: 5)),
    ),
    HistoryItem(
      title: 'Inception',
      posterUrl: 'https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg',
      language: 'Français',
      progress: 0.12,
      lastWatched: DateTime.now().subtract(const Duration(days: 10)),
    ),
    HistoryItem(
      title: 'Blade Runner 2049',
      posterUrl: 'https://image.tmdb.org/t/p/w500/gajva96ISrVW8FDsO7x3OjvrtsJ.jpg',
      language: 'English',
      progress: 0.67,
      lastWatched: DateTime.now().subtract(const Duration(days: 15)),
    ),
    HistoryItem(
      title: 'Dune',
      posterUrl: 'https://image.tmdb.org/t/p/w500/jYEW2xGT37CudPvKGWKR4MWjYQG.jpg',
      language: 'Français',
      progress: 1.0,
      lastWatched: DateTime.now().subtract(const Duration(days: 20)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Historique'),
        backgroundColor: AppTheme.surface,
      ),
      body: SafeArea(
        child: _history.isEmpty
            ? EmptyState(
                icon: Icons.history_rounded,
                title: 'Aucun historique',
                subtitle: 'Les films que vous regardez apparaîtront ici',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _history[index];
                  return _HistoryTile(item: item);
                },
              ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final HistoryItem item;

  const _HistoryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to player
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: item.posterUrl != null
                    ? Image.network(
                        item.posterUrl!,
                        fit: BoxFit.cover,
                        width: 100,
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryViolet.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.language,
                            style: const TextStyle(
                              color: AppTheme.primaryViolet,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(item.lastWatched),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (item.progress > 0) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: item.progress,
                                backgroundColor: Colors.white10,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryViolet),
                                minHeight: 4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(item.progress * 100).round()}%',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Aujourd\'hui';
    if (diff == 1) return 'Hier';
    if (diff < 7) return 'Il y a $diff jours';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class HistoryItem {
  final String title;
  final String? posterUrl;
  final String language;
  final double progress;
  final DateTime lastWatched;

  HistoryItem({
    required this.title,
    this.posterUrl,
    required this.language,
    required this.progress,
    required this.lastWatched,
  });
}