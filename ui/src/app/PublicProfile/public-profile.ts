import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router } from '@angular/router';
import { HeaderComponent } from '../Header/header';

interface TopicStat {
  topic: string;
  count: number;
  best_score: number;
}

interface BadgeOut {
  id: string;
  label: string;
  description: string;
  icon: string;
  earned_at: string;
}

interface PublicProfileData {
  username: string;
  xp: number;
  level: number;
  streak_days: number;
  challenges_completed: number;
  member_since: string;
  badges: BadgeOut[];
  topic_breakdown: TopicStat[];
}

@Component({
  selector: 'app-public-profile',
  standalone: true,
  imports: [CommonModule, HeaderComponent],
  templateUrl: './public-profile.html',
  styleUrl: './public-profile.css',
})
export class PublicProfileComponent implements OnInit {
  private route = inject(ActivatedRoute);
  private router = inject(Router);

  readonly profile = signal<PublicProfileData | null>(null);
  readonly loading = signal(true);
  readonly error = signal<string | null>(null);

  async ngOnInit() {
    const username = this.route.snapshot.paramMap.get('username');
    if (!username) {
      this.router.navigate(['/']);
      return;
    }

    try {
      const res = await fetch(`/api/v1/users/${encodeURIComponent(username)}/profile`);
      if (res.status === 404) {
        this.error.set('User not found.');
        return;
      }
      if (!res.ok) throw new Error(`Failed to load profile (${res.status})`);
      this.profile.set(await res.json());
    } catch (e: any) {
      this.error.set(e.message ?? 'Could not load profile.');
    } finally {
      this.loading.set(false);
    }
  }

  xpProgress(xp: number): number {
    return xp % 100;
  }

  memberSince(dateStr: string): string {
    return new Date(dateStr).toLocaleDateString('en-US', { month: 'long', year: 'numeric' });
  }

  topicColor(index: number): string {
    const colors = [
      '#34d399',
      '#60a5fa',
      '#f59e0b',
      '#a78bfa',
      '#fb7185',
      '#38bdf8',
      '#4ade80',
      '#facc15',
    ];
    return colors[index % colors.length];
  }
}
