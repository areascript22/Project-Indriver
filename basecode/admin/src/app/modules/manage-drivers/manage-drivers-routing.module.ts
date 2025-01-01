import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { ManageDriversComponent } from './pages/manage-drivers/manage-drivers.component';
import { CreateDriverComponent } from './pages/create-driver/create-driver.component';

const routes: Routes = [
  {
    path:'**',
    redirectTo:'manage-drivers',
  },
  // {
  //   path:'create-driver',
  //   component:CreateDriverComponent,
  // },
  {
    path:'manage-drivers',
    component:ManageDriversComponent,
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class ManageDriversRoutingModule { }
