import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable } from 'rxjs';
import { GUser } from '../../../data/interfaces/driver.interface';
// Adjust the path to your GUser model

@Injectable({
  providedIn: 'root',
})
export class GUserService {
  private userSubject: BehaviorSubject<GUser | null> =
    new BehaviorSubject<GUser | null>(null);
  public user$: Observable<GUser | null> = this.userSubject.asObservable();

  constructor() {}

  // Set user data
  setUser(user: GUser): void {
    this.userSubject.next(user);
  }

  // Get current user data
  getUser(): GUser | null {
    return this.userSubject.value;
  }

  // Clear user data (for logout)
  clearUser(): void {
    this.userSubject.next(null);
  }
}
