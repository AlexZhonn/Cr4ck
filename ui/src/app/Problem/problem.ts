import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, ActivatedRoute } from '@angular/router';
import { HeaderComponent } from '../Header/header';
import { Challenge } from '../data/challenges';
import { ChallengesService } from '../services/challenges.service';

@Component({
  selector: 'app-problem',
  standalone: true,
  imports: [CommonModule, HeaderComponent],
  templateUrl: './problem.html',
  styleUrl: './problem.css',
})
export class ProblemComponent implements OnInit {
  private svc = inject(ChallengesService);
  private router = inject(Router);
  private route = inject(ActivatedRoute);

  challenge: Challenge | null = null;
  readonly isLoading = signal(true);
  readonly error = signal<string | null>(null);

  async ngOnInit() {
    const id = this.route.snapshot.paramMap.get('id');
    try {
      await this.svc.load();
      this.challenge = this.svc.byId(id ?? '') ?? null;
      if (!this.challenge) {
        this.error.set(`Challenge "${id}" not found.`);
      }
    } catch (err: any) {
      this.error.set(err.message ?? 'Could not load challenges.');
    } finally {
      this.isLoading.set(false);
    }
  }

  startChallenge() {
    if (this.challenge) {
      this.router.navigate(['/sandbox'], { queryParams: { challenge: this.challenge.id } });
    }
  }

  goBack() {
    const topic = this.challenge?.topic;
    if (topic) {
      this.router.navigate(['/problems/topic', topic]);
    } else {
      this.router.navigate(['/problems']);
    }
  }

  get difficultyClass(): string {
    const map: Record<string, string> = {
      Easy: 'badge-easy',
      Medium: 'badge-medium',
      Hard: 'badge-hard',
    };
    return map[this.challenge?.difficulty ?? ''] ?? '';
  }

  get descriptionLines(): string[] {
    return this.challenge?.description.split('\n') ?? [];
  }
}
