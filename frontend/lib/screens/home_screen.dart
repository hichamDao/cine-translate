import 'package:flutter/material.dart';

import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _urlController = TextEditingController();
  final _backendController =
      TextEditingController(text: 'ws://10.0.2.2:8000');
  String _targetLang = 'fr';

  static const _languages = {
    'fr': 'Francais',
    'en': 'English',
    'es': 'Espanol',
    'de': 'Deutsch',
    'ar': 'Arabe',
  };

  @override
  void dispose() {
    _urlController.dispose();
    _backendController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cine-Translate')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Colle l'URL directe d'une video (fichier .mp4/.m3u8 "
              'accessible), pas une page de streaming protegee par DRM.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL de la video',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _backendController,
              decoration: const InputDecoration(
                labelText: 'Serveur backend (ws://...)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _targetLang,
              decoration: const InputDecoration(
                labelText: 'Traduire vers',
                border: OutlineInputBorder(),
              ),
              items: _languages.entries
                  .map((e) =>
                      DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) => setState(() => _targetLang = v ?? 'fr'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_urlController.text.trim().isEmpty) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlayerScreen(
                      videoUrl: _urlController.text.trim(),
                      backendBaseUrl: _backendController.text.trim(),
                      targetLang: _targetLang,
                    ),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Lire avec traduction'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
