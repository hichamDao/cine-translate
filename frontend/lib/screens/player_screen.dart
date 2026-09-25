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
  bool _readyToPlay = false;

  @override
  void initState() {
    super.initState();

    // Le lecteur pointe DIRECTEMENT sur l'URL source. Le serveur Python
    // n'est jamais dans la boucle de lecture video : il fournit
    // uniquement les sous-titres, en parallele, via websocket.
    // On initialise la video mais on NE LA LANCE PAS tout de suite : on
    // attend d'avoir les premiers sous-titres, sinon les toutes premieres
    // secondes se jouent sans traduction (surtout genant si le traitement
    // est plus lent que la video elle-meme).
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller.addListener(_syncSubtitle);
        if (_readyToPlay) _controller.play();
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
      // Des le premier evenement utile (premiers sous-titres recus,
      // traitement termine, ou erreur), on peut lancer la lecture.
      if (!_readyToPlay && s != 'connecting') {
        _startPlayback();
      }
    });

    // Filet de securite : si le serveur de traduction ne repond jamais
    // (probleme reseau, serveur eteint...), on ne bloque pas la video
    // indefiniment. On la lance quand meme au bout de 8 secondes.
    Future.delayed(const Duration(seconds: 8), () {
      if (!mounted) return;
      if (!_readyToPlay) {
        print('Timeout traduction: lecture forcee sans attendre');
        _startPlayback();
      }
    });
  }

  void _startPlayback() {
    if (_readyToPlay) return;
    setState(() => _readyToPlay = true);
    if (_controller.value.isInitialized) {
      _controller.play();
    }
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
                    if (!_readyToPlay) _LoadingOverlay(
                      cuesReceived: _cues.length,
                      onSkip: _startPlayback,
                    ),
                  ],
                ),
        ),
      ),
      floatingActionButton: _readyToPlay
          ? FloatingActionButton(
              onPressed: () => setState(() {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              }),
              child: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
            )
          : null,
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  final int cuesReceived;
  final VoidCallback onSkip;
  const _LoadingOverlay({required this.cuesReceived, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              'Préparation des sous-titres...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              '$cuesReceived sous-titre(s) reçu(s)',
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: onSkip,
              child: const Text(
                'Lire sans attendre',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
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
