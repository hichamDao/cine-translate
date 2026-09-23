import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/subtitle_cue.dart';

/// Se connecte au backend Python et recoit les cues de sous-titres
/// au fil de l'eau, pendant que la video est lue directement depuis
/// sa source par le lecteur video (le backend n'est jamais dans la
/// boucle de lecture, seulement dans celle de la traduction).
class TranslationService {
  final String backendBaseUrl; // ex: ws://10.0.2.2:8000

  WebSocketChannel? _channel;
  final _cuesController = StreamController<SubtitleCue>.broadcast();
  final _statusController = StreamController<String>.broadcast();

  TranslationService({required this.backendBaseUrl});

  Stream<SubtitleCue> get cues => _cuesController.stream;
  Stream<String> get status => _statusController.stream;

  void connect({
    required String videoUrl,
    required String targetLang,
    String? sourceLang,
  }) {
    final uri = Uri.parse('$backendBaseUrl/ws/translate').replace(
      queryParameters: {
        'url': videoUrl,
        'target_lang': targetLang,
        if (sourceLang != null) 'source_lang': sourceLang,
      },
    );

    _statusController.add('connecting');

    try {
      _channel = WebSocketChannel.connect(uri);
    } catch (e) {
      _statusController.add('error: $e');
      return;
    }

    _channel!.stream.listen(
      (raw) {
        final data = jsonDecode(raw as String) as Map<String, dynamic>;

        if (data['type'] == 'done') {
          _statusController.add('done');
          return;
        }
        if (data['type'] == 'error') {
          _statusController.add('error: ${data['message']}');
          return;
        }

        _statusController.add('streaming');
        _cuesController.add(SubtitleCue.fromJson(data));
      },
      onError: (e) => _statusController.add('error: $e'),
      onDone: () => _statusController.add('closed'),
    );
  }

  void dispose() {
    _channel?.sink.close();
    _cuesController.close();
    _statusController.close();
  }
}
