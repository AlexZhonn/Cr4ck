import { Routes } from '@angular/router';
import { LandingPageComponent } from './LandingPage/landing';
import { SandboxComponent } from './sandbox/sandbox';

export const routes: Routes = [
  { path: '', component: LandingPageComponent },
  { path: 'sandbox', component: SandboxComponent },
];
