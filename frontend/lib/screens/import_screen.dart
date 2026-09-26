import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../widgets.dart';
import '../theme.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  File? _selectedVideo;
  VideoPlayerController? _previewController;
  ImportStage _stage = ImportStage.idle;
  double _progress = 0.0;
  String _progressTitle = '';
  String _progressSubtitle = '';
  bool _isIndeterminate = false;

  @override
  void dispose() {
    _previewController?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowedExtensions: ['mp4', 'mov', 'mkv', 'avi'],
        allowMultiple: false,
        withReadStream: true,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedVideo = File(result.files.single.path!);
          _stage = ImportStage.preview;
        });
        _initPreview();
      } else if (result != null && result.files.single.bytes != null) {
        // Handle case where path is not available but bytes are (some platforms)
        _showError('Fichier sélectionné mais chemin non disponible. Essayez un autre fichier.');
      }
    } on PlatformException catch (e) {
      _showError('Erreur de plateforme: ${e.message} (code: ${e.code})');
    } catch (e) {
      _showError('Erreur lors de la sélection: $e');
    }
  }

  void _initPreview() {
    if (_selectedVideo == null) return;
    _previewController = VideoPlayerController.file(_selectedVideo!);
    _previewController!.initialize().then((_) {
      if (mounted) setState(() {});
    });
  }

  void _startAnalysis() {
    setState(() {
      _stage = ImportStage.analyzing;
      _progress = 0.0;
      _progressTitle = 'Analyse de la vidéo...';
      _progressSubtitle = 'Extraction de l\'audio et détection des dialogues';
      _isIndeterminate = true;
    });

    _simulateProgress();
  }

  void _simulateProgress() async {
    const steps = [
      (0.2, 'Analyse de la vidéo...', 'Extraction de l\'audio'),
      (0.4, 'Analyse de la vidéo...', 'Détection des dialogues'),
      (0.6, 'Traitement audio...', 'Reconnaissance vocale en cours'),
      (0.8, 'Traitement audio...', 'Génération des sous-titres'),
      (1.0, 'Terminé !', 'Prêt pour la traduction'),
    ];

    for (final (progress, title, subtitle) in steps) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() {
        _progress = progress;
        _progressTitle = title;
        _progressSubtitle = subtitle;
        _isIndeterminate = progress < 1.0;
      });
    }

    if (mounted) {
      setState(() {
        _stage = ImportStage.complete;
      });
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.check_rounded, color: AppTheme.success, size: 32),
            ),
            const SizedBox(height: 20),
            const Text(
              'Vidéo prête !',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'La vidéo a été analysée. Vous pouvez maintenant la lire avec traduction en temps réel.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Commencer la traduction',
              onPressed: () {
                Navigator.pop(context);
                _navigateToPlayer();
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _selectedVideo = null;
                  _stage = ImportStage.idle;
                });
              },
              child: const Text('Importer une autre vidéo'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPlayer() {
    // In real app, navigate to player with the video
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigation vers le lecteur (à implémenter)'),
        backgroundColor: AppTheme.primaryViolet,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Importation'),
        backgroundColor: AppTheme.surface,
        leading: _stage != ImportStage.idle
            ? IconButton(
                onPressed: () {
                  if (_stage == ImportStage.preview) {
                    setState(() {
                      _selectedVideo = null;
                      _stage = ImportStage.idle;
                    });
                  } else if (_stage == ImportStage.complete) {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_stage) {
      case ImportStage.idle:
        return Center(
          child: VideoImportArea(onTap: _pickVideo),
        );
      case ImportStage.preview:
        return _buildPreview();
      case ImportStage.analyzing:
        return ImportProgressOverlay(
          title: _progressTitle,
          subtitle: _progressSubtitle,
          progress: _progress,
          isIndeterminate: _isIndeterminate,
        );
      case ImportStage.complete:
        return ImportProgressOverlay(
          title: _progressTitle,
          subtitle: _progressSubtitle,
          progress: 1.0,
          isIndeterminate: false,
        );
    }
  }

  Widget _buildPreview() {
    return Column(
      children: [
        // Video preview
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _previewController != null && _previewController!.value.isInitialized
                ? VideoPlayer(_previewController!)
                : Container(
                    color: AppTheme.surface,
                    child: const Center(child: CircularProgressIndicator(color: AppTheme.primaryViolet)),
                  ),
          ),
        ),
        const SizedBox(height: 24),
        // File info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.videocam_rounded, color: AppTheme.primaryViolet, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedVideo?.path.split('/').last ?? 'Vidéo sélectionnée',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatFileSize(_selectedVideo?.lengthSync() ?? 0),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() {
                  _selectedVideo = null;
                  _stage = ImportStage.idle;
                }),
                icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() {
                  _selectedVideo = null;
                  _stage = ImportStage.idle;
                }),
                child: const Text('Annuler'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PrimaryButton(
                label: 'Analyser et traduire',
                onPressed: _startAnalysis,
                icon: Icons.analytics_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

enum ImportStage {
  idle,
  preview,
  analyzing,
  complete,
}