import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

const routes: Routes = [
  {
    path: 'manage-drivers',
    loadChildren: () =>
      import('../manage-drivers/manage-drivers.module').then(
        (mod) => mod.ManageDriversModule
      ),
  },
  {
    path: 'manage-passengers',
    loadChildren: () =>
      import('../manage-passengers/manage-passengers.module').then(
        (mod) => mod.ManagePassengersModule
      ),
  },
  {
    path: 'manage-admins',
    loadChildren: () =>
      import('../manage-admins/manage-admins.module').then(
        (mod) => mod.ManageAdminsModule
      ),
  },
  {
    path: '**',
    redirectTo: 'manage-drivers',
  },
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class HomeRoutingModule {}
