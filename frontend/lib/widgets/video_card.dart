import 'package:flutter/material.dart';
import '../theme.dart';

class VideoCard extends StatelessWidget {
  final String title;
  final String? posterUrl;
  final String language;
  final double? progress;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isFavorite;

  const VideoCard({
    super.key,
    required this.title,
    this.posterUrl,
    required this.language,
    this.progress,
    this.onTap,
    this.onLongPress,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.surface,
                image: posterUrl != null
                    ? DecorationImage(
                        image: NetworkImage(posterUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: posterUrl == null
                  ? Center(
                      child: Icon(
                        Icons.movie_rounded,
                        size: 48,
                        color: AppTheme.textSecondary.withOpacity(0.5),
                      ),
                    )
                  : Stack(
                      children: [
                        if (progress != null && progress! > 0)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress!.clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryViolet,
                                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (isFavorite)
                          Positioned(
                            top: 8,
                            right: 8,
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
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            language,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 2),
            Text(
              '${(progress! * 100).round()}% regardé',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}