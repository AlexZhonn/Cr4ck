import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { HeaderComponent } from '../Header/header';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink, HeaderComponent],
  templateUrl: './login.html',
  styleUrl: './login.css',
})
export class LoginComponent {
  loginData = {
    email: '',
    password: '',
  };

  showPassword = false;

  constructor(private router: Router) {}

  goBack() {
    this.router.navigate(['/']);
  }

  onSubmit() {
    // Logic to be added when backend is ready
  }
}
