import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { HeaderComponent } from '../Header/header';

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

  constructor(private router: Router) {}

  goBack() {
    this.router.navigate(['/']);
  }

  onSubmit() {
    // Placeholder for registration logic
  }
}
