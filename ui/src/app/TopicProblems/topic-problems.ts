import { Component, OnInit, signal, computed, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, ActivatedRoute } from '@angular/router';
import { HeaderComponent } from '../Header/header';
import { TOPICS, Challenge, Topic } from '../data/challenges';
import { ChallengesService } from '../services/challenges.service';
import { ProfileService } from '../services/profile.service';

type Difficulty = 'All' | 'Easy' | 'Medium' | 'Hard';
type Language = 'All' | 'TypeScript' | 'Java' | 'Python' | 'C++';

@Component({
  selector: 'app-topic-problems',
  standalone: true,
  imports: [CommonModule, HeaderComponent],
  templateUrl: './topic-problems.html',
  styleUrl: './topic-problems.css',
})
export class TopicProblemsComponent implements OnInit {
  private svc = inject(ChallengesService);
  readonly profileSvc = inject(ProfileService);
  private router = inject(Router);
  private route = inject(ActivatedRoute);

  topic = signal<Topic | null>(null);
  activeFilter = signal<Difficulty>('All');
  activeLang = signal<Language>('All');
  readonly isLoading = signal(true);
  readonly error = signal<string | null>(null);

  readonly filters: Difficulty[] = ['All', 'Easy', 'Medium', 'Hard'];
  readonly languages: Language[] = ['All', 'TypeScript', 'Java', 'Python', 'C++'];

  readonly topicMeta = computed(() => {
    const t = this.topic();
    return t ? TOPICS.find(x => x.id === t) ?? null : null;
  });

  private readonly topicChallenges = computed<Challenge[]>(() => {
    const t = this.topic();
    return t ? this.svc.byTopic(t) : [];
  });

  readonly challenges = computed<Challenge[]>(() => {
    let list = this.topicChallenges();
    const diff = this.activeFilter();
    const lang = this.activeLang();
    if (diff !== 'All') list = list.filter(c => c.difficulty === diff);
    if (lang !== 'All') list = list.filter(c => c.language.toLowerCase().includes(lang.toLowerCase()));
    return list;
  });

  readonly counts = computed(() => {
    const base = this.topicChallenges();
    const lang = this.activeLang();
    const filtered = lang === 'All' ? base : base.filter(c => c.language.toLowerCase().includes(lang.toLowerCase()));
    return {
      All: filtered.length,
      Easy: filtered.filter(c => c.difficulty === 'Easy').length,
      Medium: filtered.filter(c => c.difficulty === 'Medium').length,
      Hard: filtered.filter(c => c.difficulty === 'Hard').length,
    };
  });

  readonly langCounts = computed(() => {
    const base = this.topicChallenges();
    const diff = this.activeFilter();
    const filtered = diff === 'All' ? base : base.filter(c => c.difficulty === diff);
    const result: Record<Language, number> = { All: filtered.length, TypeScript: 0, Java: 0, Python: 0, 'C++': 0 };
    for (const c of filtered) {
      for (const lang of this.languages.slice(1) as Language[]) {
        if (c.language.toLowerCase().includes(lang.toLowerCase())) result[lang]++;
      }
    }
    return result;
  });

  async ngOnInit() {
    const topicParam = this.route.snapshot.paramMap.get('topic') as Topic | null;
    if (!topicParam || !TOPICS.find(t => t.id === topicParam)) {
      this.router.navigate(['/problems']);
      return;
    }
    this.topic.set(topicParam);

    try {
      await Promise.all([this.svc.load(), this.profileSvc.load()]);
    } catch (err: any) {
      this.error.set(err.message ?? 'Could not load challenges.');
    } finally {
      this.isLoading.set(false);
    }
  }

  setFilter(f: Difficulty) { this.activeFilter.set(f); }
  setLang(l: Language) { this.activeLang.set(l); }
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
