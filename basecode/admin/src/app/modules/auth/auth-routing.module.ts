import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { LoginComponent } from './pages/login/login.component';
import { SignUpComponent } from './pages/sign-up/sign-up.component';
import { EmailVerificationComponent } from './pages/email-verification/email-verification.component';
import { PasswordRecoveryComponent } from './pages/password-recovery/password-recovery.component';

const routes: Routes = [
  //Login
  {
    path:'login',
    component:LoginComponent
  },
  //Sign up
  {
    path:'sign-up',
    component:SignUpComponent,
  },
  //Email verification
  {
    path:'email-verification',
    component:EmailVerificationComponent,
  },
  //Password recovery
  {
    path:'password-recovery',
    component:PasswordRecoveryComponent,
  },
  //Default route
  {
    path:'**',
    redirectTo:'/auth/login',
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class AuthRoutingModule { }
