import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { HeaderComponent } from '../Header/header';

@Component({
  selector: 'app-reset-password',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink, HeaderComponent],
  templateUrl: './reset-password.html',
  styleUrl: './reset-password.css',
})
export class ResetPasswordComponent implements OnInit {
  token = '';
  password = '';
  showPassword = false;
  isLoading = false;
  state: 'form' | 'success' | 'error' = 'form';
  errorMessage = '';

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private http: HttpClient,
  ) {}

  ngOnInit() {
    this.token = this.route.snapshot.queryParamMap.get('token') ?? '';
    if (!this.token) {
      this.state = 'error';
      this.errorMessage = 'No reset token found in the URL.';
    }
  }

  onSubmit() {
    this.isLoading = true;
    this.http
      .post('/auth/reset-password', { token: this.token, password: this.password })
      .subscribe({
        next: () => {
          this.state = 'success';
          this.isLoading = false;
        },
        error: (err) => {
          this.state = 'error';
          this.errorMessage = err?.error?.detail ?? 'Invalid or expired reset link.';
          this.isLoading = false;
        },
      });
  }

  goLogin() {
    this.router.navigate(['/login']);
  }
}
