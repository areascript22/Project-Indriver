import { Component, computed, Input, signal } from '@angular/core';

@Component({
  selector: 'app-custom-sidenav',
  templateUrl: './custom-sidenav.component.html',
  styleUrl: './custom-sidenav.component.css',
})
export class CustomSidenavComponent {
  sideNavCollapsed = signal(false);
  @Input() set collapsed(val: boolean) {
    this.sideNavCollapsed.set(val);
  }

  profilePicSize = computed(() => (this.sideNavCollapsed() ? '32' : '100'));

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
}

export type MenuItem = {
  icon: string;
  label: string;
  route?: string;
};
