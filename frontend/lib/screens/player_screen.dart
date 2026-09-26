import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/subtitle_cue.dart';
import '../services/translation_service.dart';
import '../widgets.dart';
import '../theme.dart';

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
  String _currentOriginalText = '';
  String _currentTranslatedText = '';
  String _status = 'connecting';
  bool _readyToPlay = false;
  bool _showControls = true;
  bool _showSubtitles = true;
  String _sourceLanguage = 'en';
  String _sourceFlag = '🇺🇸';
  String _targetFlag = '🇫🇷';

  @override
  void initState() {
    super.initState();
    _targetFlag = _getFlagForLang(widget.targetLang);

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller.addListener(_syncSubtitle);
        if (_readyToPlay) _controller.play();
      });

    _translationService =
        TranslationService(backendBaseUrl: widget.backendBaseUrl)
          ..connect(
            videoUrl: widget.videoUrl,
            targetLang: widget.targetLang,
          );

    _translationService.cues.listen((cue) {
      if (!mounted) return;
      setState(() {
        _cues.add(cue);
        if (cue.original != null) {
          _sourceLanguage = _detectLanguage(cue.original!);
          _sourceFlag = _getFlagForLang(_sourceLanguage);
        }
      });
    });
    _translationService.status.listen((s) {
      if (!mounted) return;
      setState(() => _status = s);
      if (!_readyToPlay && s != 'connecting') {
        _startPlayback();
      }
    });

    Future.delayed(const Duration(seconds: 8), () {
      if (!mounted) return;
      if (!_readyToPlay) {
        print('Timeout traduction: lecture forcee sans attendre');
        _startPlayback();
      }
    });

    _hideControlsTimer();
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
    if (match.isNotEmpty) {
      final cue = match.last;
      if (cue.text != _currentTranslatedText || cue.original != _currentOriginalText) {
        setState(() {
          _currentTranslatedText = cue.text;
          _currentOriginalText = cue.original ?? '';
        });
      }
    } else if (_currentTranslatedText.isNotEmpty || _currentOriginalText.isNotEmpty) {
      setState(() {
        _currentTranslatedText = '';
        _currentOriginalText = '';
      });
    }
  }

  void _hideControlsTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _controller.value.isPlaying && _showControls) {
        setState(() => _showControls = false);
      }
    });
  }

  void _onTapVideo() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) _hideControlsTimer();
    });
  }

  void _togglePlayPause() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
      if (_controller.value.isPlaying) _hideControlsTimer();
    });
  }

  void _seekRelative(int seconds) {
    final newPosition = _controller.value.position + Duration(seconds: seconds);
    if (newPosition < Duration.zero) {
      _controller.seekTo(Duration.zero);
    } else if (newPosition > _controller.value.duration) {
      _controller.seekTo(_controller.value.duration);
    } else {
      _controller.seekTo(newPosition);
    }
    _hideControlsTimer();
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
      extendBodyBehindAppBar: true,
      appBar: _showControls
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
              ),
              title: Text(
                _extractTitleFromUrl(widget.videoUrl),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                IconButton(
                  onPressed: () => _showSettingsModal(context),
                  icon: const Icon(Icons.settings_rounded, color: AppTheme.textPrimary),
                ),
              ],
            )
          : null,
      body: GestureDetector(
        onTap: _onTapVideo,
        child: Stack(
          children: [
            // Video player
            Center(
              child: !_controller.value.isInitialized
                  ? const CircularProgressIndicator(color: AppTheme.primaryViolet)
                  : AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
            ),
            // Subtitles display (above controls)
            if (_showSubtitles && (_currentOriginalText.isNotEmpty || _currentTranslatedText.isNotEmpty))
              Positioned(
                bottom: _showControls ? 180 : 32,
                left: 16,
                right: 16,
                child: DualSubtitleDisplay(
                  originalText: _currentOriginalText,
                  translatedText: _currentTranslatedText,
                  originalLang: _sourceLanguage.toUpperCase(),
                  translatedLang: widget.targetLang.toUpperCase(),
                  originalFlag: _sourceFlag,
                  translatedFlag: _targetFlag,
                ),
              ),
            // Status badge
            if (_showControls)
              Positioned(
                top: MediaQuery.of(context).padding.top + 56,
                right: 16,
                child: _buildStatusBadge(),
              ),
            // Loading overlay
            if (!_readyToPlay)
              _LoadingOverlay(
                cuesReceived: _cues.length,
                onSkip: _startPlayback,
              ),
            // Playback controls
            if (_showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: PlaybackControls(
                  controller: _controller,
                  onRewind: () => _seekRelative(-10),
                  onForward: () => _seekRelative(10),
                  onSpeed: () => _showSpeedDialog(context),
                  onSubtitleSettings: () => _showSubtitleSettings(context),
                  onFullscreen: () {},
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    StatusType statusType;
    switch (_status) {
      case 'connecting':
        statusType = StatusType.connecting;
        break;
      case 'streaming':
        statusType = StatusType.streaming;
        break;
      case 'done':
        statusType = StatusType.done;
        break;
      default:
        if (_status.startsWith('error')) {
          statusType = StatusType.error;
        } else {
          statusType = StatusType.disconnected;
        }
    }
    return StatusBadge(status: statusType);
  }

  void _showSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.closed_caption_rounded, color: AppTheme.textPrimary),
              title: const Text('Sous-titres', style: TextStyle(color: AppTheme.textPrimary)),
              trailing: Switch(
                value: _showSubtitles,
                activeColor: AppTheme.primaryViolet,
                onChanged: (v) => setState(() => _showSubtitles = v),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.speed_rounded, color: AppTheme.textPrimary),
              title: const Text('Vitesse de lecture', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _showSpeedDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.translate_rounded, color: AppTheme.textPrimary),
              title: const Text('Changer la langue', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _showLanguageDialog(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showSpeedDialog(BuildContext context) {
    const speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  const Text(
                    'Vitesse de lecture',
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),
            ListView.separated(
              shrinkWrap: true,
              itemCount: speeds.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final speed = speeds[index];
                final isSelected = _controller.value.playbackSpeed == speed;
                return ListTile(
                  title: Text(
                    '${speed}x',
                    style: TextStyle(
                      color: isSelected ? AppTheme.primaryViolet : AppTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_rounded, color: AppTheme.primaryViolet)
                      : null,
                  onTap: () {
                    _controller.setPlaybackSpeed(speed);
                    Navigator.pop(context);
                  },
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final languages = [
      LanguageOption(code: 'fr', name: 'Français', flag: '🇫🇷'),
      LanguageOption(code: 'en', name: 'English', flag: '🇬🇧'),
      LanguageOption(code: 'es', name: 'Español', flag: '🇪🇸'),
      LanguageOption(code: 'de', name: 'Deutsch', flag: '🇩🇪'),
      LanguageOption(code: 'it', name: 'Italiano', flag: '🇮🇹'),
      LanguageOption(code: 'pt', name: 'Português', flag: '🇵🇹'),
      LanguageOption(code: 'ar', name: 'العربية', flag: '🇸🇦'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LanguageSelectorModal(
        currentLanguage: widget.targetLang,
        languages: languages,
        onSelect: (lang) {
          Navigator.pop(context);
          // In real app, reconnect websocket with new language
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Changement de langue vers ${_getLanguageName(lang)} (reconnexion nécessaire)'),
              backgroundColor: AppTheme.primaryViolet,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
      ),
    );
  }

  void _showSubtitleSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.text_fields_rounded, color: AppTheme.textPrimary),
              title: const Text('Taille', style: TextStyle(color: AppTheme.textPrimary)),
              subtitle: Text('${18}px', style: const TextStyle(color: AppTheme.textSecondary)),
              trailing: SizedBox(
                width: 120,
                child: Slider(
                  value: 18.0,
                  min: 12,
                  max: 28,
                  divisions: 16,
                  activeColor: AppTheme.primaryViolet,
                  onChanged: (v) {},
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.color_lens_rounded, color: AppTheme.textPrimary),
              title: const Text('Couleur', style: TextStyle(color: AppTheme.textPrimary)),
              trailing: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.textPrimary,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.format_color_fill_rounded, color: AppTheme.textPrimary),
              title: const Text('Style', style: TextStyle(color: AppTheme.textPrimary)),
              subtitle: const Text('Classique', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _extractTitleFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        final fileName = segments.last;
        return fileName.replaceAll(RegExp(r'\.(mp4|mov|mkv|avi)$', caseSensitive: false), '');
      }
    } catch (_) {}
    return 'Vidéo';
  }

  String _getFlagForLang(String lang) {
    const flags = {
      'fr': '🇫🇷',
      'en': '🇬🇧',
      'es': '🇪🇸',
      'de': '🇩🇪',
      'it': '🇮🇹',
      'pt': '🇵🇹',
      'ar': '🇸🇦',
      'ja': '🇯🇵',
      'ko': '🇰🇷',
      'zh': '🇨🇳',
      'ru': '🇷🇺',
      'nl': '🇳🇱',
      'pl': '🇵🇱',
      'tr': '🇹🇷',
    };
    return flags[lang.toLowerCase()] ?? '🌐';
  }

  String _detectLanguage(String text) {
    // Simple heuristic - in real app use a proper language detection library
    if (text.contains(RegExp(r'[àâäéèêëïîôöùûüÿç]'))) return 'fr';
    if (text.contains(RegExp(r'[ñáéíóúü]'))) return 'es';
    if (text.contains(RegExp(r'[äöüß]'))) return 'de';
    if (text.contains(RegExp(r'[àèéìíòóùú]'))) return 'it';
    if (text.contains(RegExp(r'[ãõáéíóúâêô]'))) return 'pt';
    return 'en';
  }

  String _getLanguageName(String code) {
    const names = {
      'fr': 'Français',
      'en': 'English',
      'es': 'Español',
      'de': 'Deutsch',
      'it': 'Italiano',
      'pt': 'Português',
      'ar': 'العربية',
      'ja': '日本語',
      'ko': '한국어',
      'zh': '中文',
      'ru': 'Русский',
      'nl': 'Nederlands',
      'pl': 'Polski',
      'tr': 'Türkçe',
    };
    return names[code] ?? code;
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
            const CircularProgressIndicator(color: AppTheme.primaryViolet, strokeWidth: 3),
            const SizedBox(height: 20),
            const Text(
              'Préparation des sous-titres...',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              '$cuesReceived sous-titre(s) reçu(s)',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: onSkip,
              child: const Text(
                'Lire sans attendre',
                style: TextStyle(color: AppTheme.accentBlue, fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}