import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { RouterLink } from '@angular/router';
import { HeaderComponent } from '../Header/header';

@Component({
  selector: 'app-forgot-password',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink, HeaderComponent],
  templateUrl: './forgot-password.html',
  styleUrl: './forgot-password.css',
})
export class ForgotPasswordComponent {
  email = '';
  isLoading = false;
  submitted = false;

  constructor(private http: HttpClient) {}

  onSubmit() {
    this.isLoading = true;
    this.http.post('/auth/forgot-password', { email: this.email }).subscribe({
      next: () => {
        this.submitted = true;
        this.isLoading = false;
      },
      error: () => {
        this.submitted = true;
        this.isLoading = false;
      }, // always silent
    });
  }
}
