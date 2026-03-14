import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { HeaderComponent } from '../Header/header';
import { AuthService, UserPublic } from '../services/auth.service';

@Component({
  selector: 'app-profile',
  standalone: true,
  imports: [CommonModule, HeaderComponent],
  templateUrl: './profile.html',
  styleUrl: './profile.css',
})
export class ProfileComponent implements OnInit {
  readonly user = this.auth.user;
  readonly isLoggedIn = this.auth.isLoggedIn;

  constructor(private router: Router, private auth: AuthService) {}

  ngOnInit() {
    if (!this.isLoggedIn()) {
      this.router.navigate(['/login']);
    }
  }

  goProblems() {
    this.router.navigate(['/problems']);
  }

  xpToNextLevel(xp: number): number {
    return Math.ceil((Math.floor(xp / 100) + 1) * 100);
  }

  xpProgress(xp: number): number {
    return (xp % 100);
  }

  level(xp: number): number {
    return Math.floor(xp / 100) + 1;
  }
}
