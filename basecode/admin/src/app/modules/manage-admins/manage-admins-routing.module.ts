import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { ManageAdminComponent } from './pages/manage-admin/manage-admin.component';

const routes: Routes = [
  {
    path: '**',
    redirectTo: 'manage-admins',
  },
  // {
  //   path:'create-driver',
  //   component:CreateDriverComponent,
  // },
  {
    path: 'manage-admins',
    component: ManageAdminComponent,
  },
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class ManageAdminsRoutingModule {}
