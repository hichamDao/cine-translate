import 'package:flutter/material.dart';
import '../theme.dart';

class DualSubtitleDisplay extends StatelessWidget {
  final String originalText;
  final String translatedText;
  final String originalLang;
  final String translatedLang;
  final String originalFlag;
  final String translatedFlag;
  final double fontSize;
  final Color textColor;
  final double backgroundOpacity;

  const DualSubtitleDisplay({
    super.key,
    required this.originalText,
    required this.translatedText,
    required this.originalLang,
    required this.translatedLang,
    required this.originalFlag,
    required this.translatedFlag,
    this.fontSize = 18,
    this.textColor = AppTheme.textPrimary,
    this.backgroundOpacity = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    if (originalText.isEmpty && translatedText.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(backgroundOpacity),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (originalText.isNotEmpty) _SubtitleLine(
            flag: originalFlag,
            lang: originalLang,
            text: originalText,
            isOriginal: true,
            fontSize: fontSize,
            textColor: textColor,
          ),
          if (originalText.isNotEmpty && translatedText.isNotEmpty)
            const SizedBox(height: 12),
          if (translatedText.isNotEmpty) _SubtitleLine(
            flag: translatedFlag,
            lang: translatedLang,
            text: translatedText,
            isOriginal: false,
            fontSize: fontSize,
            textColor: textColor,
          ),
        ],
      ),
    );
  }
}

class _SubtitleLine extends StatelessWidget {
  final String flag;
  final String lang;
  final String text;
  final bool isOriginal;
  final double fontSize;
  final Color textColor;

  const _SubtitleLine({
    required this.flag,
    required this.lang,
    required this.text,
    required this.isOriginal,
    required this.fontSize,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              lang,
              style: TextStyle(
                color: isOriginal ? AppTheme.textSecondary : AppTheme.primaryViolet,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: isOriginal ? fontSize - 3 : fontSize,
            fontWeight: isOriginal ? FontWeight.w400 : FontWeight.w500,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
