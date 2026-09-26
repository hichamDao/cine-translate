/// Une video sauvegardee localement sur le telephone (aucun backend/BDD).
/// Contient juste une URL a lire et des metadonnees d'affichage.
class SavedVideo {
  final String id;
  String title;
  String videoUrl;
  String? thumbnailPath; // chemin fichier LOCAL (image_picker + copie locale)
  String targetLang;
  bool isFavorite;
  final DateTime dateAdded;
  DateTime? lastWatched;
  double lastPositionSeconds;

  SavedVideo({
    required this.id,
    required this.title,
    required this.videoUrl,
    this.thumbnailPath,
    this.targetLang = 'fr',
    this.isFavorite = false,
    DateTime? dateAdded,
    this.lastWatched,
    this.lastPositionSeconds = 0,
  }) : dateAdded = dateAdded ?? DateTime.now();

  factory SavedVideo.fromJson(Map<String, dynamic> json) {
    return SavedVideo(
      id: json['id'] as String,
      title: json['title'] as String,
      videoUrl: json['videoUrl'] as String,
      thumbnailPath: json['thumbnailPath'] as String?,
      targetLang: json['targetLang'] as String? ?? 'fr',
      isFavorite: json['isFavorite'] as bool? ?? false,
      dateAdded: json['dateAdded'] != null
          ? DateTime.tryParse(json['dateAdded'] as String)
          : null,
      lastWatched: json['lastWatched'] != null
          ? DateTime.tryParse(json['lastWatched'] as String)
          : null,
      lastPositionSeconds: (json['lastPositionSeconds'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'videoUrl': videoUrl,
      'thumbnailPath': thumbnailPath,
      'targetLang': targetLang,
      'isFavorite': isFavorite,
      'dateAdded': dateAdded.toIso8601String(),
      'lastWatched': lastWatched?.toIso8601String(),
      'lastPositionSeconds': lastPositionSeconds,
    };
  }
}
