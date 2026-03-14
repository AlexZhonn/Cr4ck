import { Component, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HeaderComponent } from '../Header/header';

interface LeaderboardEntry {
  rank: number;
  username: string;
  xp: number;
  level: number;
  challenges_completed: number;
  streak_days: number;
}

@Component({
  selector: 'app-leaderboard',
  standalone: true,
  imports: [CommonModule, HeaderComponent],
  templateUrl: './leaderboard.html',
  styleUrl: './leaderboard.css',
})
export class LeaderboardComponent implements OnInit {
  entries = signal<LeaderboardEntry[]>([]);
  isLoading = signal(true);
  error = signal<string | null>(null);

  async ngOnInit() {
    try {
      const res = await fetch('/api/leaderboard');
      if (!res.ok) throw new Error(`Failed to load leaderboard (${res.status})`);
      this.entries.set(await res.json());
    } catch (err: any) {
      this.error.set(err.message ?? 'Could not load leaderboard.');
    } finally {
      this.isLoading.set(false);
    }
  }

  rankClass(rank: number): string {
    if (rank === 1) return 'rank-gold';
    if (rank === 2) return 'rank-silver';
    if (rank === 3) return 'rank-bronze';
    return 'rank-default';
  }

  rankIcon(rank: number): string {
    if (rank === 1) return '🥇';
    if (rank === 2) return '🥈';
    if (rank === 3) return '🥉';
    return `#${rank}`;
  }
}
