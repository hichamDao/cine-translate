import 'package:shared_preferences/shared_preferences.dart';

/// Centralise tous les reglages persistes localement (SharedPreferences),
/// pour que toutes les ecrans lisent/ecrivent les memes cles.
class AppSettings {
  static const _keyBackendUrl = 'backend_url';
  static const _keyTargetLang = 'target_language';
  static const _keySubtitleSize = 'subtitle_size';
  static const _keySubtitleColor = 'subtitle_color';
  static const _keySubtitleBgOpacity = 'subtitle_bg_opacity';
  static const _keyAutoTranslation = 'auto_translation';
  static const _keyProfileName = 'profile_name';
  static const _keyProfileAvatarPath = 'profile_avatar_path';

  /// Valeur par defaut generique : a changer obligatoirement dans les
  /// Reglages au premier lancement (l'IP locale change d'un reseau a l'autre).
  static const defaultBackendUrl = 'ws://192.168.1.100:8000';

  static Future<String> getBackendUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBackendUrl) ?? defaultBackendUrl;
  }

  static Future<void> setBackendUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBackendUrl, url);
  }

  static Future<String> getTargetLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTargetLang) ?? 'fr';
  }

  static Future<void> setTargetLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTargetLang, lang);
  }

  static Future<double> getSubtitleSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keySubtitleSize) ?? 18.0;
  }

  static Future<void> setSubtitleSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keySubtitleSize, size);
  }

  /// Couleur stockee sous forme d'entier ARGB (Color.value).
  static Future<int> getSubtitleColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keySubtitleColor) ?? 0xFFF8FAFC; // AppTheme.textPrimary
  }

  static Future<void> setSubtitleColor(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySubtitleColor, colorValue);
  }

  static Future<double> getSubtitleBgOpacity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keySubtitleBgOpacity) ?? 0.6;
  }

  static Future<void> setSubtitleBgOpacity(double opacity) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keySubtitleBgOpacity, opacity);
  }

  static Future<bool> getAutoTranslation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAutoTranslation) ?? true;
  }

  static Future<void> setAutoTranslation(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoTranslation, value);
  }

  static Future<String> getProfileName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyProfileName) ?? 'Utilisateur';
  }

  static Future<void> setProfileName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfileName, name);
  }

  static Future<String?> getProfileAvatarPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyProfileAvatarPath);
  }

  static Future<void> setProfileAvatarPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfileAvatarPath, path);
  }
}
