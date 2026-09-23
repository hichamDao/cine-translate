import asyncio
from typing import Optional

from fastapi import FastAPI, Query, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware

from .audio_stream import iter_pcm_chunks, open_audio_stream, read_stderr_tail
from .config import CHUNK_SECONDS, DEFAULT_TARGET_LANG
from .transcribe import transcribe_chunk
from .translate import translate_text

app = FastAPI(title="Cine-Translate backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # a restreindre en prod
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health():
    return {"status": "ok"}


@app.websocket("/ws/translate")
async def ws_translate(
    websocket: WebSocket,
    url: str = Query(..., description="URL directe de la video/flux audio"),
    target_lang: str = Query(DEFAULT_TARGET_LANG),
    source_lang: Optional[str] = Query(
        None, description="Langue source (auto-detectee si absente)"
    ),
):
    """
    Le serveur ne stocke JAMAIS la video. Il lit l'URL en flux via ffmpeg,
    n'en extrait que l'audio, transcrit + traduit par morceaux, et pousse
    les sous-titres (cues) au fur et a mesure. Le client Flutter lit la
    video directement depuis `url`, independamment de ce websocket.
    """
    await websocket.accept()
    print(f"[ws] Nouvelle connexion - url={url} target_lang={target_lang} source_lang={source_lang}")

    loop = asyncio.get_event_loop()
    process = open_audio_stream(url)
    offset = 0.0
    chunk_num = 0

    try:
        for raw_chunk in iter_pcm_chunks(process, CHUNK_SECONDS):
            chunk_num += 1
            print(f"[ws] Chunk #{chunk_num} recu ({len(raw_chunk)} octets PCM), offset={offset:.1f}s -> transcription en cours...")

            # ffmpeg + whisper sont bloquants -> hors de la boucle asyncio
            segments, detected_lang = await loop.run_in_executor(
                None, transcribe_chunk, raw_chunk, source_lang
            )
            print(f"[ws] Chunk #{chunk_num}: {len(segments)} segment(s) detecte(s) (langue detectee: {detected_lang})")

            for seg in segments:
                print(f"[ws]   segment [{seg['start']:.1f}-{seg['end']:.1f}] original: {seg['text']!r}")
                translated = await loop.run_in_executor(
                    None,
                    translate_text,
                    seg["text"],
                    target_lang,
                    source_lang or detected_lang,
                )
                print(f"[ws]   -> traduit ({target_lang}): {translated!r}")
                await websocket.send_json(
                    {
                        "start": offset + seg["start"],
                        "end": offset + seg["end"],
                        "text": translated,
                        "original": seg["text"],
                    }
                )

            offset += CHUNK_SECONDS

        return_code = process.poll()
        if return_code not in (0, None):
            stderr_tail = read_stderr_tail(process)
            print(f"[ws] ffmpeg a echoue (code {return_code}): {stderr_tail}")
            await websocket.send_json(
                {"type": "error", "message": stderr_tail or "ffmpeg a echoue"}
            )
        else:
            print(f"[ws] Traitement termine normalement ({chunk_num} chunk(s) au total)")
            await websocket.send_json({"type": "done"})

    except WebSocketDisconnect:
        print("[ws] Client deconnecte")
    except Exception as e:  # noqa: BLE001
        print(f"[ws] ERREUR pendant le traitement: {type(e).__name__}: {e}")
        try:
            await websocket.send_json({"type": "error", "message": str(e)})
        except Exception:
            pass
    finally:
        process.terminate()
        await websocket.close()
