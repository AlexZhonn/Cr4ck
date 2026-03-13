import { Component, signal, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { MonacoEditorModule } from 'ngx-monaco-editor-v2';

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
  feedback = signal<string | null>(null);

  get activeChallenge(): Challenge {
    return CHALLENGES.find(c => c.id === this.activeChallengeId()) ?? CHALLENGES[0];
  }

  editorOptions = this.buildEditorOptions(CHALLENGES[0].language);

  constructor(private router: Router) {}

  ngOnInit() {}

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

    try {
      const challenge = this.activeChallenge;
      const prompt = `
You are an expert software architect evaluating a code submission for an OOP and System Design challenge.

Challenge: ${challenge.title}
Framework/Language: ${challenge.framework}
Description:
${challenge.description}

User's Code:
\`\`\`${challenge.language}
${this.code()}
\`\`\`

Evaluate based on:
1. Correctness: Does it meet requirements?
2. OOP Principles: Encapsulation, inheritance, polymorphism?
3. Framework Best Practices: Idiomatic usage?
4. Security & Validation: Any issues?

Respond in Markdown. Start with **Pass** or **Needs Improvement**. Be concise and educational.
      `.trim();

      const response = await fetch('/api/evaluate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ prompt, challenge }),
      });

      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      const data = await response.json();
      this.feedback.set(data.text ?? 'No feedback generated.');
    } catch (err) {
      console.error('Evaluation error:', err);
      this.feedback.set('An error occurred while evaluating your code. Please try again.');
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
