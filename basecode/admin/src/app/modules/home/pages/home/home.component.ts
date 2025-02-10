import { Component, computed, OnInit, signal } from '@angular/core';
import { AuthService } from '../../../auth/services/auth.service';
import { Router } from '@angular/router';
import { GUser } from '../../../../data/interfaces/driver.interface';
import { GUserService } from '../../../../shared/services/guser/g-user.service';

@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrl: './home.component.css',
})
export class HomeComponent implements OnInit {
  showFiller = false;
  collapsed = signal(false);
  sideNavWidth = computed(() => (this.collapsed() ? '65px' : '250px'));
  gUser: GUser | null = null;

  constructor(
    private authService: AuthService,
    private router: Router,
    private gUserService: GUserService
  ) {}

  ngOnInit(): void {
    this.gUser = this.gUserService.getUser();
  }

  toggleSidenav(): void {
    const sidenav = document.querySelector('mat-sidenav') as HTMLElement;
    if (sidenav) {
      sidenav.toggleAttribute('opened');
    }
  }

  viewProfile() {
    console.log('View Profile Clicked');
  }

  settings() {
    console.log('Settings Clicked');
  }

  //Log out
  async signOut(): Promise<any> {
    await this.authService.signOut();
    this.router.navigate(['/auth']);
  }
}
