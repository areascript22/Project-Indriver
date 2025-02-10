import { Component, OnInit } from '@angular/core';
import { FirestoreService } from '../../../../shared/services/firestore/firestore.service';
import { MatDialog } from '@angular/material/dialog';
import { GUser } from '../../../../data/interfaces/driver.interface';
import { DialogBodyComponent } from '../../../../shared/components/dialogs/dialog-body/dialog-body.component';
import { BasicDialog } from '../../../../data/interfaces/basic.dialog';
import { DialogEditComponent } from '../../../../shared/components/dialogs/dialog-edit/dialog-edit.component';
import { Access } from '../../../../shared/utils/access';
import { DialogEditAdminComponent } from '../../../../shared/components/dialogs/dialog-edit-admin/dialog-edit-admin.component';
import { DialogEditPassengerComponent } from '../../../../shared/components/dialogs/dialog-edit-passenger/dialog-edit-passenger.component';

@Component({
  selector: 'app-list-remove-passengers',
  templateUrl: './list-remove-passengers.component.html',
  styleUrl: './list-remove-passengers.component.css',
})
export class ListRemovePassengersComponent implements OnInit {
  items: any[] = [];

  constructor(
    private firestoreService: FirestoreService,
    private dialog: MatDialog
  ) {}

  ngOnInit(): void {
    this.firestoreService.getDrivers('g_user').subscribe((data) => {
      this.items = data.filter((val) => val.role.includes('passenger'));
      console.log('Filtered passenger:', this.items);
    });
    console.log('Users retrieved', this.items);
  }

  //get access
  getAccess(item: GUser): String {
    let value = '';
    switch (item.access) {
      case Access.granted:
        value = 'Accesso permitido';
        break;
      case Access.denied:
        value = 'Acceso denegado';
        break;
      default:
        value = 'Por defecto';
        break;
    }

    return value;
  }

  //Open Remove confirmation Dialog
  openDialog(
    enterAnimationDuration: string,
    exitAnimationDuration: string,
    driver: GUser
  ): void {
    const dialogContent: BasicDialog = {
      title: 'Confirmar acción',
      content: '¿Desea eliminar a ' + driver.name + ' ?',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    };
    const dialogRef = this.dialog.open(DialogBodyComponent, {
      width: '250px',
      enterAnimationDuration,
      exitAnimationDuration,
      data: dialogContent,
    });

    dialogRef.afterClosed().subscribe((result) => {
      if (result) {
        console.log('Confirmed deletion', result);
        this.deleteItem(driver.id!); // Call your delete function
      } else {
        console.log('Deletion canceled');
      }
    });
  }
  // Delete Item
  async deleteItem(id: string): Promise<void> {
    try {
      await this.firestoreService.deleteAuthenticatedUser(id);
      await this.firestoreService.removeUserById('g_user', id);
    } catch (error) {
      console.error('Error deleting user:', error);
    }
  }

  //Open Edit driver Dialog
  openEditDriverDialog(
    driver: GUser,
    enterAnimationDuration: string,
    exitAnimationDuration: string
  ): void {
    const dialogRef = this.dialog.open(DialogEditPassengerComponent, {
      width: '500px',
      enterAnimationDuration,
      exitAnimationDuration,
      data: driver,
      disableClose: true,
    });

    dialogRef.afterClosed().subscribe((result) => {
      if (result) {
        console.log('Editing saved', result);
      } else {
        console.log('Driver data editing canceled');
      }
    });
  }
}
