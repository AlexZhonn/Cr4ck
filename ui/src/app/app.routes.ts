import { Routes } from '@angular/router';
import { authGuard } from './guards/auth.guard';

export const routes: Routes = [
  {
    path: '',
    loadComponent: () => import('./LandingPage/landing').then((m) => m.LandingPageComponent),
  },
  {
    path: 'problems',
    loadComponent: () => import('./ProblemSet/problem-set').then((m) => m.ProblemSetComponent),
  },
  {
    path: 'paths',
    loadComponent: () => import('./Paths/paths').then((m) => m.PathsComponent),
  },
  // :slug must come before any wildcard — no conflict risk since slugs are kebab-case strings
  {
    path: 'paths/:slug',
    loadComponent: () => import('./PathDetail/path-detail').then((m) => m.PathDetailComponent),
  },
  // topic must come before :id so Angular doesn't treat "topic" as a problem id
  {
    path: 'problems/topic/:topic',
    loadComponent: () =>
      import('./TopicProblems/topic-problems').then((m) => m.TopicProblemsComponent),
  },
  {
    path: 'problems/:id',
    loadComponent: () => import('./Problem/problem').then((m) => m.ProblemComponent),
  },
  {
    path: 'sandbox',
    loadComponent: () => import('./sandbox/sandbox').then((m) => m.SandboxComponent),
    canActivate: [authGuard],
  },
  {
    path: 'leaderboard',
    loadComponent: () => import('./Leaderboard/leaderboard').then((m) => m.LeaderboardComponent),
  },
  {
    path: 'login',
    loadComponent: () => import('./Login/login').then((m) => m.LoginComponent),
  },
  {
    path: 'register',
    loadComponent: () => import('./Register/register').then((m) => m.RegisterComponent),
  },
  {
    path: 'about',
    loadComponent: () => import('./About/about').then((m) => m.AboutComponent),
  },
  {
    path: 'profile',
    loadComponent: () => import('./Profile/profile').then((m) => m.ProfileComponent),
  },
  {
    path: 'verify-email',
    loadComponent: () => import('./VerifyEmail/verify-email').then((m) => m.VerifyEmailComponent),
  },
  {
    path: 'forgot-password',
    loadComponent: () =>
      import('./ForgotPassword/forgot-password').then((m) => m.ForgotPasswordComponent),
  },
  {
    path: 'reset-password',
    loadComponent: () =>
      import('./ResetPassword/reset-password').then((m) => m.ResetPasswordComponent),
  },
];
