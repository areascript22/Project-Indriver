import { CanActivateFn } from '@angular/router';
import { inject } from '@angular/core';
import { AngularFireAuth } from '@angular/fire/compat/auth';
import { Router } from '@angular/router';
import { map, Observable, switchMap } from 'rxjs';
import { AngularFirestore } from '@angular/fire/compat/firestore';
import { GUser } from '../../data/interfaces/driver.interface';
import { GUserService } from '../../shared/services/guser/g-user.service';
// Import the GUser type (adjust path as needed)

export const authGuard: CanActivateFn = (route, state) => {
  const afAuth = inject(AngularFireAuth);
  const firestore = inject(AngularFirestore);
  const router = inject(Router);
  const gUserService = inject(GUserService);

  return afAuth.authState.pipe(
    switchMap((user) => {
      if (user) {
        // Fetch the user's Firestore document, explicitly typing the return value
        return firestore
          .collection('g_user')
          .doc(user.uid)
          .valueChanges() as Observable<GUser | null>;
      } else {
        // If no user is authenticated, redirect to login and return false
        router.navigate(['/auth/login']);
        return [null]; // No user found, return false
      }
    }),
    map((userData: GUser | null) => {
      if (userData && userData.role) {
        gUserService.setUser(userData);

        // Check if the user has 'admin' or 'superUser' role
        if (
          userData.role.includes('admin') ||
          userData.role.includes('superUser')
        ) {
          return true; // Grant access
        } else {
          // Redirect to a "denied access" page or home if unauthorized
          router.navigate(['/']);
          return false; // Deny access
        }
      } else {
        // No roles or data found, deny access
        router.navigate(['/']);
        return false; // Deny access
      }
    })
  );
};
