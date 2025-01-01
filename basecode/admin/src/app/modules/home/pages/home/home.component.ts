import { Component, computed, signal } from '@angular/core';
import { AuthService } from '../../../auth/services/auth.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrl: './home.component.css',
})
export class HomeComponent {
  showFiller = false;
  collapsed = signal(false);
  sideNavWidth = computed(() => (this.collapsed() ? '65px' : '250px'));

  constructor(private authService: AuthService, private router: Router) {}

  toggleSidenav(): void {
    const sidenav = document.querySelector('mat-sidenav') as HTMLElement;
    if (sidenav) {
      sidenav.toggleAttribute('opened');
    }
  }

  //Log out
  async signOut(): Promise<any> {
    await this.authService.signOut();
    this.router.navigate(['/auth']);
  }
}
