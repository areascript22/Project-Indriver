import { Component, computed, Input, OnInit, signal } from '@angular/core';
import { GUser } from '../../../data/interfaces/driver.interface';
import { GUserService } from '../../services/guser/g-user.service';
import { Roles } from '../../utils/roles';

@Component({
  selector: 'app-custom-sidenav',
  templateUrl: './custom-sidenav.component.html',
  styleUrl: './custom-sidenav.component.css',
})
export class CustomSidenavComponent implements OnInit {
  sideNavCollapsed = signal(false);
  @Input() set collapsed(val: boolean) {
    this.sideNavCollapsed.set(val);
  }

  guser: GUser | null = null;

  profilePicSize = computed(() => (this.sideNavCollapsed() ? '32' : '100'));

  //contructor
  constructor(private GUserService: GUserService) {}
  //oninit
  ngOnInit(): void {
    this.GUserService.user$.subscribe((userData: GUser | null) => {
      this.guser = userData;
    });
    this.updatedMenuItems();
  }

  menuItems = signal<MenuItem[]>([
    {
      icon: 'dashboard',
      label: 'Conductores',
      route: 'manage-drivers',
    },
    {
      icon: 'dashboard',
      label: 'Pasajeros',
      route: 'manage-passengers',
    },
  ]);

  updatedMenuItems() {
    if (this.guser && this.guser.role.includes(Roles.superUser)) {
      this.menuItems = signal<MenuItem[]>([
        ...this.menuItems(),
        {
          icon: 'dashboard',
          label: 'Administradores',
          route: 'manage-admins',
        },
      ]);
    }
  }

  //get role
  getUserRole(): string {
    let role: String[] | undefined = this.guser?.role;
    if (role && role.includes(Roles.superUser)) {
      return 'Super usuario';
    }
    if (role && role.includes(Roles.admin)) {
      return 'Administrador';
    }
    return 'Sin rol';
  }

  onImageError(event: any): void {
    // Set a fallback image in case of error loading the profile image
    event.target.src = '/assets/img/car-engine.png';
  }
}

export type MenuItem = {
  icon: string;
  label: string;
  route?: string;
};
