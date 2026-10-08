from pydantic import BaseModel

from models.user import BadgeOut


class EvaluationFeedback(BaseModel):
    score: int          # 0-100
    summary: str
    strengths: list[str]
    improvements: list[str]
    oop_feedback: str
    architecture_feedback: str
    xp_earned: int = 0
    is_first_completion: bool = True
    badges_earned: list[BadgeOut] = []

