import { Routes } from '@angular/router';
import { LandingPageComponent } from './LandingPage/landing';
import { SandboxComponent } from './sandbox/sandbox';
import { LoginComponent } from './Login/login';
import { RegisterComponent } from './Register/register';
export const routes: Routes = [
  { path: '', component: LandingPageComponent },
  { path: 'sandbox', component: SandboxComponent },
  { path: 'login', component: LoginComponent },
  { path: 'register', component: RegisterComponent },
];
