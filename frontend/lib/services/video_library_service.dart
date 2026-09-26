import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_video.dart';

/// Gere la liste des videos sauvegardees, entierement en local
/// (SharedPreferences), sans aucun backend ni base de donnees.
class VideoLibraryService {
  static const _key = 'saved_videos';

  static Future<List<SavedVideo>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => SavedVideo.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _saveAll(List<SavedVideo> videos) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(videos.map((v) => v.toJson()).toList());
    await prefs.setString(_key, raw);
  }

  static Future<void> add(SavedVideo video) async {
    final videos = await getAll();
    videos.insert(0, video);
    await _saveAll(videos);
  }

  static Future<void> update(SavedVideo updated) async {
    final videos = await getAll();
    final index = videos.indexWhere((v) => v.id == updated.id);
    if (index != -1) {
      videos[index] = updated;
      await _saveAll(videos);
    }
  }

  static Future<void> remove(String id) async {
    final videos = await getAll();
    videos.removeWhere((v) => v.id == id);
    await _saveAll(videos);
  }

  static Future<void> toggleFavorite(String id) async {
    final videos = await getAll();
    final index = videos.indexWhere((v) => v.id == id);
    if (index != -1) {
      videos[index].isFavorite = !videos[index].isFavorite;
      await _saveAll(videos);
    }
  }

  static Future<void> markWatched(String id, double positionSeconds) async {
    final videos = await getAll();
    final index = videos.indexWhere((v) => v.id == id);
    if (index != -1) {
      videos[index].lastWatched = DateTime.now();
      videos[index].lastPositionSeconds = positionSeconds;
      await _saveAll(videos);
    }
  }

  static Future<List<SavedVideo>> getFavorites() async {
    final videos = await getAll();
    return videos.where((v) => v.isFavorite).toList();
  }

  static Future<List<SavedVideo>> getHistory() async {
    final videos = await getAll();
    final watched = videos.where((v) => v.lastWatched != null).toList();
    watched.sort((a, b) => b.lastWatched!.compareTo(a.lastWatched!));
    return watched;
  }
}
