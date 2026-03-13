import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { HeaderComponent } from '../Header/header';

@Component({
  selector: 'app-landing',
  standalone: true,
  imports: [HeaderComponent],
  templateUrl: './landing.html',
  styleUrl: './landing.css',
})
export class LandingPageComponent {
  constructor(private router: Router) {}

  launch() {
    this.router.navigate(['/sandbox']);
  }
}
