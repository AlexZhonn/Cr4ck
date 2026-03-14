import { Injectable, signal } from '@angular/core';
import { Challenge, Topic } from '../data/challenges';

// API response shape matches ChallengeOut from backend
interface ChallengeApiRow {
  id: string;
  title: string;
  topic: string;
  difficulty: string;
  language: string;
  framework: string;
  description: string;
  starter_code: string;
}

function toChallenge(row: ChallengeApiRow): Challenge {
  return {
    id: row.id,
    title: row.title,
    topic: row.topic as Topic,
    difficulty: row.difficulty as Challenge['difficulty'],
    language: row.language,
    framework: row.framework,
    description: row.description,
    starterCode: row.starter_code,
  };
}

@Injectable({ providedIn: 'root' })
export class ChallengesService {
  private _challenges = signal<Challenge[]>([]);
  private _loaded = false;
  private _loading: Promise<void> | null = null;

  readonly challenges = this._challenges.asReadonly();

  /** Fetch once, cache for the session. */
  async load(): Promise<void> {
    if (this._loaded) return;
    if (this._loading) return this._loading;

    this._loading = fetch('/api/challenges')
      .then(res => {
        if (!res.ok) throw new Error(`Failed to load challenges (${res.status})`);
        return res.json();
      })
      .then((rows: ChallengeApiRow[]) => {
        this._challenges.set(rows.map(toChallenge));
        this._loaded = true;
      })
      .finally(() => {
        this._loading = null;
      });

    return this._loading;
  }

  byId(id: string): Challenge | undefined {
    return this._challenges().find(c => c.id === id);
  }

  byTopic(topic: Topic): Challenge[] {
    return this._challenges().filter(c => c.topic === topic);
  }
}
