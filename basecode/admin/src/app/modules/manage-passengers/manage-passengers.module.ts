import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';

import { ManagePassengersRoutingModule } from './manage-passengers-routing.module';
import { ManagePassengersComponent } from './pages/manage-passengers/manage-passengers.component';
import { MatTabsModule } from '@angular/material/tabs';
import { AccessRequestComponent } from './pages/access-request/access-request.component';
import { ListRemovePassengersComponent } from './pages/list-remove-passengers/list-remove-passengers.component';

import { ReactiveFormsModule } from '@angular/forms';

import { MatSnackBarModule } from '@angular/material/snack-bar';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';

@NgModule({
  declarations: [
    ManagePassengersComponent,
    AccessRequestComponent,
    ListRemovePassengersComponent,
  ],
  imports: [
    CommonModule,
    ManagePassengersRoutingModule,
    MatTabsModule,
    ReactiveFormsModule,
    MatSnackBarModule,
    MatProgressSpinnerModule,
    MatCardModule,
    MatButtonModule,
    MatDialogModule,
  ],
})
export class ManagePassengersModule {}
