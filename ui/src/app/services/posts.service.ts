import { Injectable } from '@angular/core';

export interface PostAuthor {
  id: string; // UUID
  username: string;
  xp: number;
}

export interface Post {
  id: string;
  challenge_id: string;
  parent_id: string | null;
  author: PostAuthor;
  body: string;
  is_deleted: boolean;
  vote_score: number;
  user_vote: number | null;
  reply_count: number;
  created_at: string;
  updated_at: string;
  replies: Post[];
}

@Injectable({ providedIn: 'root' })
export class PostsService {
  private authHeader(): Record<string, string> {
    const token = localStorage.getItem('cr4ck_access');
    return token ? { Authorization: `Bearer ${token}` } : {};
  }

  async listPosts(challengeId: string, offset = 0, limit = 20): Promise<Post[]> {
    const res = await fetch(
      `/api/challenges/${challengeId}/posts?limit=${limit}&offset=${offset}`,
      { headers: this.authHeader() },
    );
    if (!res.ok) throw new Error(`Failed to load posts: ${res.status}`);
    return res.json();
  }

  async createPost(challengeId: string, body: string, parentId?: string): Promise<Post> {
    const res = await fetch(`/api/challenges/${challengeId}/posts`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', ...this.authHeader() },
      body: JSON.stringify({ body, parent_id: parentId ?? null }),
    });
    if (!res.ok) {
      const err = await res.json().catch(() => ({ detail: `HTTP ${res.status}` }));
      throw new Error(err.detail ?? `HTTP ${res.status}`);
    }
    return res.json();
  }

  async editPost(postId: string, body: string): Promise<Post> {
    const res = await fetch(`/api/posts/${postId}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json', ...this.authHeader() },
      body: JSON.stringify({ body }),
    });
    if (!res.ok) {
      const err = await res.json().catch(() => ({ detail: `HTTP ${res.status}` }));
      throw new Error(err.detail ?? `HTTP ${res.status}`);
    }
    return res.json();
  }

  async deletePost(postId: string): Promise<void> {
    const res = await fetch(`/api/posts/${postId}`, {
      method: 'DELETE',
      headers: this.authHeader(),
    });
    if (!res.ok && res.status !== 204) {
      throw new Error(`Delete failed: ${res.status}`);
    }
  }

  async vote(postId: string, value: 1 | -1 | 0): Promise<Post> {
    const res = await fetch(`/api/posts/${postId}/vote`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', ...this.authHeader() },
      body: JSON.stringify({ value }),
    });
    if (!res.ok) {
      const err = await res.json().catch(() => ({ detail: `HTTP ${res.status}` }));
      throw new Error(err.detail ?? `HTTP ${res.status}`);
    }
    return res.json();
  }

  /** XP → level label */
  levelLabel(xp: number): string {
    if (xp < 100) return 'Novice';
    if (xp < 500) return 'Apprentice';
    if (xp < 1500) return 'Engineer';
    if (xp < 4000) return 'Senior';
    if (xp < 10000) return 'Staff';
    return 'Principal';
  }

  timeAgo(iso: string): string {
    const diff = Math.floor((Date.now() - new Date(iso).getTime()) / 1000);
    if (diff < 60) return `${diff}s ago`;
    if (diff < 3600) return `${Math.floor(diff / 60)}m ago`;
    if (diff < 86400) return `${Math.floor(diff / 3600)}h ago`;
    return `${Math.floor(diff / 86400)}d ago`;
  }
}
