import 'package:flutter/material.dart';
import '../theme.dart';

enum StatusType {
  connecting,
  streaming,
  done,
  error,
  disconnected,
}

class StatusBadge extends StatelessWidget {
  final StatusType status;
  final String? customLabel;

  const StatusBadge({
    super.key,
    required this.status,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: config.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            customLabel ?? config.label,
            style: TextStyle(
              color: config.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(StatusType status) {
    switch (status) {
      case StatusType.connecting:
        return _StatusConfig(
          label: 'Connexion...',
          color: AppTheme.accentBlue,
        );
      case StatusType.streaming:
        return _StatusConfig(
          label: 'Traduction en direct',
          color: AppTheme.primaryViolet,
        );
      case StatusType.done:
        return _StatusConfig(
          label: 'Traduction terminée',
          color: AppTheme.success,
        );
      case StatusType.error:
        return _StatusConfig(
          label: 'Erreur traduction',
          color: AppTheme.error,
        );
      case StatusType.disconnected:
        return _StatusConfig(
          label: 'Déconnecté',
          color: AppTheme.textSecondary,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color color;

  _StatusConfig({required this.label, required this.color});
}