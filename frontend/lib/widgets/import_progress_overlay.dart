import 'package:flutter/material.dart';
import '../theme.dart';

class ImportProgressOverlay extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress; // 0.0 to 1.0
  final bool isIndeterminate;

  const ImportProgressOverlay({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    this.isIndeterminate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryViolet.withOpacity(0.2),
                      AppTheme.accentBlue.withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.movie_filter_rounded,
                  size: 40,
                  color: AppTheme.primaryViolet,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              if (isIndeterminate)
                const CircularProgressIndicator(
                  color: AppTheme.primaryViolet,
                  strokeWidth: 3,
                )
              else ...[
                SizedBox(
                  width: double.infinity,
                  height: 6,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppTheme.surface,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryViolet),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}