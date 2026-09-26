# 🎬 Cine-Translate

> Application de traduction de films et de sous-titres en temps réel.

Cine-Translate permet de regarder une vidéo ou un film tout en obtenant automatiquement la traduction des dialogues dans la langue choisie.

---

## 📖 Sommaire

* [Présentation](#-présentation)
* [Objectif](#-objectif)
* [Design UI/UX](#-design-uiux)
* [Écrans](#-écrans)
* [Fonctionnalités](#-fonctionnalités)
* [Architecture](#-architecture)
* [WebSocket](#-websocket)
* [MVP](#-mvp)
* [Roadmap](#-roadmap)

---

## 🎯 Présentation

**Cine-Translate** est une application orientée cinéma qui combine :

* 🎬 lecteur vidéo
* 🎙️ reconnaissance vocale
* 📝 génération de sous-titres
* 🌍 traduction automatique
* ⚡ traduction en temps réel
* 💬 affichage des sous-titres traduits

L'objectif est de permettre à l'utilisateur de regarder un film dans une langue étrangère sans avoir besoin de rechercher manuellement les sous-titres.

---

# 🎯 Objectif

L'expérience utilisateur principale est :

```text
Importer une vidéo
       ↓
Analyser l'audio
       ↓
Détecter les dialogues
       ↓
Convertir la voix en texte
       ↓
Traduire le texte
       ↓
Afficher les sous-titres
```

---

# 🎨 Design UI/UX

## Style

Cine-Translate utilise une interface :

* sombre
* cinématique
* moderne
* minimaliste
* premium
* légèrement inspirée du glassmorphism

### Palette

| Élément          | Couleur   |
| ---------------- | --------- |
| Background       | `#080812` |
| Surface          | `#11111F` |
| Violet principal | `#7C3AED` |
| Bleu accent      | `#3B82F6` |
| Texte principal  | `#F8FAFC` |
| Texte secondaire | `#94A3B8` |
| Succès           | `#22C55E` |
| Erreur           | `#EF4444` |

---

# 📱 Écrans

## 1. Accueil

```text
┌─────────────────────────────────────────────┐
│ 🎬 CINE-TRANSLATE                       👤  │
│                                             │
│ Traduisez vos films                         │
│ dans votre langue.                          │
│                                             │
│ ┌─────────────────────────────────────────┐ │
│ │              ＋                          │ │
│ │        Importer une vidéo               │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│ Langue de traduction                        │
│ ┌─────────────────────────────────────────┐ │
│ │ 🇫🇷 Français                         ▼ │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│ Films récents                               │
│                                             │
│ ┌────────┐ ┌────────┐ ┌────────┐           │
│ │ POSTER │ │ POSTER │ │ POSTER │           │
│ │ Movie1 │ │ Movie2 │ │ Movie3 │           │
│ └────────┘ └────────┘ └────────┘           │
│                                             │
│ 🏠       🎬       ⭐       ⚙️               │
└─────────────────────────────────────────────┘
```

---

## 2. Lecteur / Traduction

```text
┌─────────────────────────────────────────────┐
│ ←  Interstellar                         ⚙️ │
│                                             │
│ ┌─────────────────────────────────────────┐ │
│ │                                         │ │
│ │                 VIDEO                   │ │
│ │                                         │ │
│ │                   ▶                     │ │
│ │                                         │ │
│ │ ───────────────●──────────────────────  │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│ 🇺🇸 English                                │
│ "We need to find another way."              │
│                                             │
│ 🇫🇷 Français                               │
│ "Nous devons trouver une autre solution." │
│                                             │
│ ┌─────────────────────────────────────────┐ │
│ │ ⚡ Traduction en temps réel              │ │
│ │                                         │ │
│ │              ● CONNECTÉ                 │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│        ◀◀       ▶ / ❚❚       ▶▶           │
└─────────────────────────────────────────────┘
```

---

## 3. Sélection de langue

```text
Choisir une langue

🇫🇷 Français
🇬🇧 English
🇪🇸 Español
🇩🇪 Deutsch
🇮🇹 Italiano
🇵🇹 Português
🇸🇦 العربية
```

---

## 4. Importation

```text
┌──────────────────────────────────────┐
│                                      │
│                  ＋                   │
│                                      │
│       Sélectionner une vidéo         │
│                                      │
│        MP4 · MOV · MKV · AVI         │
│                                      │
└──────────────────────────────────────┘
```

Après sélection :

```text
Analyse de la vidéo...

████████████████░░░░ 78%

Détection des dialogues...
```

---

## 5. Historique

```text
Historique

┌────────┐  Interstellar
│ POSTER │  Français
└────────┘  82% regardé

┌────────┐  The Matrix
│ POSTER │  Français
└────────┘  45% regardé
```

---

## 6. Favoris

```text
Mes favoris

🎬 Interstellar
🎬 The Matrix
🎬 Inception
```

---

## 7. Réglages

```text
Réglages

👤 Profil
🌍 Langue de traduction
💬 Apparence des sous-titres
🔊 Audio
⚡ Traduction automatique
📥 Téléchargements
🔔 Notifications
🔒 Confidentialité
```

---

# ✨ Fonctionnalités

## 🎬 Gestion des vidéos

* Importer une vidéo
* Lire une vidéo
* Pause / lecture
* Avance / retour
* Barre de progression
* Reprendre une vidéo

## 🎙️ Reconnaissance vocale

Le système doit être capable de :

1. récupérer l'audio de la vidéo
2. détecter les paroles
3. convertir la voix en texte
4. associer le texte au timing de la vidéo

## 🌍 Traduction

L'utilisateur choisit une langue cible.

Exemple :

```text
Original:
"We need to find another way."

Translation:
"Nous devons trouver une autre solution."
```

## ⚡ Temps réel

Les traductions doivent apparaître progressivement pendant la lecture.

```text
Audio
  ↓
Speech-to-Text
  ↓
Translation
  ↓
WebSocket
  ↓
Application
  ↓
Sous-titre
```

---

# 🏗️ Architecture

```text
                    ┌─────────────────┐
                    │   Mobile App    │
                    │                 │
                    │  Video Player   │
                    │  Subtitles      │
                    │  UI / UX        │
                    └────────┬────────┘
                             │
                         WebSocket
                             │
                             ▼
                    ┌─────────────────┐
                    │     Backend     │
                    │                 │
                    │ API             │
                    │ WebSocket       │
                    │ Authentication  │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              ▼              ▼              ▼
       Speech-to-Text   Translation    Database
```

---

# 🔌 WebSocket

Le WebSocket permet de maintenir une connexion permanente entre l'application et le serveur.

```text
Mobile App
     │
     │ WebSocket
     ▼
  Backend
     │
     ├── Speech-to-Text
     │
     ├── Translation
     │
     └── Subtitle Engine
```

Exemple de message envoyé au client :

```json
{
  "type": "translation",
  "original": "We need to find another way.",
  "translated": "Nous devons trouver une autre solution.",
  "sourceLanguage": "en",
  "targetLanguage": "fr",
  "start": 125.4,
  "end": 128.2
}
```

---

# 📐 Responsive Design

## Mobile

Formats principaux :

```text
375 × 812
390 × 844
428 × 926
```

## Tablet

```text
768 × 1024
```

## Desktop

La version desktop peut utiliser deux colonnes :

```text
┌─────────────────────────────────────────────────────┐
│                 CINE-TRANSLATE                      │
├──────────────────────────┬──────────────────────────┤
│                          │                          │
│                          │      Traduction          │
│                          │                          │
│         VIDEO            │ 🇺🇸 English              │
│                          │ "We need..."             │
│                          │                          │
│                          │ 🇫🇷 Français             │
│                          │ "Nous devons..."         │
│                          │                          │
└──────────────────────────┴──────────────────────────┘
```

---

# 🧩 Composants UI

### Primary Button

```text
┌──────────────────────────────┐
│     ＋ Importer une vidéo    │
└──────────────────────────────┘
```

Couleur :

```text
#7C3AED
```

### Status Badge

```text
● CONNECTÉ
```

Couleur :

```text
#22C55E
```

### Language Selector

```text
🇫🇷 Français                 ▼
```

---

# 📂 Structure du projet

Structure proposée :

```text
cine-translate/
│
├── frontend/
│   ├── components/
│   ├── screens/
│   ├── services/
│   ├── hooks/
│   └── assets/
│
├── backend/
│   ├── api/
│   ├── websocket/
│   ├── services/
│   │   ├── speech-to-text/
│   │   ├── translation/
│   │   └── subtitles/
│   ├── models/
│   └── database/
│
├── docs/
│   └── architecture.md
│
├── README.md
└── .env.example
```

---

# 🚀 MVP

La première version doit contenir :

* [ ] Importer une vidéo
* [ ] Lire une vidéo
* [ ] Détecter les dialogues
* [ ] Générer le texte original
* [ ] Traduire le texte
* [ ] Afficher les sous-titres
* [ ] Choisir la langue
* [ ] Afficher l'état de connexion
* [ ] Sauvegarder les films récents

---

# 🗺️ Roadmap

## Version 0.1 — Prototype

* [ ] Maquette UI/UX
* [ ] Navigation
* [ ] Lecteur vidéo
* [ ] Import vidéo

## Version 0.2 — Traduction

* [ ] Speech-to-Text
* [ ] Traduction
* [ ] Synchronisation des sous-titres

## Version 0.3 — Temps réel

* [ ] Backend WebSocket
* [ ] Streaming des traductions
* [ ] Gestion de reconnexion

## Version 1.0

* [ ] Authentification
* [ ] Historique
* [ ] Favoris
* [ ] Mode hors ligne
* [ ] Personnalisation des sous-titres
* [ ] Plusieurs langues
* [ ] Synchronisation cloud

---

# 🎯 Expérience utilisateur cible

Le parcours principal doit rester extrêmement simple :

```text
        🎬
        │
        ▼
   Importer vidéo
        │
        ▼
   Choisir langue
        │
        ▼
      ▶ Lire
        │
        ▼
   🎙️ Détection
        │
        ▼
   🌍 Traduction
        │
        ▼
   💬 Sous-titres
```

---

# 💡 Vision

> **Cine-Translate — Watch anything. Understand everything.**

Cine-Translate a pour objectif de rendre les contenus vidéo accessibles indépendamment de la langue parlée, grâce à une traduction rapide, synchronisée et naturelle.
