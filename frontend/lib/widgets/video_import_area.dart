import 'package:flutter/material.dart';
import '../theme.dart';

class VideoImportArea extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDragging;

  const VideoImportArea({
    super.key,
    required this.onTap,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        decoration: BoxDecoration(
          color: isDragging ? AppTheme.primaryViolet.withOpacity(0.15) : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDragging ? AppTheme.primaryViolet : Colors.white10,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDragging ? AppTheme.primaryViolet : AppTheme.primaryViolet.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.add_rounded,
                size: 32,
                color: isDragging ? AppTheme.textPrimary : AppTheme.primaryViolet,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Sélectionner une vidéo',
              style: TextStyle(
                color: isDragging ? AppTheme.primaryViolet : AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'MP4 · MOV · MKV · AVI',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}