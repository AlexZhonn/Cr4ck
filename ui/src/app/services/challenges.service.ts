import { Injectable, signal } from '@angular/core';
import { Challenge, TestCase, Topic } from '../data/challenges';

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
  starter_codes: Record<string, string>;
  test_cases: TestCase[];
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
    starterCodes: row.starter_codes ?? {},
    testCases: row.test_cases ?? [],
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

    this._loading = fetch('/api/v1/challenges?limit=200')
      .then((res) => {
        if (!res.ok) throw new Error(`Failed to load challenges (${res.status})`);
        return res.json();
      })
      .then((page: { items: ChallengeApiRow[] }) => {
        this._challenges.set(page.items.map(toChallenge));
        this._loaded = true;
      })
      .finally(() => {
        this._loading = null;
      });

    return this._loading;
  }

  byId(id: string): Challenge | undefined {
    return this._challenges().find((c) => c.id === id);
  }

  byTopic(topic: Topic): Challenge[] {
    return this._challenges().filter((c) => c.topic === topic);
  }
}
