"""
Password hashing with Argon2id + per-user salt.

Strategy:
  - Generate a cryptographically random 32-byte salt per user at registration.
  - The salt is stored in its own column (hex-encoded) for auditability.
  - Argon2id is used (hybrid of Argon2i and Argon2d) — the recommended variant
    for password hashing (resistant to both side-channel and GPU attacks).
  - We pepper the password before hashing: PEPPER + salt + password.
    The pepper lives only in the environment (never in the DB), so a DB dump
    alone is not enough to brute-force hashes.
"""

import os
import secrets
from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError, VerificationError, InvalidHashError

PEPPER = os.getenv("PASSWORD_PEPPER", "")

# Argon2id parameters — OWASP recommended minimums for 2024:
#   time_cost=2, memory_cost=19456 (19 MiB), parallelism=1
_ph = PasswordHasher(
    time_cost=3,        # number of iterations
    memory_cost=65536,  # 64 MiB
    parallelism=2,
    hash_len=32,
    salt_len=16,        # argon2-cffi adds its own internal salt on top of ours
)


def generate_salt() -> str:
    """Return a 32-byte cryptographically random salt as a hex string."""
    return secrets.token_hex(32)


def _peppered(salt: str, password: str) -> str:
    """Combine pepper + salt + password before hashing."""
    return f"{PEPPER}{salt}{password}"


def hash_password(password: str, salt: str) -> str:
    """
    Hash a plaintext password using Argon2id.

    Args:
        password: plaintext password from the user
        salt: per-user salt (hex string) from generate_salt()

    Returns:
        Argon2 hash string (includes algorithm params, self-contained).
    """
    return _ph.hash(_peppered(salt, password))


def verify_password(password: str, salt: str, password_hash: str) -> bool:
    """
    Verify a plaintext password against a stored Argon2 hash.

    Returns True if the password matches, False otherwise.
    Never raises — all argon2 exceptions are caught internally.
    """
    try:
        return _ph.verify(password_hash, _peppered(salt, password))
    except (VerifyMismatchError, VerificationError, InvalidHashError):
        return False


def needs_rehash(password_hash: str) -> bool:
    """
    Returns True if the hash was created with outdated parameters.
    Call this after a successful login and rehash transparently if needed.
    """
    return _ph.check_needs_rehash(password_hash)
