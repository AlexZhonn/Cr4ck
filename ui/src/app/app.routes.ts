import { Routes } from '@angular/router';
import { LandingPageComponent } from './LandingPage/landing';
import { SandboxComponent } from './sandbox/sandbox';
import { LoginComponent } from './Login/login';
import { RegisterComponent } from './Register/register';
import { ProblemSetComponent } from './ProblemSet/problem-set';

export const routes: Routes = [
  { path: '', component: LandingPageComponent },
  { path: 'problems', component: ProblemSetComponent },
  { path: 'sandbox', component: SandboxComponent },
  { path: 'login', component: LoginComponent },
  { path: 'register', component: RegisterComponent },
];
