import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/subtitle_cue.dart';
import '../services/translation_service.dart';
import '../widgets/subtitle_overlay.dart';

class PlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String backendBaseUrl;
  final String targetLang;

  const PlayerScreen({
    super.key,
    required this.videoUrl,
    required this.backendBaseUrl,
    required this.targetLang,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final VideoPlayerController _controller;
  late final TranslationService _translationService;
  final List<SubtitleCue> _cues = [];
  String _currentText = '';
  String _status = 'connecting';

  @override
  void initState() {
    super.initState();

    // Le lecteur pointe DIRECTEMENT sur l'URL source. Le serveur Python
    // n'est jamais dans la boucle de lecture video : il fournit
    // uniquement les sous-titres, en parallele, via websocket.
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller.play();
        _controller.addListener(_syncSubtitle);
      });

    _translationService =
        TranslationService(backendBaseUrl: widget.backendBaseUrl)
          ..connect(videoUrl: widget.videoUrl, targetLang: widget.targetLang);

    _translationService.cues.listen((cue) {
      if (!mounted) return;
      setState(() => _cues.add(cue));
    });
    _translationService.status.listen((s) {
      if (!mounted) return;
      setState(() => _status = s);
    });
  }

  void _syncSubtitle() {
    final pos = _controller.value.position;
    final match = _cues.where((c) => c.contains(pos));
    final text = match.isNotEmpty ? match.last.text : '';
    if (text != _currentText) setState(() => _currentText = text);
  }

  @override
  void dispose() {
    _controller.dispose();
    _translationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: !_controller.value.isInitialized
              ? const CircularProgressIndicator(color: Colors.white)
              : Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    SubtitleOverlay(text: _currentText),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _StatusBadge(status: _status),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                      ),
                    ),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {
          _controller.value.isPlaying
              ? _controller.pause()
              : _controller.play();
        }),
        child: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final label = status.startsWith('error')
        ? 'Erreur traduction'
        : status == 'done'
            ? 'Traduction terminee'
            : status == 'streaming'
                ? 'Traduction en direct'
                : 'Connexion...';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    );
  }
}
