# Cine-Translate — Frontend Flutter

App Flutter qui lit une video depuis une URL directe et affiche des
sous-titres traduits en direct, generes par le backend Python.

Le lecteur video (`video_player`) pointe **toujours directement** sur
l'URL source : le backend n'est jamais dans la boucle de lecture, il
fournit uniquement les sous-titres en parallele via WebSocket.

## Prerequis

- Flutter SDK ≥ 3.22
- Le backend (`../backend`) lance et accessible

## Installation

Ce depot ne contient que `lib/` et `pubspec.yaml` (pas les dossiers
`android/`/`ios/` generes automatiquement par Flutter). Pour demarrer :

```bash
cd frontend

# Genere les dossiers android/ios/etc. sans ecraser lib/ existant
flutter create .

flutter pub get
flutter run
```

## Configuration du backend

Dans l'app, l'ecran d'accueil demande l'URL du backend. Valeurs par
defaut selon l'environnement :

| Environnement         | URL backend              |
|------------------------|---------------------------|
| Emulateur Android      | `ws://10.0.2.2:8000`      |
| Simulateur iOS         | `ws://localhost:8000`     |
| Appareil physique      | `ws://<IP_DE_VOTRE_PC>:8000` |

## Structure

```
lib/
├── main.dart                       # Point d'entree
├── models/
│   └── subtitle_cue.dart           # Un segment de sous-titre (start/end/text)
├── services/
│   └── translation_service.dart    # Client websocket vers le backend
├── screens/
│   ├── home_screen.dart            # Saisie URL + langue cible
│   └── player_screen.dart          # Lecteur video + overlay sous-titres
└── widgets/
    └── subtitle_overlay.dart       # Affichage du sous-titre courant
```

## Limites connues (MVP)

- Le rembobinage (scrub) ne relance pas automatiquement la traduction a
  partir du nouveau point — les cues deja recues restent affichees des
  qu'on repasse dessus, mais rien de nouveau n'est demande au backend.
- Pas de gestion de reconnexion automatique si le websocket tombe.
