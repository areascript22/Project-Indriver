import { Component } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { AuthService } from '../../services/auth.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-password-recovery',
  templateUrl: './password-recovery.component.html',
  styleUrl: './password-recovery.component.css',
})
export class PasswordRecoveryComponent {
  passwordForm: FormGroup;
  isLoading: boolean = false;

  constructor(
    private formBuilder: FormBuilder,
    private authService: AuthService,
    private router: Router
  ) {
    this.passwordForm = formBuilder.group({
      email: ['', [Validators.required, Validators.email]],
    });
  }

  //Recover password
  async recoverPassword(): Promise<any> {
    this.isLoading = true;
    //get email from Form
    const { email } = this.passwordForm.value;
    await this.authService.sendPasswordReset(email);
    this.isLoading = false;
    this.router.navigate(['/auth']);
  }
}
