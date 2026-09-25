import os
from dotenv import load_dotenv

load_dotenv()

WHISPER_MODEL_SIZE = os.getenv("WHISPER_MODEL_SIZE", "medium")
WHISPER_DEVICE = os.getenv("WHISPER_DEVICE", "cpu")
WHISPER_COMPUTE_TYPE = os.getenv("WHISPER_COMPUTE_TYPE", "int8")
WHISPER_BEAM_SIZE = int(os.getenv("WHISPER_BEAM_SIZE", "1"))
CHUNK_SECONDS = int(os.getenv("CHUNK_SECONDS", "8"))
DEEPL_API_KEY = os.getenv("DEEPL_API_KEY")  # optionnel, sinon fallback gratuit
DEFAULT_TARGET_LANG = os.getenv("DEFAULT_TARGET_LANG", "fr")
