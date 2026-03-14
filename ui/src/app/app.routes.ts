import { Routes } from '@angular/router';
import { LandingPageComponent } from './LandingPage/landing';
import { SandboxComponent } from './sandbox/sandbox';
import { LoginComponent } from './Login/login';
import { RegisterComponent } from './Register/register';
import { ProblemSetComponent } from './ProblemSet/problem-set';
import { authGuard } from './guards/auth.guard';
import { AboutComponent } from './About/about';
import { ProfileComponent } from './Profile/profile';
import { ProblemComponent } from './Problem/problem';

export const routes: Routes = [
  { path: '', component: LandingPageComponent },
  { path: 'problems', component: ProblemSetComponent },
  { path: 'sandbox', component: SandboxComponent, canActivate: [authGuard] },
  { path: 'login', component: LoginComponent },
  { path: 'register', component: RegisterComponent },
  { path: 'about', component: AboutComponent },
  { path: 'problems/:id', component: ProblemComponent },
  { path: 'profile', component: ProfileComponent },
];
