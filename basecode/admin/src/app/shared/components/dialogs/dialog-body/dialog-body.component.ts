import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { GUser } from '../../../../data/interfaces/driver.interface';
import { BasicDialog } from '../../../../data/interfaces/basic.dialog';

@Component({
  selector: 'app-dialog-body',
  templateUrl: './dialog-body.component.html',
  styleUrl: './dialog-body.component.css',
})
export class DialogBodyComponent {
  constructor(
    public dialogRef: MatDialogRef<DialogBodyComponent>,
    @Inject(MAT_DIALOG_DATA) public data: BasicDialog
  ) {}

  //ON confirm
  onConfirm(): void {
    console.log('Confiirmation button Pressed', this.data.content);
    this.dialogRef.close(true);
  }
}
