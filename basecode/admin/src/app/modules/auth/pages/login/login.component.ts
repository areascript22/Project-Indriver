import { Component, inject } from '@angular/core';
import { MatSnackBar, MatSnackBarRef } from '@angular/material/snack-bar';
import { AuthService } from '../../services/auth.service';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrl: './login.component.css',
})
export class LoginComponent {
  loginForm: FormGroup;
  isLoading: boolean = false;
  passwordVisible: boolean = false;

  constructor(
    // private snackbar: MatSnackBar,
    private authService: AuthService,
    private fb: FormBuilder,
    private router: Router
  ) {
    this.loginForm = this.fb.group({
      email: ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required, Validators.minLength(8)]],
    });
  }

  togglePasswordVisibility(): void {
    this.passwordVisible = !this.passwordVisible;
  }

  //Sign in
  async signIn() {
    this.isLoading = true;
    //get email and password
    const { email, password } = this.loginForm.value;
    //sign in
    const userCredentials = await this.authService.signIn(email, password);
    this.isLoading = false;
    if (userCredentials == null) {
      console.log('valor de user credentials: ', userCredentials);
      console.log(userCredentials);
      return;
    } else {
      this.router.navigate(['/']);
    }
  }

  //show snackbar TEST
  snack() {
    // this.snackbar.open('Error', 'Dismiss', { duration: 3000 });
  }
}
