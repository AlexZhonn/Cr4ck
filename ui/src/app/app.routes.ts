import { Routes } from '@angular/router';
import { SandboxComponent } from './sandbox/sandbox';

export const routes: Routes = [
  { path: '', redirectTo: 'sandbox', pathMatch: 'full' },
  { path: 'sandbox', component: SandboxComponent },
  // {path: './', component: LandingPage}
];
