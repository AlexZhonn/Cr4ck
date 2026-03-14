import { Component, signal, computed, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, ActivatedRoute } from '@angular/router';
import { MonacoEditorModule } from 'ngx-monaco-editor-v2';
import { Challenge } from '../data/challenges';
import { ChallengesService } from '../services/challenges.service';

interface EvaluationFeedback {
  score: number;
  summary: string;
  strengths: string[];
  improvements: string[];
  oop_feedback: string;
  architecture_feedback: string;
  xp_earned: number;
  is_first_completion: boolean;
}

@Component({
  selector: 'app-sandbox',
  standalone: true,
  imports: [CommonModule, FormsModule, MonacoEditorModule],
  templateUrl: './sandbox.html',
  styleUrl: './sandbox.css',
})
export class SandboxComponent implements OnInit {
  private svc = inject(ChallengesService);
  private router = inject(Router);
  private route = inject(ActivatedRoute);

  readonly isLoadingChallenges = signal(true);
  readonly challenges = computed(() => this.svc.challenges());

  activeChallengeId = signal<string>('');
  code = '';
  isEvaluating = signal(false);
  feedback = signal<EvaluationFeedback | null>(null);
  evalError = signal<string | null>(null);

  get activeChallenge(): Challenge | null {
    return this.svc.byId(this.activeChallengeId()) ?? null;
  }

  editorOptions = this.buildEditorOptions('java');

  async ngOnInit() {
    await this.svc.load();
    this.isLoadingChallenges.set(false);

    const all = this.svc.challenges();
    if (all.length === 0) return;

    const challengeId = this.route.snapshot.queryParamMap.get('challenge');
    const initial = challengeId ? this.svc.byId(challengeId) : null;
    this.selectChallenge((initial ?? all[0]).id);
  }

  selectChallenge(id: string) {
    const challenge = this.svc.byId(id);
    if (!challenge) return;
    this.activeChallengeId.set(id);
    this.code = challenge.starterCode;
    this.feedback.set(null);
    this.editorOptions = this.buildEditorOptions(challenge.language);
  }

  goHome() { this.router.navigate(['/']); }

  async evaluateCode() {
    const challenge = this.activeChallenge;
    if (!challenge) return;

    this.isEvaluating.set(true);
    this.feedback.set(null);
    this.evalError.set(null);

    try {
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
          code: this.code,
          problem_description: challenge.description,
        }),
      });

      if (!response.ok) {
        const err = await response.json().catch(() => ({ detail: `HTTP ${response.status}` }));
        throw new Error(err.detail ?? `HTTP ${response.status}`);
      }

      this.feedback.set(await response.json());
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
    return map[this.activeChallenge?.difficulty ?? ''] ?? 'text-gray-400';
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
    return map[this.activeChallenge?.language ?? ''] ?? 'txt';
  }
}
