import time
from typing import Optional

from .config import DEEPL_API_KEY


def translate_batch(
    texts: list[str], target_lang: str, source_lang: Optional[str] = None
) -> list[str]:
    """Traduit plusieurs textes en UN SEUL appel API quand possible : bien
    plus rapide que N appels sequentiels, et reduit le risque de
    rate-limiting sur le fallback gratuit."""
    if not texts:
        return []
    if DEEPL_API_KEY:
        return _translate_batch_deepl(texts, target_lang, source_lang)
    return _translate_batch_google_free(texts, target_lang, source_lang)


def _translate_batch_deepl(
    texts: list[str], target_lang: str, source_lang: Optional[str]
) -> list[str]:
    import deepl

    translator = deepl.Translator(DEEPL_API_KEY)
    results = translator.translate_text(
        texts,
        target_lang=_normalize_deepl_target(target_lang),
        source_lang=source_lang.upper() if source_lang else None,
    )
    return [r.text for r in results]


def _translate_batch_google_free(
    texts: list[str],
    target_lang: str,
    source_lang: Optional[str],
    max_retries: int = 3,
) -> list[str]:
    from deep_translator import GoogleTranslator
    from deep_translator.exceptions import TooManyRequests

    last_error: Exception | None = None
    for attempt in range(max_retries):
        try:
            return GoogleTranslator(
                source=source_lang or "auto", target=target_lang
            ).translate_batch(texts)
        except TooManyRequests as e:
            last_error = e
            wait = 2 * (attempt + 1)
            print(
                f"[translate] Rate-limite par Google (tentative {attempt + 1}/{max_retries}), "
                f"nouvel essai dans {wait}s...",
                flush=True,
            )
            time.sleep(wait)

    raise last_error


def translate_text(text: str, target_lang: str, source_lang: Optional[str] = None) -> str:
    if not text:
        return text
    if DEEPL_API_KEY:
        return _translate_deepl(text, target_lang, source_lang)
    return _translate_google_free(text, target_lang, source_lang)


def _translate_deepl(text: str, target_lang: str, source_lang: Optional[str]) -> str:
    import deepl

    translator = deepl.Translator(DEEPL_API_KEY)
    result = translator.translate_text(
        text,
        target_lang=_normalize_deepl_target(target_lang),
        source_lang=source_lang.upper() if source_lang else None,
    )
    return result.text


def _normalize_deepl_target(target_lang: str) -> str:
    """DeepL exige une variante precise pour EN et PT en langue CIBLE
    (le code generique est deprecie et rejete par l'API)."""
    code = target_lang.upper()
    if code == "EN":
        return "EN-US"
    if code == "PT":
        return "PT-PT"
    return code


def _translate_google_free(
    text: str, target_lang: str, source_lang: Optional[str], max_retries: int = 3
) -> str:
    # Fallback gratuit, sans cle API. Pratique pour du dev/MVP, mais bati sur
    # un point d'acces non officiel de Google -> sujet a du rate-limiting
    # (ex: TooManyRequests). On reessaie avec un delai croissant avant
    # d'abandonner. Pour un usage serieux/en production, utiliser DeepL
    # (DEEPL_API_KEY) est fortement recommande.
    from deep_translator import GoogleTranslator
    from deep_translator.exceptions import TooManyRequests

    last_error: Exception | None = None
    for attempt in range(max_retries):
        try:
            return GoogleTranslator(
                source=source_lang or "auto", target=target_lang
            ).translate(text)
        except TooManyRequests as e:
            last_error = e
            wait = 2 * (attempt + 1)  # 2s, 4s, 6s...
            print(
                f"[translate] Rate-limite par Google (tentative {attempt + 1}/{max_retries}), "
                f"nouvel essai dans {wait}s...",
                flush=True,
            )
            time.sleep(wait)

    raise last_error
