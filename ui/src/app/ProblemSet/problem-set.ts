import { Component, OnInit, signal, computed, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { HeaderComponent } from '../Header/header';
import { TOPICS, Topic } from '../data/challenges';
import { ChallengesService } from '../services/challenges.service';

@Component({
  selector: 'app-problem-set',
  standalone: true,
  imports: [CommonModule, HeaderComponent],
  templateUrl: './problem-set.html',
  styleUrl: './problem-set.css',
})
export class ProblemSetComponent implements OnInit {
  private svc = inject(ChallengesService);
  private router = inject(Router);

  readonly topics = TOPICS;
  readonly isLoading = signal(true);
  readonly error = signal<string | null>(null);
  readonly totalChallenges = computed(() => this.svc.challenges().length);

  async ngOnInit() {
    try {
      await this.svc.load();
    } catch (err: any) {
      this.error.set(err.message ?? 'Could not load challenges.');
    } finally {
      this.isLoading.set(false);
    }
  }

  countForTopic(topic: Topic): number {
    return this.svc.byTopic(topic).length;
  }

  difficultyRange(topic: Topic): string {
    const list = this.svc.byTopic(topic);
    const has = (d: string) => list.some(c => c.difficulty === d);
    const parts: string[] = [];
    if (has('Easy')) parts.push('Easy');
    if (has('Medium')) parts.push('Medium');
    if (has('Hard')) parts.push('Hard');
    return parts.join(' · ');
  }

  goToTopic(topic: Topic) {
    this.router.navigate(['/problems/topic', topic]);
  }
}
