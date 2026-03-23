import { TestBed } from '@angular/core/testing';
import { Router } from '@angular/router';
import { AuthService, UserPublic } from './auth.service';

const MOCK_USER: UserPublic = {
  id: 'user-123',
  username: 'testuser',
  email: 'test@example.com',
  role: 'user',
  is_active: true,
  is_verified: true,
  created_at: '2025-01-01T00:00:00Z',
  xp: 100,
  streak_days: 3,
  challenges_completed: 5,
};

const MOCK_TOKENS = {
  access_token: 'access.jwt.token',
  refresh_token: 'refresh.jwt.token',
  token_type: 'bearer',
};

describe('AuthService', () => {
  let service: AuthService;
  let fetchSpy: ReturnType<typeof vi.spyOn>;

  beforeEach(() => {
    localStorage.clear();

    TestBed.configureTestingModule({
      providers: [
        { provide: Router, useValue: { navigate: vi.fn() } },
      ],
    });
    service = TestBed.inject(AuthService);
    fetchSpy = vi.spyOn(globalThis, 'fetch');
  });

  afterEach(() => {
    vi.restoreAllMocks();
    localStorage.clear();
  });

  // ── Initial state ────────────────────────────────────────────────────────────

  it('isLoggedIn() returns false initially', () => {
    expect(service.isLoggedIn()).toBe(false);
  });

  it('user() returns null initially', () => {
    expect(service.user()).toBeNull();
  });

  it('getAccessToken() returns null when no token stored', () => {
    expect(service.getAccessToken()).toBeNull();
  });

  // ── login() ──────────────────────────────────────────────────────────────────

  it('login() stores tokens and sets user on success', async () => {
    fetchSpy
      .mockResolvedValueOnce(
        new Response(JSON.stringify(MOCK_TOKENS), { status: 200 }),
      )
      .mockResolvedValueOnce(
        new Response(JSON.stringify(MOCK_USER), { status: 200 }),
      );

    await service.login('test@example.com', 'password');

    expect(service.isLoggedIn()).toBe(true);
    expect(service.user()?.username).toBe('testuser');
    expect(localStorage.getItem('cr4ck_access')).toBe('access.jwt.token');
  });

  it('login() throws on non-ok response', async () => {
    fetchSpy.mockResolvedValueOnce(
      new Response(JSON.stringify({ detail: 'Invalid credentials' }), { status: 401 }),
    );

    await expect(service.login('bad@example.com', 'wrong')).rejects.toThrow('Invalid credentials');
    expect(service.isLoggedIn()).toBe(false);
  });

  // ── logout() ─────────────────────────────────────────────────────────────────

  it('logout() clears tokens and user state', async () => {
    localStorage.setItem('cr4ck_access', 'some-token');
    localStorage.setItem('cr4ck_refresh', 'some-refresh');

    fetchSpy.mockResolvedValue(new Response(null, { status: 204 }));

    await service.logout();

    expect(service.isLoggedIn()).toBe(false);
    expect(service.user()).toBeNull();
    expect(localStorage.getItem('cr4ck_access')).toBeNull();
    expect(localStorage.getItem('cr4ck_refresh')).toBeNull();
  });

  // ── authHeaders() ─────────────────────────────────────────────────────────────

  it('authHeaders() returns Authorization header when token exists', () => {
    localStorage.setItem('cr4ck_access', 'my-token');
    const headers = service.authHeaders();
    expect(headers['Authorization']).toBe('Bearer my-token');
  });

  it('authHeaders() returns empty object when no token', () => {
    const headers = service.authHeaders();
    expect(Object.keys(headers)).toHaveLength(0);
  });

  // ── restore() ────────────────────────────────────────────────────────────────

  it('restore() fetches /auth/me when access token is present', async () => {
    localStorage.setItem('cr4ck_access', 'stored-token');

    fetchSpy.mockResolvedValueOnce(
      new Response(JSON.stringify(MOCK_USER), { status: 200 }),
    );

    await service.restore();

    expect(service.user()?.username).toBe('testuser');
  });

  it('restore() does nothing when no token stored', async () => {
    await service.restore();
    expect(fetchSpy).not.toHaveBeenCalled();
    expect(service.isLoggedIn()).toBe(false);
  });
});
