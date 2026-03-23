import { TestBed } from '@angular/core/testing';
import { ComponentFixture } from '@angular/core/testing';
import { HttpClientTestingModule } from '@angular/common/http/testing';
import { provideRouter, Router } from '@angular/router';
import { signal, computed } from '@angular/core';
import { LoginComponent } from './login';
import { AuthService, UserPublic } from '../services/auth.service';

function makeAuthMock(): Partial<AuthService> {
  const userSignal = signal<UserPublic | null>(null);
  return {
    login: vi.fn(),
    user: userSignal.asReadonly(),
    isLoggedIn: computed(() => userSignal() !== null),
    getAccessToken: vi.fn().mockReturnValue(null),
    authHeaders: vi.fn().mockReturnValue({}),
  } as Partial<AuthService>;
}

describe('LoginComponent', () => {
  let fixture: ComponentFixture<LoginComponent>;
  let component: LoginComponent;
  let mockAuth: Partial<AuthService>;
  let router: Router;

  beforeEach(async () => {
    mockAuth = makeAuthMock();

    await TestBed.configureTestingModule({
      imports: [LoginComponent, HttpClientTestingModule],
      providers: [
        provideRouter([]),
        { provide: AuthService, useValue: mockAuth },
      ],
    }).compileComponents();

    router = TestBed.inject(Router);
    vi.spyOn(router, 'navigate').mockResolvedValue(true);

    fixture = TestBed.createComponent(LoginComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it('should create the component', () => {
    expect(component).toBeTruthy();
  });

  it('starts with empty credentials and no error', () => {
    expect(component.loginData.email).toBe('');
    expect(component.loginData.password).toBe('');
    expect(component.errorMessage).toBe('');
    expect(component.isLoading).toBe(false);
  });

  it('onSubmit() calls auth.login with form credentials', async () => {
    (mockAuth.login as ReturnType<typeof vi.fn>).mockResolvedValueOnce(undefined);

    component.loginData.email = 'user@example.com';
    component.loginData.password = 'mypassword';
    await component.onSubmit();

    expect(mockAuth.login).toHaveBeenCalledWith('user@example.com', 'mypassword');
  });

  it('onSubmit() navigates to /problems on success', async () => {
    (mockAuth.login as ReturnType<typeof vi.fn>).mockResolvedValueOnce(undefined);

    await component.onSubmit();

    expect(router.navigate).toHaveBeenCalledWith(['/problems']);
  });

  it('onSubmit() sets errorMessage on login failure', async () => {
    (mockAuth.login as ReturnType<typeof vi.fn>).mockRejectedValueOnce(
      new Error('Invalid credentials'),
    );

    await component.onSubmit();

    expect(component.errorMessage).toBe('Invalid credentials');
    expect(component.isLoading).toBe(false);
  });

  it('onSubmit() sets showResend when error mentions email not verified', async () => {
    (mockAuth.login as ReturnType<typeof vi.fn>).mockRejectedValueOnce(
      new Error('Email not verified. Check your inbox'),
    );

    await component.onSubmit();

    expect(component.showResend).toBe(true);
    expect(component.errorMessage).toContain('not verified');
  });

  it('onSubmit() does not set showResend for generic errors', async () => {
    (mockAuth.login as ReturnType<typeof vi.fn>).mockRejectedValueOnce(
      new Error('Invalid credentials'),
    );

    await component.onSubmit();

    expect(component.showResend).toBe(false);
  });

  it('isLoading is true during login and false afterwards', async () => {
    let resolveLogin!: () => void;
    (mockAuth.login as ReturnType<typeof vi.fn>).mockReturnValue(
      new Promise<void>(res => { resolveLogin = res; }),
    );

    const submitPromise = component.onSubmit();
    expect(component.isLoading).toBe(true);

    resolveLogin();
    await submitPromise;
    expect(component.isLoading).toBe(false);
  });
});
