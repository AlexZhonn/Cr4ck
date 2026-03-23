import { TestBed } from '@angular/core/testing';
import { ChallengesService } from './challenges.service';
import { Challenge } from '../data/challenges';

const MOCK_CHALLENGE_ROW = {
  id: 'ch-001',
  title: 'Design a Stack',
  topic: 'data-structures',
  difficulty: 'easy',
  language: 'python',
  framework: 'none',
  description: 'Implement a stack class',
  starter_code: 'class Stack:\n    pass',
  test_cases: [{ input: '', expected_output: '', description: 'empty' }],
};

const MOCK_PAGE = {
  items: [MOCK_CHALLENGE_ROW],
  total: 1,
  page: 1,
  limit: 200,
  pages: 1,
};

describe('ChallengesService', () => {
  let service: ChallengesService;
  let fetchSpy: ReturnType<typeof vi.spyOn>;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(ChallengesService);
    fetchSpy = vi.spyOn(globalThis, 'fetch');
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it('challenges() starts empty', () => {
    expect(service.challenges()).toEqual([]);
  });

  it('load() fetches /api/challenges and maps rows to Challenge shape', async () => {
    fetchSpy.mockResolvedValueOnce(
      new Response(JSON.stringify(MOCK_PAGE), { status: 200 }),
    );

    await service.load();

    const challenges = service.challenges();
    expect(challenges).toHaveLength(1);

    const ch: Challenge = challenges[0];
    expect(ch.id).toBe('ch-001');
    expect(ch.title).toBe('Design a Stack');
    expect(ch.starterCode).toBe('class Stack:\n    pass');
    expect(fetchSpy).toHaveBeenCalledWith('/api/challenges?limit=200');
  });

  it('load() is idempotent — only fetches once even when called multiple times', async () => {
    fetchSpy.mockResolvedValue(
      new Response(JSON.stringify(MOCK_PAGE), { status: 200 }),
    );

    await service.load();
    await service.load();
    await service.load();

    expect(fetchSpy).toHaveBeenCalledTimes(1);
  });

  it('load() throws when API returns non-ok status', async () => {
    fetchSpy.mockResolvedValueOnce(new Response(null, { status: 500 }));

    await expect(service.load()).rejects.toThrow('Failed to load challenges');
  });

  it('byId() returns matching challenge after load', async () => {
    fetchSpy.mockResolvedValueOnce(
      new Response(JSON.stringify(MOCK_PAGE), { status: 200 }),
    );
    await service.load();

    expect(service.byId('ch-001')?.title).toBe('Design a Stack');
    expect(service.byId('nonexistent')).toBeUndefined();
  });

  it('byTopic() returns challenges filtered by topic', async () => {
    fetchSpy.mockResolvedValueOnce(
      new Response(JSON.stringify(MOCK_PAGE), { status: 200 }),
    );
    await service.load();

    const matches = service.byTopic('data-structures' as any);
    expect(matches).toHaveLength(1);

    const noMatches = service.byTopic('concurrency' as any);
    expect(noMatches).toHaveLength(0);
  });
});
