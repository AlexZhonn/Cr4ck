import { Component, OnInit, signal, computed, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, ActivatedRoute } from '@angular/router';
import { HeaderComponent } from '../Header/header';
import { TOPICS, Challenge, Topic } from '../data/challenges';
import { ChallengesService } from '../services/challenges.service';

type Difficulty = 'All' | 'Easy' | 'Medium' | 'Hard';

@Component({
  selector: 'app-topic-problems',
  standalone: true,
  imports: [CommonModule, HeaderComponent],
  templateUrl: './topic-problems.html',
  styleUrl: './topic-problems.css',
})
export class TopicProblemsComponent implements OnInit {
  private svc = inject(ChallengesService);
  private router = inject(Router);
  private route = inject(ActivatedRoute);

  topic = signal<Topic | null>(null);
  activeFilter = signal<Difficulty>('All');
  readonly isLoading = signal(true);
  readonly error = signal<string | null>(null);

  readonly filters: Difficulty[] = ['All', 'Easy', 'Medium', 'Hard'];

  readonly topicMeta = computed(() => {
    const t = this.topic();
    return t ? TOPICS.find(x => x.id === t) ?? null : null;
  });

  readonly challenges = computed<Challenge[]>(() => {
    const t = this.topic();
    if (!t) return [];
    const all = this.svc.byTopic(t);
    const filter = this.activeFilter();
    return filter === 'All' ? all : all.filter(c => c.difficulty === filter);
  });

  readonly counts = computed(() => {
    const t = this.topic();
    if (!t) return { All: 0, Easy: 0, Medium: 0, Hard: 0 };
    const base = this.svc.byTopic(t);
    return {
      All: base.length,
      Easy: base.filter(c => c.difficulty === 'Easy').length,
      Medium: base.filter(c => c.difficulty === 'Medium').length,
      Hard: base.filter(c => c.difficulty === 'Hard').length,
    };
  });

  async ngOnInit() {
    const topicParam = this.route.snapshot.paramMap.get('topic') as Topic | null;
    if (!topicParam || !TOPICS.find(t => t.id === topicParam)) {
      this.router.navigate(['/problems']);
      return;
    }
    this.topic.set(topicParam);

    try {
      await this.svc.load();
    } catch (err: any) {
      this.error.set(err.message ?? 'Could not load challenges.');
    } finally {
      this.isLoading.set(false);
    }
  }

  setFilter(f: Difficulty) { this.activeFilter.set(f); }
  goBack() { this.router.navigate(['/problems']); }
  selectChallenge(id: string) { this.router.navigate(['/problems', id]); }

  difficultyClass(difficulty: string): string {
    const map: Record<string, string> = {
      Easy: 'badge-easy',
      Medium: 'badge-medium',
      Hard: 'badge-hard',
    };
    return map[difficulty] ?? '';
  }

  descriptionPreview(description: string): string {
    const firstLine = description
      .split('\n')
      .find(line => line.trim() && !line.startsWith('**') && !line.startsWith('-'));
    return firstLine?.trim() ?? '';
  }
}
