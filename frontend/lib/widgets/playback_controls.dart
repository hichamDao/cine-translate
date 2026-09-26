import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../theme.dart';

class PlaybackControls extends StatelessWidget {
  final VideoPlayerController controller;
  final VoidCallback? onRewind;
  final VoidCallback? onForward;
  final VoidCallback? onSpeed;
  final VoidCallback? onSubtitleSettings;
  final VoidCallback? onFullscreen;

  const PlaybackControls({
    super.key,
    required this.controller,
    this.onRewind,
    this.onForward,
    this.onSpeed,
    this.onSubtitleSettings,
    this.onFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        if (!value.isInitialized) return const SizedBox.shrink();

        final position = value.position;
        final duration = value.duration;
        final progress = duration.inMilliseconds > 0
            ? position.inMilliseconds / duration.inMilliseconds
            : 0.0;

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.9),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress bar
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppTheme.primaryViolet,
                  inactiveTrackColor: Colors.white24,
                  thumbColor: AppTheme.primaryViolet,
                  overlayColor: AppTheme.primaryViolet.withOpacity(0.2),
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                ),
                child: Slider(
                  value: progress.clamp(0.0, 1.0),
                  onChanged: (v) {
                    final newPosition = Duration(
                      milliseconds: (v * duration.inMilliseconds).round(),
                    );
                    controller.seekTo(newPosition);
                  },
                ),
              ),
              // Time labels
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(position),
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                    ),
                    Text(
                      _formatDuration(duration),
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (onSubtitleSettings != null)
                    _ControlButton(
                      icon: Icons.closed_caption_rounded,
                      onPressed: onSubtitleSettings,
                    ),
                  _ControlButton(
                    icon: Icons.replay_10_rounded,
                    onPressed: onRewind ?? () => _seekRelative(controller, -10),
                    size: 44,
                  ),
                  _ControlButton(
                    icon: value.isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                    onPressed: () => value.isPlaying ? controller.pause() : controller.play(),
                    size: 64,
                    isPrimary: true,
                  ),
                  _ControlButton(
                    icon: Icons.forward_10_rounded,
                    onPressed: onForward ?? () => _seekRelative(controller, 10),
                    size: 44,
                  ),
                  if (onSpeed != null)
                    _ControlButton(
                      icon: Icons.speed_rounded,
                      onPressed: onSpeed,
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _seekRelative(VideoPlayerController controller, int seconds) {
    final newPosition = controller.value.position + Duration(seconds: seconds);
    if (newPosition < Duration.zero) {
      controller.seekTo(Duration.zero);
    } else if (newPosition > controller.value.duration) {
      controller.seekTo(controller.value.duration);
    } else {
      controller.seekTo(newPosition);
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final bool isPrimary;

  const _ControlButton({
    required this.icon,
    this.onPressed,
    this.size = 40,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: isPrimary
            ? BoxDecoration(
                color: AppTheme.primaryViolet,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryViolet.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              )
            : BoxDecoration(
                color: AppTheme.surface.withOpacity(0.8),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white10),
              ),
        child: Icon(
          icon,
          color: isPrimary ? AppTheme.textPrimary : AppTheme.textPrimary,
          size: size * 0.55,
        ),
      ),
    );
  }
}