import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';

import { ManageDriversRoutingModule } from './manage-drivers-routing.module';
import { ManageDriversComponent } from './pages/manage-drivers/manage-drivers.component';
import { CreateDriverComponent } from './pages/create-driver/create-driver.component';
import { ReactiveFormsModule } from '@angular/forms';
import { MatTabsModule } from '@angular/material/tabs';
import { ListRemoveDriversComponent } from './pages/list-remove-drivers/list-remove-drivers.component';
import { MatSnackBarModule } from '@angular/material/snack-bar';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatSelectModule } from '@angular/material/select';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';

@NgModule({
  declarations: [
    ManageDriversComponent,
    CreateDriverComponent,
    ListRemoveDriversComponent,
  ],
  imports: [
    CommonModule,
    ManageDriversRoutingModule,
    ReactiveFormsModule,
    MatTabsModule,
    MatSnackBarModule,
    MatProgressSpinnerModule,
    MatCardModule,
    MatButtonModule,
    MatDialogModule,
    MatSelectModule,
  ],
})
export class ManageDriversModule {}
