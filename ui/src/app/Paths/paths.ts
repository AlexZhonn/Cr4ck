import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { HeaderComponent } from '../Header/header';

export interface PathSummary {
  id: number;
  slug: string;
  title: string;
  description: string;
  topic: string | null;
  icon: string | null;
  order_index: number;
  challenge_count: number;
  difficulty_tags: string[];
}

@Component({
  selector: 'app-paths',
  standalone: true,
  imports: [CommonModule, HeaderComponent],
  templateUrl: './paths.html',
  styleUrl: './paths.css',
})
export class PathsComponent implements OnInit {
  private router = inject(Router);

  readonly paths = signal<PathSummary[]>([]);
  readonly isLoading = signal(true);
  readonly error = signal<string | null>(null);

  async ngOnInit() {
    try {
      const res = await fetch('/api/v1/paths');
      if (!res.ok) throw new Error(`Failed to load paths (${res.status})`);
      this.paths.set(await res.json());
    } catch (err: any) {
      this.error.set(err.message ?? 'Could not load learning paths.');
    } finally {
      this.isLoading.set(false);
    }
  }

  goToPath(slug: string) {
    this.router.navigate(['/paths', slug]);
  }

  topicLabel(topic: string | null): string {
    const map: Record<string, string> = {
      OOP: 'OOP',
      'Design Patterns': 'Patterns',
      'System Design': 'System Design',
    };
    return topic ? (map[topic] ?? topic) : 'Multi-topic';
  }

  topicClass(topic: string | null): string {
    const map: Record<string, string> = {
      OOP: 'topic-oop',
      'Design Patterns': 'topic-patterns',
      'System Design': 'topic-system',
    };
    return topic ? (map[topic] ?? 'topic-other') : 'topic-other';
  }

  difficultyClass(tag: string): string {
    const map: Record<string, string> = {
      Easy: 'diff-easy',
      Medium: 'diff-medium',
      Hard: 'diff-hard',
    };
    return map[tag] ?? '';
  }
}
