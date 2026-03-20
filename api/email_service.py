"""
Email sending via Postmark.

Requires env vars:
  POSTMARK_API_KEY  — server API token from Postmark dashboard
  POSTMARK_FROM     — verified sender address (e.g. noreply@yourdomain.com)
  FRONTEND_URL      — base URL of Angular app (e.g. https://cr4ck.dev)
"""

import logging
import os

import httpx

logger = logging.getLogger(__name__)

POSTMARK_API_KEY = os.getenv("POSTMARK_API_KEY", "")
POSTMARK_FROM = os.getenv("POSTMARK_FROM", "noreply@cr4ck.dev")
FRONTEND_URL = os.getenv("FRONTEND_URL", "http://localhost:4200")

POSTMARK_API = "https://api.postmarkapp.com/email"


def send_verification_email(to_email: str, username: str, token: str) -> None:
    """Send an account verification email via Postmark."""
    if not POSTMARK_API_KEY:
        logger.warning("[email] POSTMARK_API_KEY not set — skipping verification email")
        return

    verify_url = f"{FRONTEND_URL}/verify-email?token={token}"

    html_body = f"""
    <div style="font-family:sans-serif;max-width:560px;margin:0 auto">
      <h2 style="color:#7c3aed">Verify your Cr4ck account</h2>
      <p>Hey {username},</p>
      <p>Click the button below to verify your email address. The link expires in <strong>24 hours</strong>.</p>
      <p style="margin:32px 0">
        <a href="{verify_url}"
           style="background:#7c3aed;color:#fff;padding:12px 24px;border-radius:6px;text-decoration:none;font-weight:600">
          Verify Email
        </a>
      </p>
      <p style="color:#6b7280;font-size:13px">
        Or paste this link into your browser:<br>
        <a href="{verify_url}" style="color:#7c3aed">{verify_url}</a>
      </p>
      <hr style="border:none;border-top:1px solid #e5e7eb;margin:32px 0">
      <p style="color:#9ca3af;font-size:12px">
        If you didn't create a Cr4ck account, you can safely ignore this email.
      </p>
    </div>
    """

    text_body = (
        f"Hey {username},\n\n"
        f"Verify your Cr4ck account by visiting:\n{verify_url}\n\n"
        "The link expires in 24 hours.\n\n"
        "If you didn't create an account, ignore this email."
    )

    try:
        resp = httpx.post(
            POSTMARK_API,
            headers={
                "Accept": "application/json",
                "Content-Type": "application/json",
                "X-Postmark-Server-Token": POSTMARK_API_KEY,
            },
            json={
                "From": POSTMARK_FROM,
                "To": to_email,
                "Subject": "Verify your Cr4ck account",
                "HtmlBody": html_body,
                "TextBody": text_body,
                "MessageStream": "outbound",
            },
            timeout=10,
        )
        resp.raise_for_status()
        logger.info("[email] Verification email sent to %s", to_email)
    except httpx.HTTPStatusError as exc:
        logger.error("[email] Postmark error %s: %s", exc.response.status_code, exc.response.text)
    except Exception as exc:
        logger.error("[email] Failed to send verification email: %s", exc)
