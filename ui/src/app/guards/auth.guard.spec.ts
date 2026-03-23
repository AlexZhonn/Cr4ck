import { TestBed } from '@angular/core/testing';
import { Router } from '@angular/router';
import { signal } from '@angular/core';
import { authGuard } from './auth.guard';
import { AuthService } from '../services/auth.service';

function runGuard() {
  return TestBed.runInInjectionContext(() => authGuard(null as any, null as any));
}

describe('authGuard', () => {
  let loggedInSignal: ReturnType<typeof signal<boolean>>;
  let mockAuthService: Partial<AuthService>;
  let mockRouter: Partial<Router>;

  beforeEach(() => {
    loggedInSignal = signal(false);
    // Cast to unknown first to bypass strict Signal vs computed typing
    mockAuthService = {
      isLoggedIn: loggedInSignal as unknown as AuthService['isLoggedIn'],
    };
    mockRouter = { createUrlTree: vi.fn().mockReturnValue('/login' as any) };

    TestBed.configureTestingModule({
      providers: [
        { provide: AuthService, useValue: mockAuthService },
        { provide: Router, useValue: mockRouter },
      ],
    });
  });

  it('returns true when user is logged in', () => {
    loggedInSignal.set(true);
    expect(runGuard()).toBe(true);
  });

  it('redirects to /login when user is not logged in', () => {
    loggedInSignal.set(false);
    const result = runGuard();
    expect(result).not.toBe(true);
    expect(mockRouter.createUrlTree).toHaveBeenCalledWith(['/login']);
  });
});
