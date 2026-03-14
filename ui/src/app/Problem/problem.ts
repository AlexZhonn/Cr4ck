import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, ActivatedRoute } from '@angular/router';
import { HeaderComponent } from '../Header/header';
import { Challenge, CHALLENGES } from '../data/challenges';

@Component({
  selector: 'app-problem',
  standalone: true,
  imports: [CommonModule, HeaderComponent],
  templateUrl: './problem.html',
  styleUrl: './problem.css',
})
export class ProblemComponent implements OnInit {
  challenge: Challenge | null = null;

  constructor(private router: Router, private route: ActivatedRoute) {}

  ngOnInit() {
    const id = this.route.snapshot.paramMap.get('id');
    this.challenge = CHALLENGES.find(c => c.id === id) ?? null;
    if (!this.challenge) {
      this.router.navigate(['/problems']);
    }
  }

  startChallenge() {
    if (this.challenge) {
      this.router.navigate(['/sandbox'], { queryParams: { challenge: this.challenge.id } });
    }
  }

  goBack() {
    this.router.navigate(['/problems']);
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
