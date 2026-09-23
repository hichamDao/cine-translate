# Cine-Translate — Backend

Serveur FastAPI qui traduit en direct l'audio d'une video lue depuis une URL,
**sans jamais stocker la video**. Il lit le flux, en extrait l'audio avec
ffmpeg, transcrit avec `faster-whisper`, traduit chaque segment, et pousse
les sous-titres via WebSocket au fur et a mesure.

## Important — a lire avant de commencer

Ce serveur ne fonctionne que sur des **URLs de videos directes et non
protegees par DRM** (fichier `.mp4`/`.m3u8` que vous avez le droit de
traiter, ou vos propres videos). Netflix, Disney+, Amazon Prime etc.
chiffrent leur flux — ce n'est ni contournable ici, ni legal de le faire.

## Prerequis

- Python 3.11+
- [ffmpeg](https://ffmpeg.org/download.html) installe et dans le PATH

## Installation

```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
```

## Lancement

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Verification rapide :

```bash
curl http://localhost:8000/health
```

## Utilisation du WebSocket

```
ws://localhost:8000/ws/translate?url=<URL_VIDEO>&target_lang=fr
```

Le serveur pousse des messages JSON au fil de l'eau :

```json
{"start": 12.4, "end": 15.1, "text": "Bonjour, comment vas-tu ?", "original": "Hello, how are you?"}
```

Et a la fin :

```json
{"type": "done"}
```

## Avec Docker

```bash
docker build -t cine-translate-backend .
docker run -p 8000:8000 --env-file .env cine-translate-backend
```

## Configuration (`.env`)

| Variable              | Description                                              | Defaut |
|------------------------|-----------------------------------------------------------|--------|
| `WHISPER_MODEL_SIZE`  | Taille du modele Whisper (`tiny`, `base`, `small`, `medium`, `large-v3`) | `medium` |
| `WHISPER_DEVICE`      | `cpu` ou `cuda` (si GPU disponible)                       | `cpu`  |
| `WHISPER_COMPUTE_TYPE`| `int8` (rapide, CPU) ou `float16` (GPU)                   | `int8` |
| `CHUNK_SECONDS`       | Taille des blocs audio traites a la suite                | `25`   |
| `DEFAULT_TARGET_LANG` | Langue cible par defaut                                   | `fr`   |
| `DEEPL_API_KEY`       | Cle DeepL (optionnel, sinon fallback gratuit Google)      | vide   |

## Limites connues (MVP)

- Un modele plus gros (`medium`/`large`) donne une meilleure transcription
  mais est plus lent sur CPU — sur un film entier, du retard peut s'accumuler
  si le materiel est modeste. Un GPU ou un modele plus petit aide beaucoup.
- Le rembobinage cote client ne relance pas automatiquement le traitement
  a partir du nouveau point — a implementer si besoin (fermer/rouvrir le
  websocket avec un `start_offset`).
- Le fallback de traduction gratuit (`deep-translator`) peut etre instable
  ou rate-limite en usage intensif ; DeepL est recommande en production.
