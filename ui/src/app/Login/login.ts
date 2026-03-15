import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { HeaderComponent } from '../Header/header';
import { AuthService } from '../services/auth.service';

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
  isLoading = false;
  errorMessage = '';

  constructor(private router: Router, private auth: AuthService) {}

  goBack() {
    this.router.navigate(['/']);
  }

  githubComingSoon = false;

  loginWithGitHub() {
    this.githubComingSoon = true;
    setTimeout(() => { this.githubComingSoon = false; }, 3000);
  }

  async onSubmit() {
    this.errorMessage = '';
    this.isLoading = true;
    try {
      await this.auth.login(this.loginData.email, this.loginData.password);
      this.router.navigate(['/problems']);
    } catch (err: any) {
      this.errorMessage = err.message ?? 'Login failed. Please try again.';
    } finally {
      this.isLoading = false;
    }
  }
}
