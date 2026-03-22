import { Component, signal, computed, inject, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, ActivatedRoute } from '@angular/router';
import { MonacoEditorModule } from 'ngx-monaco-editor-v2';
import { marked } from 'marked';
import { Challenge } from '../data/challenges';
import { ChallengesService } from '../services/challenges.service';
import { AuthService } from '../services/auth.service';
import { WebSocketService } from '../services/websocket.service';
import { PostsService, Post } from '../services/posts.service';

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

interface TestResult {
  description: string;
  input: string;
  expected_output: string;
  actual_output: string;
  passed: boolean;
  error: string | null;
}

interface RunResponse {
  results: TestResult[];
  passed: number;
  total: number;
}

@Component({
  selector: 'app-sandbox',
  standalone: true,
  imports: [CommonModule, FormsModule, MonacoEditorModule],
  templateUrl: './sandbox.html',
  styleUrl: './sandbox.css',
})
export class SandboxComponent implements OnInit, OnDestroy {
  private svc = inject(ChallengesService);
  readonly auth = inject(AuthService);
  private router = inject(Router);
  private route = inject(ActivatedRoute);
  readonly ws = inject(WebSocketService);

  readonly isLoadingChallenges = signal(true);

  // Sidebar filters — initialised from URL params, written back on change
  filterTopic = signal<string>('');
  filterDifficulty = signal<string>('');
  filterSearch = signal<string>('');

  private _syncParams(overrides: Record<string, string | null> = {}) {
    this.router.navigate([], {
      queryParams: {
        topic: this.filterTopic() || null,
        difficulty: this.filterDifficulty() || null,
        q: this.filterSearch() || null,
        challenge: this.activeChallengeId() || null,
        ...overrides,
      },
      replaceUrl: true,
    });
  }

  setFilterTopic(value: string) {
    this.filterTopic.set(value);
    this._syncParams({ topic: value || null });
  }

  setFilterDifficulty(value: string) {
    this.filterDifficulty.set(value);
    this._syncParams({ difficulty: value || null });
  }

  setFilterSearch(value: string) {
    this.filterSearch.set(value);
    this._syncParams({ q: value || null });
  }

  readonly allTopics = computed(() => {
    const seen = new Set<string>();
    this.svc.challenges().forEach(c => seen.add(c.topic));
    return Array.from(seen).sort();
  });

  readonly challenges = computed(() => {
    let list = this.svc.challenges();
    const topic = this.filterTopic();
    const diff = this.filterDifficulty();
    const q = this.filterSearch().toLowerCase().trim();
    if (topic) list = list.filter(c => c.topic === topic);
    if (diff)  list = list.filter(c => c.difficulty === diff);
    if (q)     list = list.filter(c => c.title.toLowerCase().includes(q) || c.description?.toLowerCase().includes(q));
    return list;
  });

  activeChallengeId = signal<string>('');
  code = '';
  isEvaluating = signal(false);
  feedback = signal<EvaluationFeedback | null>(null);
  evalError = signal<string | null>(null);

  // Tests panel
  activeTab = signal<'feedback' | 'tests' | 'community'>('feedback');
  isRunning = signal(false);
  runResults = signal<RunResponse | null>(null);
  runError = signal<string | null>(null);

  // Community panel
  readonly postsSvc = inject(PostsService);
  posts = signal<Post[]>([]);
  postsLoading = signal(false);
  postsError = signal<string | null>(null);
  newPostBody = signal('');
  postSubmitting = signal(false);
  replyingTo = signal<string | null>(null);   // post id being replied to
  replyBody = signal('');
  editingPostId = signal<string | null>(null);
  editBody = signal('');

  // -----------------------------------------------------------------------
  // Draggable panel sizes (px), persisted in localStorage
  // -----------------------------------------------------------------------
  private readonly LS = {
    sidebar: 'cr4ck_sidebar_w',
    desc:    'cr4ck_desc_h',
    right:   'cr4ck_right_w',
  };

  sidebarWidth  = signal(this._load(this.LS.sidebar, 256));
  descHeight    = signal(this._load(this.LS.desc,    240));
  rightWidth    = signal(this._load(this.LS.right,   380));

  private _activeHandle: 'sidebar' | 'desc' | 'right' | null = null;
  private _dragStart = { x: 0, y: 0, init: 0 };

  private _load(key: string, fallback: number): number {
    const v = localStorage.getItem(key);
    return v ? +v : fallback;
  }

  private _save(key: string, value: number) {
    localStorage.setItem(key, String(value));
  }

  startDrag(handle: 'sidebar' | 'desc' | 'right', event: MouseEvent) {
    event.preventDefault();
    this._activeHandle = handle;
    this._dragStart = {
      x: event.clientX,
      y: event.clientY,
      init: handle === 'sidebar' ? this.sidebarWidth()
          : handle === 'desc'    ? this.descHeight()
          :                        this.rightWidth(),
    };
    document.addEventListener('mousemove', this._onDrag);
    document.addEventListener('mouseup',   this._onDragEnd);
    document.body.style.cursor = handle === 'desc' ? 'row-resize' : 'col-resize';
    document.body.style.userSelect = 'none';
  }

  private _onDrag = (e: MouseEvent) => {
    const { x, y, init } = this._dragStart;
    switch (this._activeHandle) {
      case 'sidebar': {
        const w = Math.min(Math.max(init + (e.clientX - x), 160), 480);
        this.sidebarWidth.set(w);
        this._save(this.LS.sidebar, w);
        break;
      }
      case 'desc': {
        const h = Math.min(Math.max(init + (e.clientY - y), 80), 500);
        this.descHeight.set(h);
        this._save(this.LS.desc, h);
        break;
      }
      case 'right': {
        // handle sits left of right panel: drag left → bigger, drag right → smaller
        const w = Math.min(Math.max(init + (x - e.clientX), 200), 700);
        this.rightWidth.set(w);
        this._save(this.LS.right, w);
        break;
      }
    }
  };

  private _onDragEnd = () => {
    this._activeHandle = null;
    document.removeEventListener('mousemove', this._onDrag);
    document.removeEventListener('mouseup',   this._onDragEnd);
    document.body.style.cursor = '';
    document.body.style.userSelect = '';
  };

  get activeChallenge(): Challenge | null {
    return this.svc.byId(this.activeChallengeId()) ?? null;
  }

  get hasTestCases(): boolean {
    return (this.activeChallenge?.testCases?.length ?? 0) > 0;
  }

  editorOptions = this.buildEditorOptions('java');

  async ngOnInit() {
    this.ws.connect();
    await this.svc.load();
    this.isLoadingChallenges.set(false);

    const all = this.svc.challenges();
    if (all.length === 0) return;

    const params = this.route.snapshot.queryParamMap;
    const topicParam  = params.get('topic');
    const diffParam   = params.get('difficulty');
    const searchParam = params.get('q');
    if (topicParam)  this.filterTopic.set(topicParam);
    if (diffParam)   this.filterDifficulty.set(diffParam);
    if (searchParam) this.filterSearch.set(searchParam);

    const challengeId = params.get('challenge');
    const initial = challengeId ? this.svc.byId(challengeId) : null;
    this.selectChallenge((initial ?? all[0]).id);
  }

  ngOnDestroy() {
    this.ws.disconnect();
    this._onDragEnd();
  }

  selectChallenge(id: string) {
    const challenge = this.svc.byId(id);
    if (!challenge) return;
    this.activeChallengeId.set(id);
    this.code = challenge.starterCode;
    this.feedback.set(null);
    this.runResults.set(null);
    this.runError.set(null);
    this.posts.set([]);
    this.postsError.set(null);
    this.replyingTo.set(null);
    this.editingPostId.set(null);
    this.editorOptions = this.buildEditorOptions(challenge.language);
  }

  async loadPosts() {
    const id = this.activeChallengeId();
    if (!id) return;
    this.postsLoading.set(true);
    this.postsError.set(null);
    try {
      this.posts.set(await this.postsSvc.listPosts(id));
    } catch (e: any) {
      this.postsError.set(e.message ?? 'Failed to load posts');
    } finally {
      this.postsLoading.set(false);
    }
  }

  async switchTab(tab: 'feedback' | 'tests' | 'community') {
    this.activeTab.set(tab);
    if (tab === 'community' && this.posts().length === 0) {
      await this.loadPosts();
    }
  }

  async submitPost() {
    const id = this.activeChallengeId();
    const body = this.newPostBody().trim();
    if (!id || !body) return;
    this.postSubmitting.set(true);
    try {
      const post = await this.postsSvc.createPost(id, body);
      this.posts.update(p => [post, ...p]);
      this.newPostBody.set('');
    } catch (e: any) {
      this.postsError.set(e.message ?? 'Failed to post');
    } finally {
      this.postSubmitting.set(false);
    }
  }

  async submitReply(parentId: string) {
    const id = this.activeChallengeId();
    const body = this.replyBody().trim();
    if (!id || !body) return;
    this.postSubmitting.set(true);
    try {
      const reply = await this.postsSvc.createPost(id, body, parentId);
      this.posts.update(posts =>
        posts.map(p => p.id === parentId ? { ...p, replies: [...(p.replies ?? []), reply], reply_count: p.reply_count + 1 } : p)
      );
      this.replyingTo.set(null);
      this.replyBody.set('');
    } catch (e: any) {
      this.postsError.set(e.message ?? 'Failed to post reply');
    } finally {
      this.postSubmitting.set(false);
    }
  }

  startEdit(post: Post) {
    this.editingPostId.set(post.id);
    this.editBody.set(post.body);
  }

  async saveEdit(postId: string) {
    const body = this.editBody().trim();
    if (!body) return;
    try {
      const updated = await this.postsSvc.editPost(postId, body);
      this.posts.update(posts =>
        posts.map(p => p.id === postId ? { ...p, body: updated.body, updated_at: updated.updated_at } : p)
      );
      this.editingPostId.set(null);
    } catch (e: any) {
      this.postsError.set(e.message ?? 'Failed to edit post');
    }
  }

  async deletePost(postId: string) {
    try {
      await this.postsSvc.deletePost(postId);
      this.posts.update(posts => posts.map(p => p.id === postId ? { ...p, is_deleted: true, body: '[deleted]' } : p));
    } catch (e: any) {
      this.postsError.set(e.message ?? 'Failed to delete post');
    }
  }

  async votePost(postId: string, value: 1 | -1 | 0) {
    try {
      const updated = await this.postsSvc.vote(postId, value);
      this.posts.update(posts =>
        posts.map(p => p.id === postId ? { ...p, vote_score: updated.vote_score, user_vote: updated.user_vote } : p)
      );
    } catch { /* ignore vote errors */ }
  }

  goHome() { this.router.navigate(['/']); }

  renderMarkdown(text: string): string {
    return marked.parse(text, { async: false }) as string;
  }

  isOwnPost(post: Post): boolean {
    return !!this.auth.user() && post.author.username === this.auth.user()!.username;
  }

  async evaluateCode() {
    const challenge = this.activeChallenge;
    if (!challenge) return;

    if (!this.auth.isLoggedIn()) {
      this.evalError.set('You must be logged in to evaluate code. Please log in and try again.');
      return;
    }

    this.activeTab.set('feedback');
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

      if (response.status === 401) {
        await this.auth.logout();
        this.router.navigate(['/login'], { queryParams: { returnUrl: '/sandbox' } });
        return;
      }

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

  async runTests() {
    const challenge = this.activeChallenge;
    if (!challenge) return;

    if (!this.auth.isLoggedIn()) {
      this.runError.set('You must be logged in to run tests. Please log in and try again.');
      return;
    }

    this.activeTab.set('tests');
    this.isRunning.set(true);
    this.runResults.set(null);
    this.runError.set(null);

    try {
      const token = localStorage.getItem('cr4ck_access');
      const response = await fetch('/api/run', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          ...(token ? { Authorization: `Bearer ${token}` } : {}),
        },
        body: JSON.stringify({
          challenge_id: challenge.id,
          language: challenge.language,
          code: this.code,
        }),
      });

      if (response.status === 401) {
        await this.auth.logout();
        this.router.navigate(['/login'], { queryParams: { returnUrl: '/sandbox' } });
        return;
      }

      if (!response.ok) {
        const err = await response.json().catch(() => ({ detail: `HTTP ${response.status}` }));
        throw new Error(err.detail ?? `HTTP ${response.status}`);
      }

      this.runResults.set(await response.json());
    } catch (err: any) {
      this.runError.set(err.message ?? 'An error occurred while running tests.');
    } finally {
      this.isRunning.set(false);
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
