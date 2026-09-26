import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets.dart';
import '../theme.dart';
import 'language_selection_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'fr';
  double _subtitleSize = 18.0;
  Color _subtitleColor = AppTheme.textPrimary;
  bool _autoTranslation = true;
  bool _backgroundDownload = true;
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('target_language') ?? 'fr';
      _subtitleSize = prefs.getDouble('subtitle_size') ?? 18.0;
      _subtitleColor = Color(prefs.getInt('subtitle_color') ?? AppTheme.textPrimary.value);
      _autoTranslation = prefs.getBool('auto_translation') ?? true;
      _backgroundDownload = prefs.getBool('background_download') ?? true;
      _notifications = prefs.getBool('notifications') ?? true;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) await prefs.setString(key, value);
    if (value is double) await prefs.setDouble(key, value);
    if (value is int) await prefs.setInt(key, value);
    if (value is bool) await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Réglages'),
        backgroundColor: AppTheme.surface,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            // Profile section
            SettingsSection(
              title: 'PROFIL',
              children: [
                SettingsItem(
                  icon: Icons.person_rounded,
                  title: 'Profil',
                  subtitle: 'Gérer votre compte et préférences',
                  onTap: () {},
                ),
              ],
            ),
            // Language section
            SettingsSection(
              title: 'LANGUE',
              children: [
                SettingsItem(
                  icon: Icons.translate_rounded,
                  title: 'Langue de traduction',
                  subtitle: _getLanguageName(_selectedLanguage),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
                  onTap: () async {
                    final result = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
                    );
                    if (result != null && mounted) {
                      setState(() => _selectedLanguage = result);
                      await _saveSetting('target_language', result);
                    }
                  },
                ),
              ],
            ),
            // Subtitle appearance section
            SettingsSection(
              title: 'APPARENCE DES SOUS-TITRES',
              children: [
                SettingsItem(
                  icon: Icons.text_fields_rounded,
                  title: 'Taille du texte',
                  subtitle: '${_subtitleSize.round()}px',
                  trailing: SizedBox(
                    width: 120,
                    child: Slider(
                      value: _subtitleSize,
                      min: 12,
                      max: 28,
                      divisions: 16,
                      activeColor: AppTheme.primaryViolet,
                      inactiveColor: Colors.white24,
                      onChanged: (v) async {
                        setState(() => _subtitleSize = v);
                        await _saveSetting('subtitle_size', v);
                      },
                    ),
                  ),
                ),
                SettingsItem(
                  icon: Icons.color_lens_rounded,
                  title: 'Couleur du texte',
                  subtitle: 'Blanc',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _subtitleColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white24),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
                    ],
                  ),
                  onTap: () => _showColorPicker(context),
                ),
                SettingsItem(
                  icon: Icons.closed_caption_rounded,
                  title: 'Style des sous-titres',
                  subtitle: 'Classique, Ombre, Fond',
                  onTap: () {},
                ),
              ],
            ),
            // Audio section
            SettingsSection(
              title: 'AUDIO',
              children: [
                SettingsItem(
                  icon: Icons.volume_up_rounded,
                  title: 'Volume des sous-titres audio',
                  subtitle: 'Synthèse vocale pour les sous-titres',
                  trailing: Switch(
                    value: false,
                    activeColor: AppTheme.primaryViolet,
                    onChanged: (v) {},
                  ),
                ),
                SettingsItem(
                  icon: Icons.speed_rounded,
                  title: 'Vitesse de lecture',
                  subtitle: '0.5x - 2.0x',
                  onTap: () {},
                ),
              ],
            ),
            // Translation section
            SettingsSection(
              title: 'TRADUCTION AUTOMATIQUE',
              children: [
                SettingsItem(
                  icon: Icons.auto_awesome_rounded,
                  title: 'Traduction en temps réel',
                  subtitle: 'Activer la traduction pendant la lecture',
                  trailing: Switch(
                    value: _autoTranslation,
                    activeColor: AppTheme.primaryViolet,
                    onChanged: (v) async {
                      setState(() => _autoTranslation = v);
                      await _saveSetting('auto_translation', v);
                    },
                  ),
                ),
                SettingsItem(
                  icon: Icons.cloud_download_rounded,
                  title: 'Téléchargement en arrière-plan',
                  subtitle: 'Précharger les traductions',
                  trailing: Switch(
                    value: _backgroundDownload,
                    activeColor: AppTheme.primaryViolet,
                    onChanged: (v) async {
                      setState(() => _backgroundDownload = v);
                      await _saveSetting('background_download', v);
                    },
                  ),
                ),
                SettingsItem(
                  icon: Icons.language_rounded,
                  title: 'Moteur de traduction',
                  subtitle: 'DeepL, Google, LibreTranslate',
                  onTap: () {},
                ),
              ],
            ),
            // Downloads section
            SettingsSection(
              title: 'TÉLÉCHARGEMENTS',
              children: [
                SettingsItem(
                  icon: Icons.download_rounded,
                  title: 'Qualité vidéo par défaut',
                  subtitle: '720p, 1080p, 4K',
                  onTap: () {},
                ),
                SettingsItem(
                  icon: Icons.storage_rounded,
                  title: 'Espace de stockage utilisé',
                  subtitle: '2.4 GB sur 64 GB',
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
                  onTap: () {},
                ),
                SettingsItem(
                  icon: Icons.delete_sweep_rounded,
                  title: 'Vider le cache',
                  subtitle: 'Libérer de l\'espace',
                  isDestructive: true,
                  onTap: () => _showClearCacheDialog(context),
                ),
              ],
            ),
            // Notifications section
            SettingsSection(
              title: 'NOTIFICATIONS',
              children: [
                SettingsItem(
                  icon: Icons.notifications_rounded,
                  title: 'Notifications push',
                  subtitle: 'Recevoir des alertes',
                  trailing: Switch(
                    value: _notifications,
                    activeColor: AppTheme.primaryViolet,
                    onChanged: (v) async {
                      setState(() => _notifications = v);
                      await _saveSetting('notifications', v);
                    },
                  ),
                ),
                SettingsItem(
                  icon: Icons.schedule_rounded,
                  title: 'Rappels de visionnage',
                  subtitle: 'Continuer là où vous vous êtes arrêté',
                  trailing: Switch(
                    value: true,
                    activeColor: AppTheme.primaryViolet,
                    onChanged: (v) {},
                  ),
                ),
              ],
            ),
            // Privacy section
            SettingsSection(
              title: 'CONFIDENTIALITÉ',
              children: [
                SettingsItem(
                  icon: Icons.privacy_tip_rounded,
                  title: 'Politique de confidentialité',
                  onTap: () {},
                ),
                SettingsItem(
                  icon: Icons.article_rounded,
                  title: 'Conditions d\'utilisation',
                  onTap: () {},
                ),
                SettingsItem(
                  icon: Icons.delete_forever_rounded,
                  title: 'Supprimer mon compte',
                  isDestructive: true,
                  onTap: () => _showDeleteAccountDialog(context),
                ),
              ],
            ),
            // About section
            SettingsSection(
              title: 'À PROPOS',
              children: [
                SettingsItem(
                  icon: Icons.info_rounded,
                  title: 'Version',
                  subtitle: '1.0.0 (Build 1)',
                ),
                SettingsItem(
                  icon: Icons.code_rounded,
                  title: 'Licences open source',
                  onTap: () {},
                ),
                SettingsItem(
                  icon: Icons.star_rounded,
                  title: 'Noter l\'application',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

  void _showColorPicker(BuildContext context) {
    final colors = [
      AppTheme.textPrimary,
      AppTheme.primaryViolet,
      AppTheme.accentBlue,
      AppTheme.success,
      Colors.amber,
      Colors.orange,
      Colors.pink,
      Colors.cyan,
    ];

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
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Couleur des sous-titres',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: colors.map((color) {
                  final isSelected = color == _subtitleColor;
                  return GestureDetector(
                    onTap: () async {
                      setState(() => _subtitleColor = color);
                      await _saveSetting('subtitle_color', color.value);
                      if (mounted) Navigator.pop(context);
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: AppTheme.textPrimary, width: 3)
                            : Border.all(color: Colors.white10),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.5),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 24)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Vider le cache', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'Cela supprimera tous les fichiers temporaires et les traductions mises en cache. Cette action est irréversible.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Cache vidé avec succès'),
                  backgroundColor: AppTheme.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: const Text('Vider', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer le compte', style: TextStyle(color: AppTheme.error)),
        content: const Text(
          'Cette action supprimera définitivement votre compte, vos favoris, votre historique et toutes vos données. Cette action est irréversible.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Suppression du compte... (à implémenter)'),
                  backgroundColor: AppTheme.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: const Text('Supprimer', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}