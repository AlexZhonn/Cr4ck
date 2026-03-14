import { Component } from '@angular/core';
import { Router } from '@angular/router';
@Component({
  selector: 'app-header',
  standalone: true,
  templateUrl: './header.html',
  styleUrl: './header.css',
})
export class HeaderComponent {
  constructor(private router: Router) {}

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
  GotoAbout() {
    this.router.navigate(['/about']);
  }
}
