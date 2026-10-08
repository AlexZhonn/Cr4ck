"""Submission feedback persistence and history compatibility without external services."""

from datetime import datetime, timezone
from types import SimpleNamespace
from unittest.mock import MagicMock, patch

from fastapi import Request

from routers.challenges import my_submissions
from routers.evaluate import EvaluateRequest, evaluate


AI_FEEDBACK = {
    "score": 85,
    "summary": "Good design.",
    "strengths": ["Encapsulation"],
    "improvements": ["Add validation"],
    "oop_feedback": "Clear responsibilities.",
    "architecture_feedback": "Separate storage from business logic.",
}


def test_evaluation_saves_exact_feedback_and_history_returns_it(monkeypatch):
    monkeypatch.setenv("ALLOW_SERVER_KEY", "true")
    monkeypatch.setenv("GOOGLE_API_KEY", "test-key")
    db = MagicMock()
    cur = db.cursor.return_value.__enter__.return_value
    cur.fetchone.side_effect = [
        None,
        {"best_score": 90, "attempts": 1},
        {"last_login_at": None, "streak_days": 0},
        {"xp": 100, "challenges_completed": 1},
    ]
    user = SimpleNamespace(id="user-1", username="tester")
    body = EvaluateRequest(
        challenge_id="challenge-1", challenge_title="Test", language="python", code="class A: pass"
    )
    with (
        patch("routers.evaluate._call_google", return_value=AI_FEEDBACK),
        patch("routers.evaluate._check_and_award_badges", return_value=[]),
    ):
        feedback = evaluate.__wrapped__(
            request=Request({"type": "http"}), body=body, db=db, current_user=user
        )

    inserts = [call for call in cur.execute.call_args_list if "INSERT INTO submissions" in call.args[0]]
    assert len(inserts) == 1
    params = inserts[0].args[1]
    saved = params[-1].adapted
    assert params[:5] == ("user-1", "challenge-1", 85, "python", body.code)
    assert saved == feedback.model_dump(mode="json")
    assert saved["is_first_completion"] is False
    assert saved["xp_earned"] == 0

    row = dict(id=2, score=85, language="python", code=body.code,
               submitted_at=datetime.now(timezone.utc), feedback=saved)
    cur.fetchall.return_value = [row, {**row, "id": 1, "feedback": None}]
    history = my_submissions("challenge-1", current_user=user, db=db)
    assert history[0].feedback.model_dump(mode="json") == saved
    assert history[1].feedback is None
    assert cur.execute.call_args.args[1] == ("user-1", "challenge-1")
