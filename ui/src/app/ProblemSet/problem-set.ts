import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { CommonModule } from '@angular/common';
import { HeaderComponent } from '../Header/header';

interface Challenge {
  id: string;
  title: string;
  framework: string;
  difficulty: 'Easy' | 'Medium' | 'Hard';
  description: string;
}

const CHALLENGES: Challenge[] = [
  {
    id: 'oop_001',
    title: 'Library System',
    framework: 'Java / OOP',
    difficulty: 'Easy',
    description: `Design a simple library system where users can borrow and return books.\n- Users can borrow books\n- Users can return books\n- Library tracks inventory\n- A book cannot be borrowed if already checked out`,
  },
  {
    id: 'oop_002',
    title: 'Notification Service',
    framework: 'TypeScript / Design Patterns',
    difficulty: 'Medium',
    description: `Design a notification service that supports multiple delivery channels (Email, SMS, Push).\n- Send notifications through Email, SMS, and Push channels\n- Users can subscribe to specific channels\n- Channels can be added without modifying core logic`,
  },
  {
    id: 'oop_003',
    title: 'E-Commerce Cart',
    framework: 'Python / OOP',
    difficulty: 'Medium',
    description: `Build a shopping cart system with discount strategies.\n- Add/remove items from cart\n- Apply discount codes (percentage, fixed amount)\n- Calculate total with taxes\n- Support the Strategy pattern for pricing`,
  },
  {
    id: 'sys_001',
    title: 'Rate Limiter',
    framework: 'Java / System Design',
    difficulty: 'Hard',
    description: `Implement a token bucket rate limiter that can throttle API requests per user.\n- Limit requests per user per time window\n- Token bucket algorithm\n- Thread-safe implementation\n- Configurable rate and burst capacity`,
  },
];

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
    this.router.navigate(['/sandbox'], { queryParams: { challenge: id } });
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
