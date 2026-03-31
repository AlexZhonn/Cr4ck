"""
Integration tests for POST /api/v1/evaluate.

AI calls are mocked so no external API key is needed.
"""

import json
from unittest.mock import AsyncMock, patch

import pytest

from tests.conftest import db_required

pytestmark = [pytest.mark.asyncio, db_required]

_MOCK_AI_RESPONSE = {
    "score": 85,
    "summary": "Good OOP design.",
    "strengths": ["Encapsulation used correctly"],
    "improvements": ["Consider dependency injection"],
    "oop_feedback": "Solid use of classes.",
    "architecture_feedback": "Could benefit from factory pattern.",
}


async def _login(client, user) -> str:
    """Helper: log in and return access token."""
    resp = await client.post(
        "/auth/v1/login",
        json={"email": user["email"], "password": user["password"]},
    )
    return resp.json()["access_token"]


class TestEvaluate:
    async def test_unauthenticated_returns_401_or_403(self, client):
        """Unauthenticated evaluate request must be rejected."""
        resp = await client.post(
            "/api/v1/evaluate",
            json={
                "challenge_id": "00000000-0000-0000-0000-000000000001",
                "challenge_title": "Test",
                "language": "python",
                "code": "class Foo: pass",
            },
        )
        assert resp.status_code in (401, 403)

    async def test_authenticated_evaluate(self, client, verified_user):
        token = await _login(client, verified_user)

        mock_message = AsyncMock()
        mock_message.content = [AsyncMock(text=json.dumps(_MOCK_AI_RESPONSE))]

        with patch("routers.evaluate.anthropic") as mock_anthropic:
            mock_client = AsyncMock()
            mock_anthropic.Anthropic.return_value = mock_client
            mock_client.messages.create = AsyncMock(return_value=mock_message)

            resp = await client.post(
                "/api/v1/evaluate",
                headers={"Authorization": f"Bearer {token}"},
                json={
                    "challenge_id": "00000000-0000-0000-0000-000000000001",
                    "challenge_title": "Sample Challenge",
                    "language": "python",
                    "code": "class BankAccount:\n    def __init__(self):\n        self.balance = 0",
                    "problem_description": "Design a bank account class",
                },
            )

        # The key assertion: authenticated requests are not rejected (401/403)
        assert resp.status_code not in (401, 403)
