import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';

import { AuthRoutingModule } from './auth-routing.module';

import { LoginComponent } from './pages/login/login.component';
import { EmailVerificationComponent } from './pages/email-verification/email-verification.component';
import { SignUpComponent } from './pages/sign-up/sign-up.component';
import { PasswordRecoveryComponent } from './pages/password-recovery/password-recovery.component';
import { MatSnackBarModule } from '@angular/material/snack-bar';
import { MatButtonModule } from '@angular/material/button';
import {MatProgressSpinnerModule} from '@angular/material/progress-spinner';
import { ReactiveFormsModule } from '@angular/forms';

@NgModule({
  declarations: [
    LoginComponent,
    EmailVerificationComponent,
    SignUpComponent,
    PasswordRecoveryComponent,
  ],
  imports: [
    CommonModule,
    AuthRoutingModule,
    MatSnackBarModule,
    MatButtonModule,
    MatProgressSpinnerModule,
    ReactiveFormsModule,
  ],
})
export class AuthModule {}
