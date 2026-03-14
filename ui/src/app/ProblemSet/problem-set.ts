import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { CommonModule } from '@angular/common';
import { HeaderComponent } from '../Header/header';
import { Challenge, CHALLENGES } from '../data/challenges';



@Component({
  selector: 'app-problem-set',
  standalone: true,
  imports: [CommonModule, HeaderComponent],
  templateUrl: './problem-set.html',
  styleUrl: './problem-set.css',
})
export class ProblemSetComponent {
  challenges = CHALLENGES;
  constructor(private router: Router) {}

  goHome() {
    this.router.navigate(['/']);
  }

  selectChallenge(id: string) {
    this.router.navigate(['/problems', id]);
  }

  difficultyClass(difficulty: string): string {
    const map: Record<string, string> = {
      Easy: 'badge-easy',
      Medium: 'badge-medium',
      Hard: 'badge-hard',
    };
    return map[difficulty] ?? '';
  }

  descriptionPreview(description: string): string {
    return description
      .split('\n')
      .filter((line) => !line.startsWith('-'))
      .join(' ');
  }
}
