import { Injectable, signal } from '@angular/core';
import { Challenge, TestCase, Topic } from '../data/challenges';

interface DailyApiRow {
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

@Injectable({ providedIn: 'root' })
export class DailyService {
  readonly daily = signal<Challenge | null>(null);
  readonly loading = signal(false);
  readonly error = signal<string | null>(null);

  async load(): Promise<void> {
    if (this.daily() !== null) return;
    this.loading.set(true);
    this.error.set(null);
    try {
      const res = await fetch('/api/v1/daily');
      if (res.status === 404) {
        // No daily challenge set yet — not an error worth showing
        return;
      }
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const row: DailyApiRow = await res.json();
      this.daily.set({
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
      });
    } catch (e) {
      this.error.set('Could not load today\'s challenge.');
    } finally {
      this.loading.set(false);
    }
  }
}
