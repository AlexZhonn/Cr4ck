"""
Unit tests for auth/password.py — no database required.
"""

from auth.password import (
    generate_salt,
    hash_password,
    needs_rehash,
    verify_password,
)


class TestGenerateSalt:
    def test_returns_hex_string(self):
        salt = generate_salt()
        assert isinstance(salt, str)
        # 32 bytes → 64 hex chars
        assert len(salt) == 64

    def test_unique_per_call(self):
        salts = {generate_salt() for _ in range(100)}
        assert len(salts) == 100  # all unique


class TestHashPassword:
    def test_returns_argon2_hash(self):
        salt = generate_salt()
        h = hash_password("mysecret", salt)
        assert h.startswith("$argon2id$")

    def test_same_inputs_produce_different_hashes(self):
        # argon2-cffi adds its own internal random salt on top of ours
        salt = generate_salt()
        h1 = hash_password("mysecret", salt)
        h2 = hash_password("mysecret", salt)
        assert h1 != h2


class TestVerifyPassword:
    def test_correct_password_returns_true(self):
        salt = generate_salt()
        pw = "correct_horse_battery_staple"
        h = hash_password(pw, salt)
        assert verify_password(pw, salt, h) is True

    def test_wrong_password_returns_false(self):
        salt = generate_salt()
        h = hash_password("correct", salt)
        assert verify_password("wrong", salt, h) is False

    def test_wrong_salt_returns_false(self):
        salt1, salt2 = generate_salt(), generate_salt()
        h = hash_password("password", salt1)
        assert verify_password("password", salt2, h) is False

    def test_invalid_hash_returns_false(self):
        assert verify_password("anything", generate_salt(), "not-a-real-hash") is False

    def test_empty_password_handled(self):
        salt = generate_salt()
        h = hash_password("", salt)
        assert verify_password("", salt, h) is True
        assert verify_password("notempty", salt, h) is False


class TestNeedsRehash:
    def test_fresh_hash_does_not_need_rehash(self):
        salt = generate_salt()
        h = hash_password("password", salt)
        assert needs_rehash(h) is False
