import logging
from typing import List, Optional, Tuple

import numpy as np
from faster_whisper import WhisperModel
from faster_whisper.vad import VadOptions, get_speech_timestamps

from .config import WHISPER_MODEL_SIZE, WHISPER_DEVICE, WHISPER_COMPUTE_TYPE, WHISPER_BEAM_SIZE

logger = logging.getLogger(__name__)

_model: Optional[WhisperModel] = None

# Partager exactement les memes reglages que ceux appliques par
# WhisperModel.transcribe(vad_filter=True), sans les dupliquer ici.
_VAD_OPTIONS = VadOptions()


def has_speech(audio: np.ndarray) -> bool:
    """Dit si le chunk contient effectivement de la parole.

    Indispensable : quand le VAD ne garde AUCUN segment (chunk de silence,
    music, bruit de fond), faster_whisper compacte l'audio a un tableau vide
    et plante sur `max()` de dict vide lors de la detection de langue.
    """
    try:
        return bool(get_speech_timestamps(audio, _VAD_OPTIONS))
    except Exception as e:  # noqa: BLE001
        # Si le VAD lui-meme echoue, on laisse passer : whisper sera juge.
        logger.warning("VAD indisponible sur ce chunk (%s: %s)", type(e).__name__, e)
        return True


def get_model() -> WhisperModel:
    global _model
    if _model is None:
        _model = WhisperModel(
            WHISPER_MODEL_SIZE,
            device=WHISPER_DEVICE,
            compute_type=WHISPER_COMPUTE_TYPE,
        )
    return _model


def pcm_bytes_to_float_array(raw: bytes) -> np.ndarray:
    """Convertit du PCM 16 bits brut en tableau float32 [-1, 1], format
    attendu par whisper."""
    return np.frombuffer(raw, dtype=np.int16).astype(np.float32) / 32768.0


def transcribe_chunk(
    raw_pcm: bytes, source_lang: Optional[str] = None
) -> Tuple[List[dict], str]:
    """Transcrit un chunk audio.

    Retourne (segments, langue_detectee) ou chaque segment est
    {"start": float, "end": float, "text": str}, les timestamps etant
    RELATIFS AU DEBUT DU CHUNK (l'appelant doit ajouter l'offset global).
    """
    audio = pcm_bytes_to_float_array(raw_pcm)
    if audio.size == 0:
        return [], source_lang or "unknown"

    if not has_speech(audio):
        # Chunk sans parole : on le saute au lieu de laisser faster_whisper
        # echouer sur une detection de langue impossible.
        return [], source_lang or "unknown"

    model = get_model()
    segments_iter, info = model.transcribe(
        audio,
        language=source_lang,  # None -> detection automatique
        vad_filter=True,       # ignore les silences, evite le bruit de fond
        beam_size=WHISPER_BEAM_SIZE,  # plus bas = plus rapide, qualite legerement moindre
    )

    segments = [
        {"start": seg.start, "end": seg.end, "text": seg.text.strip()}
        for seg in segments_iter
        if seg.text.strip()
    ]
    return segments, info.language
