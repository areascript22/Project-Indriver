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



@NgModule({
  declarations: [
    CustomSidenavComponent,
    DialogBodyComponent,
    DialogEditComponent
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
  ],
  exports:[
    CustomSidenavComponent,
  ]
})
export class SharedModule { }
