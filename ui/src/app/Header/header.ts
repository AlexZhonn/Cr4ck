import { Component, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

@Component({
  selector: 'app-header',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './header.html',
  styleUrl: './header.css',
})
export class HeaderComponent {
  readonly user = this.auth.user;
  readonly isLoggedIn = this.auth.isLoggedIn;

  constructor(private router: Router, private auth: AuthService) {}

  GotoLandingPage() { this.router.navigate(['/']); }
  GotoSandbox() { this.router.navigate(['/sandbox']); }
  GotoLogin() { this.router.navigate(['/login']); }
  GotoRegister() { this.router.navigate(['/register']); }
  GotoProblems() { this.router.navigate(['/problems']); }
  GotoAbout() { this.router.navigate(['/about']); }

  async logout() {
    await this.auth.logout();
  }
}
