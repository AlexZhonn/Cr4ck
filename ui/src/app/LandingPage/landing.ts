import { Component, OnInit } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { CommonModule } from '@angular/common';
import { HeaderComponent } from '../Header/header';
import { DailyService } from '../services/daily.service';

@Component({
  selector: 'app-landing',
  standalone: true,
  imports: [HeaderComponent, CommonModule, RouterLink],
  templateUrl: './landing.html',
  styleUrl: './landing.css',
})
export class LandingPageComponent implements OnInit {
  constructor(
    private router: Router,
    readonly daily: DailyService,
  ) {}

  ngOnInit(): void {
    this.daily.load();
  }

  launch() {
    this.router.navigate(['/sandbox']);
  }

  solveDaily() {
    const c = this.daily.daily();
    if (c) {
      this.router.navigate(['/sandbox'], { queryParams: { challenge: c.id } });
    }
  }

  difficultyClass(difficulty: string): string {
    switch (difficulty) {
      case 'Easy':
        return 'daily-difficulty-easy';
      case 'Medium':
        return 'daily-difficulty-medium';
      case 'Hard':
        return 'daily-difficulty-hard';
      default:
        return '';
    }
  }
}
