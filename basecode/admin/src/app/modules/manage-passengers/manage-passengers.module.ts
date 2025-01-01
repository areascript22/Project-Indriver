import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';

import { ManagePassengersRoutingModule } from './manage-passengers-routing.module';
import { ManagePassengersComponent } from './pages/manage-passengers/manage-passengers.component';
import {MatTabsModule} from '@angular/material/tabs';
import { AccessRequestComponent } from './pages/access-request/access-request.component';


@NgModule({
  declarations: [
    ManagePassengersComponent,
    AccessRequestComponent
  ],
  imports: [
    CommonModule,
    ManagePassengersRoutingModule,
    MatTabsModule,
  ]
})
export class ManagePassengersModule { }
