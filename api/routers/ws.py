"""
WebSocket endpoint: ws://host/ws

Optionally authenticated via ?token=<access_jwt> query param.

Events broadcast to all connected clients:
  leaderboard_update — emitted after any XP change
    { "type": "leaderboard_update" }

Events broadcast to authenticated connections only:
  solve_event  — emitted when a user earns XP on first completion
    { "type": "solve_event", "username": str, "challenge_title": str,
      "xp_earned": int, "score": int }

Unauthenticated connections still receive leaderboard_update (no PII).

  ping/pong — client sends {"type":"ping"}, server replies {"type":"pong"}
"""

import asyncio
import json
import logging
from typing import Any, Optional

from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from jose import JWTError, jwt

from auth.tokens import SECRET_KEY, ALGORITHM

logger = logging.getLogger(__name__)

router = APIRouter(tags=["ws"])


class ConnectionManager:
    def __init__(self) -> None:
        self._all: list[WebSocket] = []
        self._authenticated: list[WebSocket] = []

    async def connect(self, ws: WebSocket, user_id: Optional[str] = None) -> None:
        await ws.accept()
        self._all.append(ws)
        if user_id:
            self._authenticated.append(ws)
        logger.info(
            "WS connect — %d total, %d authenticated",
            len(self._all),
            len(self._authenticated),
        )

    def disconnect(self, ws: WebSocket) -> None:
        self._all = [c for c in self._all if c is not ws]
        self._authenticated = [c for c in self._authenticated if c is not ws]
        logger.info(
            "WS disconnect — %d total, %d authenticated",
            len(self._all),
            len(self._authenticated),
        )

    async def broadcast(self, payload: dict[str, Any]) -> None:
        """Broadcast to all connections (e.g. leaderboard_update)."""
        await self._send_to(self._all, payload)

    async def broadcast_authenticated(self, payload: dict[str, Any]) -> None:
        """Broadcast only to authenticated connections (e.g. solve_event with PII)."""
        await self._send_to(self._authenticated, payload)

    async def _send_to(self, targets: list[WebSocket], payload: dict[str, Any]) -> None:
        if not targets:
            return
        message = json.dumps(payload)
        dead: list[WebSocket] = []
        for ws in list(targets):
            try:
                await ws.send_text(message)
            except Exception:
                dead.append(ws)
        for ws in dead:
            self.disconnect(ws)

    @property
    def connected_count(self) -> int:
        return len(self._all)


# Singleton — imported by other routers to broadcast events
manager = ConnectionManager()


def _decode_ws_token(token: str) -> Optional[str]:
    """Decode an access JWT from the WS query param. Returns user_id or None."""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        if payload.get("type") != "access":
            return None
        return payload.get("sub")
    except JWTError:
        return None


@router.websocket("/ws")
async def websocket_endpoint(ws: WebSocket, token: Optional[str] = None) -> None:
    user_id: Optional[str] = None
    if token:
        user_id = _decode_ws_token(token)

    await manager.connect(ws, user_id=user_id)
    try:
        # Send initial connection ack with current online count
        await ws.send_text(json.dumps({
            "type": "connected",
            "online": manager.connected_count,
            "authenticated": user_id is not None,
        }))
        while True:
            try:
                raw = await asyncio.wait_for(ws.receive_text(), timeout=30)
                msg = json.loads(raw)
                if msg.get("type") == "ping":
                    await ws.send_text(json.dumps({"type": "pong"}))
            except asyncio.TimeoutError:
                # Send heartbeat to keep connection alive
                await ws.send_text(json.dumps({"type": "heartbeat"}))
            except json.JSONDecodeError:
                pass
    except WebSocketDisconnect:
        pass
    finally:
        manager.disconnect(ws)
