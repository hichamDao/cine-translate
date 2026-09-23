from typing import Optional

from .config import DEEPL_API_KEY


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
        target_lang=target_lang.upper(),
        source_lang=source_lang.upper() if source_lang else None,
    )
    return result.text


def _translate_google_free(text: str, target_lang: str, source_lang: Optional[str]) -> str:
    # Fallback gratuit, sans cle API. Pratique pour du dev/MVP, qualite
    # inferieure a DeepL. A remplacer en prod si le volume est important.
    from deep_translator import GoogleTranslator

    return GoogleTranslator(
        source=source_lang or "auto", target=target_lang
    ).translate(text)
