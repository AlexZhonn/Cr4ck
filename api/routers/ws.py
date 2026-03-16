"""
WebSocket endpoint: ws://host/ws

Events broadcast to all connected clients:

  solve_event  — emitted when a user earns XP on first completion
    { "type": "solve_event", "username": str, "challenge_title": str,
      "xp_earned": int, "score": int }

  leaderboard_update — emitted after any XP change so the leaderboard
    refreshes across all open tabs
    { "type": "leaderboard_update" }

  ping/pong — client sends {"type":"ping"}, server replies {"type":"pong"}
"""

import asyncio
import json
import logging
from typing import Any

from fastapi import APIRouter, WebSocket, WebSocketDisconnect

logger = logging.getLogger(__name__)

router = APIRouter(tags=["ws"])


class ConnectionManager:
    def __init__(self) -> None:
        self._active: list[WebSocket] = []

    async def connect(self, ws: WebSocket) -> None:
        await ws.accept()
        self._active.append(ws)
        logger.info("WS connect — %d active", len(self._active))

    def disconnect(self, ws: WebSocket) -> None:
        self._active = [c for c in self._active if c is not ws]
        logger.info("WS disconnect — %d active", len(self._active))

    async def broadcast(self, payload: dict[str, Any]) -> None:
        if not self._active:
            return
        message = json.dumps(payload)
        dead: list[WebSocket] = []
        for ws in list(self._active):
            try:
                await ws.send_text(message)
            except Exception:
                dead.append(ws)
        for ws in dead:
            self.disconnect(ws)

    @property
    def connected_count(self) -> int:
        return len(self._active)


# Singleton — imported by other routers to broadcast events
manager = ConnectionManager()


@router.websocket("/ws")
async def websocket_endpoint(ws: WebSocket) -> None:
    await manager.connect(ws)
    try:
        # Send initial connection ack with current online count
        await ws.send_text(json.dumps({
            "type": "connected",
            "online": manager.connected_count,
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
