import 'package:flutter/material.dart';

import '../widgets.dart';
import '../theme.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  static final List<LanguageOption> _languages = [
    LanguageOption(code: 'fr', name: 'Français', flag: '🇫🇷'),
    LanguageOption(code: 'en', name: 'English', flag: '🇬🇧'),
    LanguageOption(code: 'es', name: 'Español', flag: '🇪🇸'),
    LanguageOption(code: 'de', name: 'Deutsch', flag: '🇩🇪'),
    LanguageOption(code: 'it', name: 'Italiano', flag: '🇮🇹'),
    LanguageOption(code: 'pt', name: 'Português', flag: '🇵🇹'),
    LanguageOption(code: 'ar', name: 'العربية', flag: '🇸🇦'),
    LanguageOption(code: 'ja', name: '日本語', flag: '🇯🇵'),
    LanguageOption(code: 'ko', name: '한국어', flag: '🇰🇷'),
    LanguageOption(code: 'zh', name: '中文', flag: '🇨🇳'),
    LanguageOption(code: 'ru', name: 'Русский', flag: '🇷🇺'),
    LanguageOption(code: 'nl', name: 'Nederlands', flag: '🇳🇱'),
    LanguageOption(code: 'pl', name: 'Polski', flag: '🇵🇱'),
    LanguageOption(code: 'tr', name: 'Türkçe', flag: '🇹🇷'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Langue de traduction'),
        backgroundColor: AppTheme.surface,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _languages.length,
          separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1, indent: 56, endIndent: 16),
          itemBuilder: (context, index) {
            final lang = _languages[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              leading: Text(lang.flag, style: const TextStyle(fontSize: 28)),
              title: Text(
                lang.name,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context, lang.code);
              },
            );
          },
        ),
      ),
    );
  }
}