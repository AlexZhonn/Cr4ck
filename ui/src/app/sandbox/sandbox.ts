import { Component, signal, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MonacoEditorModule } from 'ngx-monaco-editor-v2';

interface Problem {
  id: string;
  title: string;
  difficulty: 'Easy' | 'Medium' | 'Hard';
  description: string;
  requirements: string[];
  constraints: string[];
  starterCode: Record<string, string>;
}

interface FeedbackItem {
  type: 'pass' | 'warn' | 'info';
  message: string;
}

@Component({
  selector: 'app-sandbox',
  standalone: true,
  imports: [CommonModule, FormsModule, MonacoEditorModule],
  templateUrl: './sandbox.html',
  styleUrl: './sandbox.css',
})
export class SandboxComponent implements OnInit {
  problem: Problem = {
    id: 'oop_001',
    title: 'Library System',
    difficulty: 'Easy',
    description:
      'Design a simple library system where users can borrow and return books. The library tracks its inventory and prevents borrowing unavailable books.',
    requirements: [
      'Users can borrow books',
      'Users can return books',
      'Library tracks inventory',
      'A book cannot be borrowed if already checked out',
    ],
    constraints: ['Support multiple users', 'Book availability must be tracked'],
    starterCode: {
      java: `public class Library {
    // TODO: implement
}

public class Book {
    // TODO: implement
}

public class User {
    // TODO: implement
}`,
      python: `class Library:
    # TODO: implement
    pass

class Book:
    # TODO: implement
    pass

class User:
    # TODO: implement
    pass`,
      cpp: `#include <string>
#include <vector>

class Book {
    // TODO: implement
};

class User {
    // TODO: implement
};

class Library {
    // TODO: implement
};`,
    },
  };

  languages = ['java', 'python', 'cpp'];
  selectedLanguage = signal('java');
  activeTab = signal<'description' | 'feedback'>('description');
  isRunning = signal(false);
  isSubmitting = signal(false);
  feedback = signal<FeedbackItem[]>([]);
  testResult = signal<{ passed: number; total: number } | null>(null);
  consoleOutput = signal('');
  showConsole = signal(false);

  editorOptions = signal({
    theme: 'vs-dark',
    language: 'java',
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
  });

  code = signal('');

  ngOnInit() {
    this.code.set(this.problem.starterCode[this.selectedLanguage()]);
  }

  selectLanguage(lang: string) {
    this.selectedLanguage.set(lang);
    this.code.set(this.problem.starterCode[lang]);
    this.editorOptions.set({ ...this.editorOptions(), language: this.monacoLang(lang) });
  }

  monacoLang(lang: string): string {
    const map: Record<string, string> = { java: 'java', python: 'python', cpp: 'cpp' };
    return map[lang] ?? lang;
  }

  onCodeChange(value: string) {
    this.code.set(value);
  }

  runCode() {
    this.isRunning.set(true);
    this.showConsole.set(true);
    this.consoleOutput.set('Running tests...\n');

    // Simulate test runner
    setTimeout(() => {
      this.consoleOutput.set(
        'Running tests...\n\n[TEST 1] test_borrow_book ... PASSED\n[TEST 2] test_return_book ... PASSED\n[TEST 3] test_unavailable_book ... FAILED\n  AssertionError: Expected is_available=False, got True\n[TEST 4] test_multiple_users ... PASSED\n\nPassed 3/4 tests'
      );
      this.testResult.set({ passed: 3, total: 4 });
      this.isRunning.set(false);
    }, 1500);
  }

  submit() {
    this.isSubmitting.set(true);
    this.activeTab.set('feedback');
    this.feedback.set([]);

    setTimeout(() => {
      this.feedback.set([
        { type: 'pass', message: 'Encapsulation implemented correctly' },
        { type: 'pass', message: 'Good use of composition over inheritance' },
        { type: 'warn', message: 'Class Library violates Single Responsibility Principle' },
        { type: 'warn', message: "Method processData() is handling multiple tasks" },
        { type: 'pass', message: 'Interface segregation implemented properly' },
        { type: 'info', message: 'Consider introducing a BorrowService to separate concerns' },
      ]);
      this.testResult.set({ passed: 3, total: 4 });
      this.isSubmitting.set(false);
    }, 2000);
  }

  get difficultyClass(): string {
    const map: Record<string, string> = {
      Easy: 'text-green-400',
      Medium: 'text-yellow-400',
      Hard: 'text-red-400',
    };
    return map[this.problem.difficulty] ?? 'text-gray-400';
  }
}
