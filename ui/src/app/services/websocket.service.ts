import { Injectable, signal, OnDestroy } from '@angular/core';

export type WsEvent =
  | { type: 'connected'; online: number }
  | { type: 'solve_event'; username: string; challenge_title: string; xp_earned: number; score: number }
  | { type: 'leaderboard_update' }
  | { type: 'heartbeat' }
  | { type: 'pong' };

@Injectable({ providedIn: 'root' })
export class WebSocketService implements OnDestroy {
  private ws: WebSocket | null = null;
  private reconnectTimer: ReturnType<typeof setTimeout> | null = null;
  private pingTimer: ReturnType<typeof setInterval> | null = null;
  private destroyed = false;

  readonly connected = signal(false);
  readonly onlineCount = signal(0);

  /** Last N activity messages shown in the feed */
  readonly activity = signal<{ text: string; ts: number }[]>([]);

  /** Emitted whenever a leaderboard_update event arrives */
  readonly leaderboardUpdate = signal(0);

  connect(): void {
    if (this.ws || this.destroyed) return;
    const proto = location.protocol === 'https:' ? 'wss' : 'ws';
    const url = `${proto}://${location.host}/ws`;
    this._open(url);
  }

  private _open(url: string): void {
    const ws = new WebSocket(url);
    this.ws = ws;

    ws.onopen = () => {
      this.connected.set(true);
      // Ping every 20s to keep the connection alive
      this.pingTimer = setInterval(() => {
        if (ws.readyState === WebSocket.OPEN) {
          ws.send(JSON.stringify({ type: 'ping' }));
        }
      }, 20_000);
    };

    ws.onmessage = (event) => {
      try {
        const msg = JSON.parse(event.data) as WsEvent;
        this._handle(msg);
      } catch { /* ignore malformed */ }
    };

    ws.onclose = () => {
      this.connected.set(false);
      this._clearTimers();
      this.ws = null;
      if (!this.destroyed) {
        this.reconnectTimer = setTimeout(() => this._open(url), 3_000);
      }
    };

    ws.onerror = () => ws.close();
  }

  private _handle(msg: WsEvent): void {
    switch (msg.type) {
      case 'connected':
        this.onlineCount.set(msg.online);
        break;
      case 'solve_event':
        this._push(`${msg.username} solved "${msg.challenge_title}" · +${msg.xp_earned} XP · score ${msg.score}`);
        break;
      case 'leaderboard_update':
        this.leaderboardUpdate.update(n => n + 1);
        break;
    }
  }

  private _push(text: string): void {
    const MAX = 6;
    this.activity.update(prev => [{ text, ts: Date.now() }, ...prev].slice(0, MAX));
  }

  private _clearTimers(): void {
    if (this.pingTimer) { clearInterval(this.pingTimer); this.pingTimer = null; }
    if (this.reconnectTimer) { clearTimeout(this.reconnectTimer); this.reconnectTimer = null; }
  }

  disconnect(): void {
    this._clearTimers();
    this.ws?.close();
    this.ws = null;
  }

  ngOnDestroy(): void {
    this.destroyed = true;
    this.disconnect();
  }
}
