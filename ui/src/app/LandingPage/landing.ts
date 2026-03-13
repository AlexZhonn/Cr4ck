import { Component } from '@angular/core';
import { Router } from '@angular/router';

@Component({
  selector: 'app-landing',
  standalone: true,
  templateUrl: './landing.html',
  styleUrl: './landing.css',
})
export class LandingPageComponent {
  constructor(private router: Router) {}

  launch() {
    this.router.navigate(['/sandbox']);
  }
}
