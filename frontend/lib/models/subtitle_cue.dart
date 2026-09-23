class SubtitleCue {
  final Duration start;
  final Duration end;
  final String text;
  final String? original;

  SubtitleCue({
    required this.start,
    required this.end,
    required this.text,
    this.original,
  });

  factory SubtitleCue.fromJson(Map<String, dynamic> json) {
    return SubtitleCue(
      start: Duration(milliseconds: ((json['start'] as num) * 1000).round()),
      end: Duration(milliseconds: ((json['end'] as num) * 1000).round()),
      text: json['text'] as String,
      original: json['original'] as String?,
    );
  }

  bool contains(Duration position) => position >= start && position <= end;
}
