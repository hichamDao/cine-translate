# Cine-Translate

App Flutter + serveur Python pour traduire en direct les sous-titres d'une
video lue depuis une URL — **sans jamais stocker la video sur le serveur**.

## A lire avant de commencer

Ce projet fonctionne uniquement avec des **URLs de videos directes et non
protegees par DRM** : fichiers `.mp4`/`.m3u8` que vous avez le droit de
traiter, vos propres videos, du contenu du domaine public... Les
plateformes de streaming grand public (Netflix, Disney+, Amazon Prime,
etc.) chiffrent leur flux avec du DRM (Widevine/FairPlay) : c'est bloque
techniquement, et le contourner serait illegal. Ce projet ne cherche pas
a le faire.

## Architecture

```
Flutter app                              Backend Python (FastAPI)
────────────                             ─────────────────────────
1. Utilisateur donne une URL video  ──▶  2. ffmpeg lit l'URL en flux et
                                             extrait UNIQUEMENT l'audio
                                             (rien de la video n'est
                                             jamais ecrit sur disque)
                                          3. faster-whisper transcrit
                                             par chunks (~25s)
                                          4. Traduction de chaque segment
                                             (DeepL ou fallback gratuit)
                                          5. Envoi des cues (texte +
                                             timestamps) via WebSocket,
                                             au fil de l'eau
6. video_player lit directement
   depuis l'URL d'origine — le      ◀──── (le backend n'est jamais dans
   backend n'est jamais dans la           la boucle de lecture video)
   boucle de lecture video
7. Sous-titres traduits affiches
   en overlay, synchronises sur
   la position de lecture
```

Le point cle : **le serveur ne fait que "regarder passer" l'audio**, il ne
proxy jamais la video elle-meme. Le lecteur Flutter streame directement
depuis la source.

## Demarrage rapide

### 1. Backend

```bash
cd backend
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Voir [`backend/README.md`](backend/README.md) pour les details.

### 2. Frontend

```bash
cd frontend
flutter create .      # genere android/ios sans ecraser lib/
flutter pub get
flutter run
```

Voir [`frontend/README.md`](frontend/README.md) pour les details.

## Roadmap possible

- [ ] Cache des cues pour eviter de re-traiter un passage deja vu
- [ ] Relance automatique du traitement lors d'un rembobinage important
- [ ] Choix du modele Whisper depuis l'app (vitesse vs qualite)
- [ ] Export `.srt` genere a la volee, telechargeable
- [ ] File d'attente/quota si plusieurs utilisateurs traduisent en meme temps
