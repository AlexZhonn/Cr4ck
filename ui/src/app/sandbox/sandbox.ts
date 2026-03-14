import { Component, signal, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, ActivatedRoute } from '@angular/router';
import { MonacoEditorModule } from 'ngx-monaco-editor-v2';
interface EvaluationFeedback {
  score: number;
  summary: string;
  strengths: string[];
  improvements: string[];
  oop_feedback: string;
  architecture_feedback: string;
}

interface Challenge {
  id: string;
  title: string;
  framework: string;
  language: string;
  difficulty: 'Easy' | 'Medium' | 'Hard';
  description: string;
  starterCode: string;
}

const CHALLENGES: Challenge[] = [
  {
    id: 'oop_001',
    title: 'Library System',
    framework: 'Java / OOP',
    language: 'java',
    difficulty: 'Easy',
    description: `Design a simple library system where users can borrow and return books.

**Requirements:**
- Users can borrow books
- Users can return books
- Library tracks inventory
- A book cannot be borrowed if already checked out

**Constraints:**
- Support multiple users
- Book availability must be tracked`,
    starterCode: `public class Library {
    // TODO: implement
}

public class Book {
    // TODO: implement
}

public class User {
    // TODO: implement
}`,
  },
  {
    id: 'oop_002',
    title: 'Notification Service',
    framework: 'TypeScript / Design Patterns',
    language: 'typescript',
    difficulty: 'Medium',
    description: `Design a notification service that supports multiple delivery channels (Email, SMS, Push).

**Requirements:**
- Send notifications through Email, SMS, and Push channels
- Users can subscribe to specific channels
- Support for notification templates
- Channels can be added without modifying core logic (Open/Closed Principle)`,
    starterCode: `interface NotificationChannel {
  // TODO: define interface
}

class NotificationService {
  // TODO: implement
}

class EmailChannel implements NotificationChannel {
  // TODO: implement
}`,
  },
  {
    id: 'oop_003',
    title: 'E-Commerce Cart',
    framework: 'Python / OOP',
    language: 'python',
    difficulty: 'Medium',
    description: `Build a shopping cart system with discount strategies.

**Requirements:**
- Add/remove items from cart
- Apply discount codes (percentage, fixed amount)
- Calculate total with taxes
- Support the Strategy pattern for pricing

**Constraints:**
- Discounts should be composable
- Cart state must be consistent`,
    starterCode: `class Cart:
    # TODO: implement
    pass

class DiscountStrategy:
    # TODO: implement abstract base
    pass

class PercentageDiscount(DiscountStrategy):
    # TODO: implement
    pass`,
  },
  {
    id: 'sys_001',
    title: 'Rate Limiter',
    framework: 'Java / System Design',
    language: 'java',
    difficulty: 'Hard',
    description: `Implement a token bucket rate limiter that can throttle API requests per user.

**Requirements:**
- Limit requests per user per time window
- Token bucket algorithm
- Thread-safe implementation
- Configurable rate and burst capacity

**Constraints:**
- Must handle concurrent requests
- O(1) time complexity per request check`,
    starterCode: `import java.util.concurrent.*;

public class RateLimiter {
    // TODO: implement token bucket
}

public class TokenBucket {
    // TODO: implement
}`,
  },
];

@Component({
  selector: 'app-sandbox',
  standalone: true,
  imports: [CommonModule, FormsModule, MonacoEditorModule],
  templateUrl: './sandbox.html',
  styleUrl: './sandbox.css',
})
export class SandboxComponent implements OnInit {
  challenges = CHALLENGES;
  activeChallengeId = signal(CHALLENGES[0].id);
  code = signal(CHALLENGES[0].starterCode);
  isEvaluating = signal(false);
  feedback = signal<EvaluationFeedback | null>(null);
  evalError = signal<string | null>(null);

  get activeChallenge(): Challenge {
    return CHALLENGES.find(c => c.id === this.activeChallengeId()) ?? CHALLENGES[0];
  }

  editorOptions = this.buildEditorOptions(CHALLENGES[0].language);

  constructor(private router: Router, private route: ActivatedRoute) {}

  ngOnInit() {
    const challengeId = this.route.snapshot.queryParamMap.get('challenge');
    if (challengeId) {
      this.selectChallenge(challengeId);
    }
  }

  selectChallenge(id: string) {
    const challenge = CHALLENGES.find(c => c.id === id);
    if (!challenge) return;
    this.activeChallengeId.set(id);
    this.code.set(challenge.starterCode);
    this.feedback.set(null);
    this.editorOptions = this.buildEditorOptions(challenge.language);
  }

  goHome() {
    this.router.navigate(['/']);
  }

  async evaluateCode() {
    this.isEvaluating.set(true);
    this.feedback.set(null);
    this.evalError.set(null);

    try {
      const challenge = this.activeChallenge;
      const token = localStorage.getItem('cr4ck_access');

      const response = await fetch('/api/evaluate', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          ...(token ? { Authorization: `Bearer ${token}` } : {}),
        },
        body: JSON.stringify({
          challenge_id: challenge.id,
          challenge_title: challenge.title,
          language: challenge.language,
          code: this.code(),
          problem_description: challenge.description,
        }),
      });

      if (!response.ok) {
        const err = await response.json().catch(() => ({ detail: `HTTP ${response.status}` }));
        throw new Error(err.detail ?? `HTTP ${response.status}`);
      }

      const data: EvaluationFeedback = await response.json();
      this.feedback.set(data);
    } catch (err: any) {
      this.evalError.set(err.message ?? 'An error occurred while evaluating your code.');
    } finally {
      this.isEvaluating.set(false);
    }
  }

  get difficultyClass(): string {
    const map: Record<string, string> = {
      Easy: 'bg-emerald-500/20 text-emerald-400',
      Medium: 'bg-amber-500/20 text-amber-400',
      Hard: 'bg-rose-500/20 text-rose-400',
    };
    return map[this.activeChallenge.difficulty] ?? 'text-gray-400';
  }

  private buildEditorOptions(language: string) {
    return {
      theme: 'vs-dark',
      language,
      fontSize: 14,
      minimap: { enabled: false },
      scrollBeyondLastLine: false,
      automaticLayout: true,
      padding: { top: 16, bottom: 16 },
      fontFamily: "'JetBrains Mono', 'Fira Code', 'Cascadia Code', monospace",
      fontLigatures: true,
      lineNumbers: 'on',
      renderLineHighlight: 'all',
      cursorBlinking: 'smooth',
    };
  }

  fileExtension(): string {
    const map: Record<string, string> = { python: 'py', typescript: 'ts', java: 'java', cpp: 'cpp' };
    return map[this.activeChallenge.language] ?? this.activeChallenge.language;
  }
}
