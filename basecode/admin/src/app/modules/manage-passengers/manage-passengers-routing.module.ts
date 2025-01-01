import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { ManagePassengersComponent } from './pages/manage-passengers/manage-passengers.component';

const routes: Routes = [
  {
    path:'',
    component:ManagePassengersComponent,
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class ManagePassengersRoutingModule { }
