import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { HeaderComponent } from '../Header/header';

@Component({
  selector: 'app-about',
  standalone: true,
  imports: [HeaderComponent],
  templateUrl: './about.html',
  styleUrl: './about.css',
})
export class AboutComponent {
  constructor(private router: Router) {}

  goProblems() {
    this.router.navigate(['/problems']);
  }
}
