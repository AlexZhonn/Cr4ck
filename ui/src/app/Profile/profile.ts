import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { HeaderComponent } from '../Header/header';
import { AuthService } from '../services/auth.service';
import { ProfileService, CompletedChallenge } from '../services/profile.service';

@Component({
  selector: 'app-profile',
  standalone: true,
  imports: [CommonModule, HeaderComponent],
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

  async ngOnInit() {
    if (!this.isLoggedIn()) {
      this.router.navigate(['/login']);
      return;
    }
    try {
      const data = await this.profileSvc.getCompleted();
      this.completed.set(data);
    } catch (e: any) {
      this.historyError.set(e.message ?? 'Could not load history');
    } finally {
      this.historyLoading.set(false);
    }
  }

  goProblems() { this.router.navigate(['/problems']); }
  goChallenge(id: string) { this.router.navigate(['/problems', id]); }

  xpToNextLevel(xp: number): number { return Math.ceil((Math.floor(xp / 100) + 1) * 100); }
  xpProgress(xp: number): number { return xp % 100; }
  level(xp: number): number { return Math.floor(xp / 100) + 1; }

  difficultyClass(d: string): string {
    return d === 'Easy' ? 'badge-easy' : d === 'Medium' ? 'badge-medium' : 'badge-hard';
  }

  scoreColor(score: number): string {
    if (score >= 80) return 'score-high';
    if (score >= 50) return 'score-mid';
    return 'score-low';
  }
}
