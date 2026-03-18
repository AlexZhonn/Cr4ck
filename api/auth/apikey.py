"""
AES-256-GCM encryption/decryption for user API keys.

Requires API_KEY_SECRET env var: 64-char hex string (32 bytes).
Generate with: python3 -c "import secrets; print(secrets.token_hex(32))"
"""

import os
import base64
from cryptography.hazmat.primitives.ciphers.aead import AESGCM

_secret: bytes | None = None


def _get_secret() -> bytes:
    global _secret
    if _secret is None:
        raw = os.getenv("API_KEY_SECRET", "")
        if len(raw) != 64:
            raise RuntimeError(
                "API_KEY_SECRET must be a 64-char hex string (32 bytes). "
                "Generate with: python3 -c \"import secrets; print(secrets.token_hex(32))\""
            )
        _secret = bytes.fromhex(raw)
    return _secret


def encrypt_key(plaintext: str) -> str:
    """Encrypt an API key string → base64-encoded ciphertext (nonce prepended)."""
    aesgcm = AESGCM(_get_secret())
    nonce = os.urandom(12)  # 96-bit nonce for AES-GCM
    ct = aesgcm.encrypt(nonce, plaintext.encode(), None)
    return base64.b64encode(nonce + ct).decode()


def decrypt_key(enc: str) -> str:
    """Decrypt a base64-encoded ciphertext → plaintext API key string."""
    aesgcm = AESGCM(_get_secret())
    data = base64.b64decode(enc)
    nonce, ct = data[:12], data[12:]
    return aesgcm.decrypt(nonce, ct, None).decode()
