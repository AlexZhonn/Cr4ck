import { Component, inject } from '@angular/core';
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
  private auth = inject(AuthService);
  private router = inject(Router);

  readonly user = this.auth.user;
  readonly isLoggedIn = this.auth.isLoggedIn;

  GotoLandingPage() {
    this.router.navigate(['/']);
  }
  GotoSandbox() {
    this.router.navigate(['/sandbox']);
  }
  GotoLogin() {
    this.router.navigate(['/login']);
  }
  GotoRegister() {
    this.router.navigate(['/register']);
  }
  GotoProblems() {
    this.router.navigate(['/problems']);
  }
  GotoPaths() {
    this.router.navigate(['/paths']);
  }
  GotoLeaderboard() {
    this.router.navigate(['/leaderboard']);
  }
  GotoAbout() {
    this.router.navigate(['/about']);
  }
  GotoProfile() {
    this.router.navigate(['/profile']);
  }

  async logout() {
    await this.auth.logout();
  }
}
