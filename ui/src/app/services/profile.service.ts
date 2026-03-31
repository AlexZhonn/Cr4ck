import { Injectable, signal, inject } from '@angular/core';
import { AuthService } from './auth.service';

export interface CompletedChallenge {
  challenge_id: string;
  title: string;
  topic: string;
  difficulty: 'Easy' | 'Medium' | 'Hard';
  language: string;
  best_score: number;
  attempts: number;
  first_completed_at: string;
  last_attempted_at: string;
}

@Injectable({ providedIn: 'root' })
export class ProfileService {
  private auth = inject(AuthService);

  private _completed = signal<CompletedChallenge[]>([]);
  private _loaded = false;

  /** Read-only reactive list of completed challenges. */
  readonly completed = this._completed.asReadonly();

  /** Reactive set of completed challenge IDs for O(1) lookup in templates. */
  readonly completedIds = (() => {
    const ids = signal<Set<string>>(new Set());
    // Keep ids in sync with _completed
    let prev: CompletedChallenge[] = [];
    const sync = () => {
      const cur = this._completed();
      if (cur !== prev) {
        ids.set(new Set(cur.map((c) => c.challenge_id)));
        prev = cur;
      }
    };
    // Use a computed-like approach: expose a getter that syncs on read
    return {
      get: () => {
        sync();
        return ids();
      },
    };
  })();

  async load(): Promise<void> {
    if (this._loaded) return;
    await this.reload();
  }

  /** Force-reload (call after a successful evaluation). */
  async reload(): Promise<void> {
    const token = this.auth.getAccessToken();
    if (!token) return;
    try {
      const res = await fetch('/api/profile/completed', {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (!res.ok) return;
      const data: CompletedChallenge[] = await res.json();
      this._completed.set(data);
      this._loaded = true;
    } catch {
      /* silently ignore */
    }
  }

  async getCompleted(): Promise<CompletedChallenge[]> {
    await this.load();
    return this._completed();
  }

  isCompleted(challengeId: string): boolean {
    return this._completed().some((c) => c.challenge_id === challengeId);
  }

  bestScore(challengeId: string): number | null {
    return this._completed().find((c) => c.challenge_id === challengeId)?.best_score ?? null;
  }
}
