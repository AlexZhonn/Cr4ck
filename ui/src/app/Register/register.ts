import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { HeaderComponent } from '../Header/header';
import { AuthService } from '../services/auth.service';

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink, HeaderComponent],
  templateUrl: './register.html',
  styleUrl: './register.css',
})
export class RegisterComponent {
  registerData = {
    UserName: '',
    email: '',
    password: '',
    confirmPassword: '',
  };

  showPassword = false;
  isLoading = false;
  errorMessage = '';

  constructor(private router: Router, private auth: AuthService) {}

  goBack() {
    this.router.navigate(['/']);
  }

  githubComingSoon = false;

  signUpWithGitHub() {
    this.githubComingSoon = true;
    setTimeout(() => { this.githubComingSoon = false; }, 3000);
  }

  async onSubmit() {
    this.errorMessage = '';

    if (this.registerData.password !== this.registerData.confirmPassword) {
      this.errorMessage = 'Passwords do not match.';
      return;
    }

    this.isLoading = true;
    try {
      await this.auth.register(
        this.registerData.UserName,
        this.registerData.email,
        this.registerData.password
      );
      this.router.navigate(['/problems']);
    } catch (err: any) {
      this.errorMessage = err.message ?? 'Registration failed. Please try again.';
    } finally {
      this.isLoading = false;
    }
  }
}
