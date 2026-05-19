import { Injectable } from '@angular/core';

export interface SolutionAuthor {
  username: string;
  xp: number;
}

export interface TopSolution {
  id: number;
  author: SolutionAuthor;
  score: number;
  language: string;
  code: string;
  shared_at: string;
}

@Injectable({ providedIn: 'root' })
export class SolutionsService {
  private authHeader(): Record<string, string> {
    const token = localStorage.getItem('cr4ck_access');
    return token ? { Authorization: `Bearer ${token}` } : {};
  }

  /** Share the current user's solution for a challenge (score must be ≥ 80). */
  async shareSolution(challengeId: string, code: string, language: string): Promise<void> {
    const res = await fetch(`/api/v1/challenges/${challengeId}/share`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', ...this.authHeader() },
      body: JSON.stringify({ code, language }),
    });
    if (!res.ok) {
      const err = await res.json().catch(() => ({ error: { message: `HTTP ${res.status}` } }));
      throw new Error(err.error?.message ?? err.detail ?? `HTTP ${res.status}`);
    }
  }

  /** Remove the user's shared solution. */
  async unshareSolution(challengeId: string): Promise<void> {
    const res = await fetch(`/api/v1/challenges/${challengeId}/share`, {
      method: 'DELETE',
      headers: this.authHeader(),
    });
    if (!res.ok) {
      const err = await res.json().catch(() => ({ error: { message: `HTTP ${res.status}` } }));
      throw new Error(err.error?.message ?? err.detail ?? `HTTP ${res.status}`);
    }
  }

  /** Fetch top 20 public solutions (only available after attempting the challenge). */
  async getTopSolutions(challengeId: string): Promise<TopSolution[]> {
    const res = await fetch(`/api/v1/challenges/${challengeId}/top-solutions`, {
      headers: this.authHeader(),
    });
    if (!res.ok) {
      const err = await res.json().catch(() => ({ error: { message: `HTTP ${res.status}` } }));
      throw new Error(err.error?.message ?? err.detail ?? `HTTP ${res.status}`);
    }
    return res.json();
  }
}
