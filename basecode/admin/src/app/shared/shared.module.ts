import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { CustomSidenavComponent } from './components/custom-sidenav/custom-sidenav.component';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatListModule } from '@angular/material/list';
import { MatIconModule } from '@angular/material/icon';
import { RouterModule } from '@angular/router';
import { DialogBodyComponent } from './components/dialogs/dialog-body/dialog-body.component';
import { MatDialogModule } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { DialogEditComponent } from './components/dialogs/dialog-edit/dialog-edit.component';
import { ReactiveFormsModule } from '@angular/forms';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatSelectModule } from '@angular/material/select';
import { MatInputModule } from '@angular/material/input';
import { DialogEditAdminComponent } from './components/dialogs/dialog-edit-admin/dialog-edit-admin.component';
import { DialogEditPassengerComponent } from './components/dialogs/dialog-edit-passenger/dialog-edit-passenger.component';

@NgModule({
  declarations: [
    CustomSidenavComponent,
    DialogBodyComponent,
    DialogEditComponent,
    DialogEditAdminComponent,
    DialogEditPassengerComponent,
  ],
  imports: [
    CommonModule,
    MatListModule,
    MatIconModule,
    RouterModule,
    MatDialogModule,
    MatButtonModule,
    ReactiveFormsModule,
    MatProgressSpinnerModule,
    MatFormFieldModule,
    MatSelectModule,
  ],
  exports: [CustomSidenavComponent],
})
export class SharedModule {}
