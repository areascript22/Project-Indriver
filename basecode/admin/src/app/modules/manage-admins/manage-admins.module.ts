import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';

import { ManageAdminsRoutingModule } from './manage-admins-routing.module';

import { ListRemoveAdminsComponent } from './pages/list-remove-admins/list-remove-admins.component';
import { ManageAdminComponent } from './pages/manage-admin/manage-admin.component';
import { CreateAdminComponent } from './pages/create-admin/create-admin.component';


import { ReactiveFormsModule } from '@angular/forms';
import { MatTabsModule } from '@angular/material/tabs';
import { MatSnackBarModule } from '@angular/material/snack-bar';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatSelectModule } from '@angular/material/select';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';



@NgModule({
  declarations: [
    CreateAdminComponent,
    ListRemoveAdminsComponent,
    ManageAdminComponent,
  ],
  imports: [CommonModule, ManageAdminsRoutingModule,ReactiveFormsModule,
      MatTabsModule,
      MatSnackBarModule,
      MatProgressSpinnerModule,
      MatCardModule,
      MatButtonModule,
      MatDialogModule,
      MatSelectModule,],
})
export class ManageAdminsModule {}
