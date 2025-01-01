import { Injectable } from '@angular/core';
import { FirebaseCodeErrors } from '../../utils/firebase.code.errors';

@Injectable({
  providedIn: 'root',
})
export class FirebaseErrorCodeService {
  constructor() {}

  //Handle Firebase Errors
  firebaseError(code: string) {
    switch (code) {
      case FirebaseCodeErrors.emailAlreadyInUse:
        return 'El correo ya ha sido registrado';
      case FirebaseCodeErrors.weakPassword:
        return 'Contraseña devil. Ingresa minimo 6 caracteres';
      case FirebaseCodeErrors.invalidEmail:
        return 'Ingresa un correo válido';
      case FirebaseCodeErrors.invalidCredentials:
        return 'Credenciales invalidas';
      default:
        return 'Error desconocido';
    }
  }
}
