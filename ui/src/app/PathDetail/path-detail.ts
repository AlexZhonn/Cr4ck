import { Component, OnInit, signal, computed, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, ActivatedRoute } from '@angular/router';
import { HeaderComponent } from '../Header/header';
import { AuthService } from '../services/auth.service';

interface Challenge {
  id: string;
  title: string;
  topic: string;
  difficulty: string;
  language: string;
  framework: string;
  description: string;
}

interface PathDetail {
  id: number;
  slug: string;
  title: string;
  description: string;
  topic: string | null;
  icon: string | null;
  order_index: number;
  challenge_count: number;
  difficulty_tags: string[];
  challenges: Challenge[];
}

interface ChallengeProgress {
  challenge_id: string;
  step_order: number;
  attempted: boolean;
  best_score: number;
}

interface PathProgress {
  path_id: number;
  slug: string;
  total: number;
  completed: number;
  challenges: ChallengeProgress[];
}

@Component({
  selector: 'app-path-detail',
  standalone: true,
  imports: [CommonModule, HeaderComponent],
  templateUrl: './path-detail.html',
  styleUrl: './path-detail.css',
})
export class PathDetailComponent implements OnInit {
  readonly authSvc = inject(AuthService);
  private router = inject(Router);
  private route = inject(ActivatedRoute);

  readonly path = signal<PathDetail | null>(null);
  readonly progress = signal<PathProgress | null>(null);
  readonly isLoading = signal(true);
  readonly error = signal<string | null>(null);

  readonly progressPercent = computed(() => {
    const p = this.progress();
    if (!p || p.total === 0) return 0;
    return Math.round((p.completed / p.total) * 100);
  });

  async ngOnInit() {
    const slug = this.route.snapshot.paramMap.get('slug');
    if (!slug) {
      this.router.navigate(['/paths']);
      return;
    }

    try {
      const res = await fetch(`/api/v1/paths/${slug}`);
      if (res.status === 404) {
        this.error.set('Path not found.');
        return;
      }
      if (!res.ok) throw new Error(`Failed to load path (${res.status})`);
      this.path.set(await res.json());

      // Load progress if logged in
      if (this.authSvc.isLoggedIn()) {
        const token = this.authSvc.getAccessToken();
        const progRes = await fetch(`/api/v1/paths/${slug}/progress`, {
          headers: { Authorization: `Bearer ${token}` },
        });
        if (progRes.ok) {
          this.progress.set(await progRes.json());
        }
      }
    } catch (err: any) {
      this.error.set(err.message ?? 'Could not load path.');
    } finally {
      this.isLoading.set(false);
    }
  }

  goBack() {
    this.router.navigate(['/paths']);
  }

  openChallenge(challengeId: string) {
    this.router.navigate(['/sandbox'], { queryParams: { challenge: challengeId } });
  }

  getStepProgress(challengeId: string): ChallengeProgress | null {
    return this.progress()?.challenges.find((c) => c.challenge_id === challengeId) ?? null;
  }

  difficultyClass(difficulty: string): string {
    const map: Record<string, string> = {
      Easy: 'badge-easy',
      Medium: 'badge-medium',
      Hard: 'badge-hard',
    };
    return map[difficulty] ?? '';
  }

  topicClass(topic: string | null): string {
    const map: Record<string, string> = {
      OOP: 'topic-oop',
      'Design Patterns': 'topic-patterns',
      'System Design': 'topic-system',
    };
    return topic ? (map[topic] ?? 'topic-other') : 'topic-other';
  }

  topicLabel(topic: string | null): string {
    const map: Record<string, string> = {
      OOP: 'OOP',
      'Design Patterns': 'Design Patterns',
      'System Design': 'System Design',
    };
    return topic ? (map[topic] ?? topic) : 'Multi-topic';
  }

  scoreClass(score: number): string {
    if (score >= 90) return 'score-excellent';
    if (score >= 70) return 'score-good';
    if (score >= 50) return 'score-fair';
    return 'score-low';
  }

  descriptionPreview(description: string): string {
    const firstLine = description
      .split('\n')
      .find((line) => line.trim() && !line.startsWith('**') && !line.startsWith('-'));
    return firstLine?.trim() ?? '';
  }
}
