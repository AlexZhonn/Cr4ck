import { Injectable, signal, computed } from '@angular/core';
import { Router } from '@angular/router';

/**
 * Extracts a human-readable message from an API error response.
 * Handles both the new standardized shape { error: { message } }
 * and the legacy FastAPI shapes { detail: string | array }.
 */
function extractErrorMessage(err: any, fallback: string): string {
  if (err?.error?.message) return err.error.message;
  if (typeof err?.detail === 'string') return err.detail;
  if (Array.isArray(err?.detail)) return err.detail.map((e: any) => e.msg).join(', ');
  return fallback;
}

export interface UserPublic {
  id: string;
  username: string;
  email: string;
  role: string;
  is_active: boolean;
  is_verified: boolean;
  created_at: string;
  xp: number;
  streak_days: number;
  challenges_completed: number;
}

interface TokenResponse {
  access_token: string;
  refresh_token: string;
  token_type: string;
}

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly ACCESS_KEY = 'cr4ck_access';
  private readonly REFRESH_KEY = 'cr4ck_refresh';

  private _user = signal<UserPublic | null>(null);
  readonly user = this._user.asReadonly();
  readonly isLoggedIn = computed(() => this._user() !== null);

  constructor(private router: Router) {}

  /** Called by APP_INITIALIZER — awaited before any route renders. */
  async restore(): Promise<void> {
    if (this.getAccessToken()) {
      await this.fetchMe().catch(() => this.clearTokens());
    }
  }

  getAccessToken(): string | null {
    return localStorage.getItem(this.ACCESS_KEY);
  }

  private getRefreshToken(): string | null {
    return localStorage.getItem(this.REFRESH_KEY);
  }

  private storeTokens(tokens: TokenResponse): void {
    localStorage.setItem(this.ACCESS_KEY, tokens.access_token);
    localStorage.setItem(this.REFRESH_KEY, tokens.refresh_token);
  }

  private clearTokens(): void {
    localStorage.removeItem(this.ACCESS_KEY);
    localStorage.removeItem(this.REFRESH_KEY);
    this._user.set(null);
  }

  async login(email: string, password: string): Promise<void> {
    const res = await fetch('/auth/v1/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password }),
    });

    if (!res.ok) {
      const err = await res.json().catch(() => ({}));
      throw new Error(extractErrorMessage(err, 'Login failed'));
    }

    const tokens: TokenResponse = await res.json();
    this.storeTokens(tokens);
    await this.fetchMe();
  }

  async register(username: string, email: string, password: string): Promise<void> {
    const res = await fetch('/auth/v1/register', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ username, email, password }),
    });

    if (!res.ok) {
      const err = await res.json().catch(() => ({}));
      throw new Error(extractErrorMessage(err, 'Registration failed'));
    }
    // Auto-login after registration
    await this.login(email, password);
  }

  async fetchMe(): Promise<void> {
    const token = this.getAccessToken();
    if (!token) return;

    const res = await fetch('/auth/v1/me', {
      headers: { Authorization: `Bearer ${token}` },
    });

    if (res.status === 401) {
      // Try refreshing the token
      await this.refresh();
      return;
    }

    if (!res.ok) {
      this.clearTokens();
      return;
    }

    this._user.set(await res.json());
  }

  async refresh(): Promise<void> {
    const refreshToken = this.getRefreshToken();
    if (!refreshToken) {
      this.clearTokens();
      return;
    }

    const res = await fetch('/auth/v1/refresh', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refresh_token: refreshToken }),
    });

    if (!res.ok) {
      this.clearTokens();
      return;
    }

    const tokens: TokenResponse = await res.json();
    this.storeTokens(tokens);
    await this.fetchMe();
  }

  async logout(): Promise<void> {
    const refreshToken = this.getRefreshToken();
    if (refreshToken) {
      fetch('/auth/v1/logout', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refresh_token: refreshToken }),
      }).catch(() => {});
    }
    this.clearTokens();
    this.router.navigate(['/']);
  }

  /** Returns headers with Bearer token for authenticated API calls */
  authHeaders(): Record<string, string> {
    const token = this.getAccessToken();
    return token ? { Authorization: `Bearer ${token}` } : {};
  }
}
