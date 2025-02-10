import { Injectable } from '@angular/core';
import { AngularFireAuth } from '@angular/fire/compat/auth';
import { MatSnackBar } from '@angular/material/snack-bar';
import { promises } from 'dns';
import { FirebaseErrorCodeService } from '../../../shared/services/FirebaseErrorCode/firebase-error-code.service';

@Injectable({
  providedIn: 'root',
})
export class AuthService {
  constructor(
    private afAuth: AngularFireAuth,
    private snackBar: MatSnackBar,
    private firebaseErrorCode: FirebaseErrorCodeService,

    
  ) {}

  //Sign in with Email and Password
  async signIn(email: string, password: string): Promise<any> {
    
    try {
      const userCredential = await this.afAuth.signInWithEmailAndPassword(
        email,
        password
      );
      return userCredential;
    } catch (error: any) {
      console.log('An error occurred while logging into Firebase', error);
      console.log(error);
      this.snackBar.open(
        this.firebaseErrorCode.firebaseError(error.code),
        'Cerrar',
        { duration: 5000 }
      );
      return null;
    }
  }

  //Create driver account with Email and Password
  async createDriverAccount(email: string, password: string): Promise<any> {
    try {
      const userCredential = await this.afAuth.createUserWithEmailAndPassword(
        email,
        password
      );
      return userCredential;
    } catch (error: any) {
      this.snackBar.open(
        this.firebaseErrorCode.firebaseError(error.code),
        'Cerrar',
        { duration: 5000 }
      );
      return null;
    }
  }

   //For user be able to reset his password
   async sendPasswordReset(email: string): Promise<void> {
    try {
      await this.afAuth.sendPasswordResetEmail(email);
      this.snackBar.open('Se ha enviado un enlace para restablecer la contraseña al conductor.', 'Success');
    } catch (error) {
      this.snackBar.open('No se pudo enviar el enlace de restablecimiento de contraseña.', 'Error');
    }
  }

   //Paswword recovery
   async recover(email:string):Promise<void>{
     try {
      await this.afAuth.sendPasswordResetEmail(email);
      this.snackBar.open('Te hemos enviado un correo para reestablecer tu contraseña','Cerrar');
     } catch (error:any) {
      this.snackBar.open(this.firebaseErrorCode.firebaseError(error.code),'Cerrar');
     }
  }

  //Sign out
  signOut(): Promise<any> {
    return this.afAuth.signOut();
  }
}
