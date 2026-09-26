import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../models/saved_video.dart';
import '../services/video_library_service.dart';
import '../services/app_settings.dart';
import '../widgets.dart';
import '../theme.dart';
import 'player_screen.dart';

/// Ecran d'ajout d'une video : on reste 100% sur une URL directe (pas de
/// fichier local), conformement au fonctionnement reel du backend (qui lit
/// l'URL lui-meme, sans jamais recevoir ni stocker la video).
class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();
  String? _thumbnailPath;
  bool _isCheckingUrl = false;
  String? _urlError;
  VideoPlayerController? _previewController;

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _previewController?.dispose();
    super.dispose();
  }

  Future<void> _pickThumbnail() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
    if (picked == null) return;

    // On copie l'image choisie dans le dossier documents de l'app : le
    // chemin temporaire renvoye par image_picker n'est pas garanti de
    // survivre au redemarrage de l'app sur toutes les plateformes.
    final docsDir = await getApplicationDocumentsDirectory();
    final fileName = 'thumb_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedFile = await File(picked.path).copy('${docsDir.path}/$fileName');

    if (mounted) setState(() => _thumbnailPath = savedFile.path);
  }

  Future<void> _testUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _urlError = 'Entrez une URL');
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.isScheme('HTTP') || uri.isScheme('HTTPS'))) {
      setState(() => _urlError = 'URL invalide (doit commencer par http:// ou https://)');
      return;
    }

    setState(() {
      _isCheckingUrl = true;
      _urlError = null;
    });

    _previewController?.dispose();
    _previewController = VideoPlayerController.networkUrl(uri);
    try {
      await _previewController!.initialize().timeout(const Duration(seconds: 12));
      if (mounted) {
        setState(() => _isCheckingUrl = false);
        if (_titleController.text.trim().isEmpty) {
          _titleController.text = _guessTitleFromUrl(url);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingUrl = false;
          _urlError = 'Impossible de lire cette URL (vérifiez qu\'elle pointe vers un fichier vidéo direct).';
        });
      }
    }
  }

  String _guessTitleFromUrl(String url) {
    try {
      final segments = Uri.parse(url).pathSegments;
      if (segments.isNotEmpty) {
        return segments.last.replaceAll(RegExp(r'\.(mp4|mov|mkv|avi|m3u8)$', caseSensitive: false), '');
      }
    } catch (_) {}
    return 'Vidéo sans titre';
  }

  Future<void> _saveAndPlay() async {
    final url = _urlController.text.trim();
    if (url.isEmpty || _previewController == null || !_previewController!.value.isInitialized) {
      setState(() => _urlError = 'Testez d\'abord l\'URL avec le bouton ci-dessus');
      return;
    }

    final targetLang = await AppSettings.getTargetLanguage();
    final backendUrl = await AppSettings.getBackendUrl();

    final video = SavedVideo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim().isEmpty
          ? _guessTitleFromUrl(url)
          : _titleController.text.trim(),
      videoUrl: url,
      thumbnailPath: _thumbnailPath,
      targetLang: targetLang,
    );

    await VideoLibraryService.add(video);

    if (!mounted) return;
    Navigator.pop(context, true);
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Ajouter une vidéo'),
        backgroundColor: AppTheme.surface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Colle l\'URL directe d\'une vidéo (fichier .mp4/.m3u8 accessible '
                'publiquement) — pas une page de streaming protégée par DRM comme '
                'Netflix ou Disney+.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _urlController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'URL de la vidéo',
                  hintText: 'https://exemple.com/video.mp4',
                  errorText: _urlError,
                  suffixIcon: _isCheckingUrl
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.play_circle_outline_rounded),
                          onPressed: _testUrl,
                          tooltip: 'Tester la vidéo',
                        ),
                ),
                onSubmitted: (_) => _testUrl(),
              ),
              const SizedBox(height: 16),
              if (_previewController != null && _previewController!.value.isInitialized) ...[
                AspectRatio(
                  aspectRatio: _previewController!.value.aspectRatio,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: VideoPlayer(_previewController!),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _titleController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Titre (optionnel)'),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickThumbnail,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    image: _thumbnailPath != null
                        ? DecorationImage(image: FileImage(File(_thumbnailPath!)), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _thumbnailPath == null
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.image_rounded, color: AppTheme.textSecondary, size: 28),
                              SizedBox(height: 8),
                              Text('Choisir une miniature (optionnel)',
                                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                            ],
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Enregistrer et regarder',
                onPressed: _saveAndPlay,
                icon: Icons.play_arrow_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
