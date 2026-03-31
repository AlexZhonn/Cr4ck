import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { HeaderComponent } from '../Header/header';
import { AuthService } from '../services/auth.service';
import { ProfileService, CompletedChallenge } from '../services/profile.service';

@Component({
  selector: 'app-profile',
  standalone: true,
  imports: [CommonModule, FormsModule, HeaderComponent],
  templateUrl: './profile.html',
  styleUrl: './profile.css',
})
export class ProfileComponent implements OnInit {
  private auth = inject(AuthService);
  private profileSvc = inject(ProfileService);
  private router = inject(Router);

  readonly user = this.auth.user;
  readonly isLoggedIn = this.auth.isLoggedIn;

  readonly completed = signal<CompletedChallenge[]>([]);
  readonly historyLoading = signal(true);
  readonly historyError = signal<string | null>(null);

  // API key settings
  readonly keyStatus = signal<{
    has_key: boolean;
    provider: string | null;
    provider_label: string | null;
  } | null>(null);
  readonly keyLoading = signal(false);
  readonly keySaving = signal(false);
  readonly keyError = signal<string | null>(null);
  readonly keySuccess = signal<string | null>(null);
  selectedProvider = 'anthropic';
  apiKeyInput = '';
  readonly providers = [
    { value: 'anthropic', label: 'Anthropic (Claude)' },
    { value: 'openai', label: 'OpenAI (GPT-4)' },
    { value: 'google', label: 'Google (Gemini)' },
  ];

  async ngOnInit() {
    if (!this.isLoggedIn()) {
      this.router.navigate(['/login']);
      return;
    }
    try {
      const [data] = await Promise.all([this.profileSvc.getCompleted(), this.loadKeyStatus()]);
      this.completed.set(data);
    } catch (e: any) {
      this.historyError.set(e.message ?? 'Could not load history');
    } finally {
      this.historyLoading.set(false);
    }
  }

  goProblems() {
    this.router.navigate(['/problems']);
  }
  goChallenge(id: string) {
    this.router.navigate(['/problems', id]);
  }

  async loadKeyStatus() {
    try {
      const res = await fetch('/auth/api-key/status', { headers: this.auth.authHeaders() });
      if (res.ok) this.keyStatus.set(await res.json());
    } catch {
      /* ignore */
    }
  }

  async saveKey() {
    if (!this.apiKeyInput.trim()) return;
    this.keySaving.set(true);
    this.keyError.set(null);
    this.keySuccess.set(null);
    try {
      const res = await fetch('/auth/api-key', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json', ...this.auth.authHeaders() },
        body: JSON.stringify({ provider: this.selectedProvider, api_key: this.apiKeyInput.trim() }),
      });
      if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        throw new Error(err.detail ?? 'Failed to save key');
      }
      this.apiKeyInput = '';
      this.keySuccess.set('API key saved successfully.');
      await this.loadKeyStatus();
    } catch (e: any) {
      this.keyError.set(e.message);
    } finally {
      this.keySaving.set(false);
    }
  }

  async removeKey() {
    this.keyLoading.set(true);
    this.keyError.set(null);
    this.keySuccess.set(null);
    try {
      await fetch('/auth/api-key', { method: 'DELETE', headers: this.auth.authHeaders() });
      this.keySuccess.set('API key removed.');
      await this.loadKeyStatus();
    } catch {
      /* ignore */
    } finally {
      this.keyLoading.set(false);
    }
  }

  // Password change
  readonly pwChanging = signal(false);
  readonly pwError = signal<string | null>(null);
  readonly pwSuccess = signal<string | null>(null);
  currentPassword = '';
  newPassword = '';
  confirmPassword = '';

  async changePassword() {
    this.pwError.set(null);
    this.pwSuccess.set(null);
    if (this.newPassword !== this.confirmPassword) {
      this.pwError.set('New passwords do not match.');
      return;
    }
    if (this.newPassword.length < 8) {
      this.pwError.set('New password must be at least 8 characters.');
      return;
    }
    this.pwChanging.set(true);
    try {
      const res = await fetch('/auth/password', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json', ...this.auth.authHeaders() },
        body: JSON.stringify({
          current_password: this.currentPassword,
          new_password: this.newPassword,
        }),
      });
      if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        throw new Error(err.error?.message ?? err.detail ?? 'Failed to change password');
      }
      this.pwSuccess.set('Password changed successfully.');
      this.currentPassword = '';
      this.newPassword = '';
      this.confirmPassword = '';
    } catch (e: any) {
      this.pwError.set(e.message);
    } finally {
      this.pwChanging.set(false);
    }
  }

  xpToNextLevel(xp: number): number {
    return Math.ceil((Math.floor(xp / 100) + 1) * 100);
  }
  xpProgress(xp: number): number {
    return xp % 100;
  }
  level(xp: number): number {
    return Math.floor(xp / 100) + 1;
  }

  difficultyClass(d: string): string {
    return d === 'Easy' ? 'badge-easy' : d === 'Medium' ? 'badge-medium' : 'badge-hard';
  }

  scoreColor(score: number): string {
    if (score >= 80) return 'score-high';
    if (score >= 50) return 'score-mid';
    return 'score-low';
  }
}
