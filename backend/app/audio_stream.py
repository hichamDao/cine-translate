import subprocess
from typing import Iterator, Optional

SAMPLE_RATE = 16000


def open_audio_stream(video_url: str) -> subprocess.Popen:
    """
    Lance ffmpeg pour lire l'URL video/audio en flux et n'en extraire
    QUE l'audio (mono, 16kHz, PCM 16 bits), sans jamais ecrire la
    video sur disque. ffmpeg gere lui-meme les requetes HTTP range
    vers l'URL source, comme le ferait un lecteur video classique.
    """
    cmd = [
        "ffmpeg",
        "-loglevel", "error",
        "-i", video_url,
        "-vn",                      # pas de piste video du tout
        "-ac", "1",                 # mono
        "-ar", str(SAMPLE_RATE),    # 16kHz, format attendu par whisper
        "-f", "s16le",              # PCM 16 bits brut, simple a decouper
        "pipe:1",
    ]
    return subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )


def iter_pcm_chunks(process: subprocess.Popen, chunk_seconds: int) -> Iterator[bytes]:
    """Lit le stdout de ffmpeg par blocs de `chunk_seconds` secondes d'audio."""
    bytes_per_second = SAMPLE_RATE * 2  # 16 bits = 2 octets/echantillon, mono
    chunk_size = bytes_per_second * chunk_seconds
    assert process.stdout is not None
    while True:
        raw = process.stdout.read(chunk_size)
        if not raw:
            break
        yield raw


def read_stderr_tail(process: subprocess.Popen) -> Optional[str]:
    """Utile pour du debug si ffmpeg echoue (URL invalide, format non supporte...)."""
    if process.stderr is None:
        return None
    data = process.stderr.read()
    return data.decode(errors="ignore") if data else None
