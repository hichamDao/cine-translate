import 'dart:io';
import 'package:flutter/material.dart';

import '../models/saved_video.dart';
import '../services/video_library_service.dart';
import '../services/app_settings.dart';
import '../widgets.dart';
import '../theme.dart';
import 'player_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<SavedVideo> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final history = await VideoLibraryService.getHistory();
    if (mounted) setState(() {
      _history = history;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Historique'),
        backgroundColor: AppTheme.surface,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _history.isEmpty
                ? const EmptyState(
                    icon: Icons.history_rounded,
                    title: 'Aucun historique',
                    subtitle: 'Les vidéos que vous regardez apparaîtront ici',
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _history.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final video = _history[index];
                        return _HistoryTile(
                          video: video,
                          onTap: () => _openPlayer(video),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final SavedVideo video;
  final VoidCallback onTap;

  const _HistoryTile({required this.video, required this.onTap});

  // Estimation grossiere de progression : sans duree totale connue de la
  // video, on affiche juste la position de reprise en minutes plutot
  // qu'un pourcentage (qui serait invente).
  String _formatPosition(double seconds) {
    final minutes = (seconds / 60).floor();
    final secs = (seconds % 60).round();
    return '${minutes}m${secs.toString().padLeft(2, '0')}s';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                child: video.thumbnailPath != null
                    ? Image.file(
                        File(video.thumbnailPath!),
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
                      video.title,
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
                            video.targetLang.toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.primaryViolet,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(video.lastWatched!),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (video.lastPositionSeconds > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Repris à ${_formatPosition(video.lastPositionSeconds)}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
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
