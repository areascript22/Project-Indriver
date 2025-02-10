import { Component, OnInit } from '@angular/core';
import { FirestoreService } from '../../../../shared/services/firestore/firestore.service';
import { MatDialog } from '@angular/material/dialog';
import { DialogBodyComponent } from '../../../../shared/components/dialogs/dialog-body/dialog-body.component';
import { GUser } from '../../../../data/interfaces/driver.interface';
import { CreateDriverComponent } from '../create-driver/create-driver.component';
import { DialogEditComponent } from '../../../../shared/components/dialogs/dialog-edit/dialog-edit.component';
import { BasicDialog } from '../../../../data/interfaces/basic.dialog';
import { title } from 'process';
import { Access } from '../../../../shared/utils/access';

@Component({
  selector: 'app-list-remove-drivers',
  templateUrl: './list-remove-drivers.component.html',
  styleUrl: './list-remove-drivers.component.css',
})
export class ListRemoveDriversComponent implements OnInit {
  items: any[] = [];
  accessOptions = [
    { value: 'allow', label: 'Permitir acceso' },
    { value: 'deny', label: 'Denegar acceso' },
  ];

  constructor(
    private firestoreService: FirestoreService,
    private dialog: MatDialog
  ) {}

  ngOnInit(): void {
    this.firestoreService.getDrivers('g_user').subscribe((data) => {
      this.items = data.filter((val) => val.role.includes('driver'));
      console.log('Filtered Drivers:', this.items);
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

  // Delete Item
  async deleteItem(id: string): Promise<void> {
    //try delete image
    try {
      await this.firestoreService.deleteImage('users/profile_image/' + id);
    } catch (error) {
      console.error('Error trying to delete profile image: ', error);
    }
    //Try to delete authenticated id and Firestore info
    try {
      await this.firestoreService.deleteAuthenticatedUser(id);
      await this.firestoreService.removeUserById('g_user', id);
    } catch (error) {
      console.error('Error deleting user:', error);
    }
  }

  updateAccess(item: GUser) {
    console.log(`Access for ${item.name}: ${item.access}`);
    // Here you can add API calls or further logic to update the access in the database
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

  //Open Edit driver Dialog
  openEditDriverDialog(
    driver: GUser,
    enterAnimationDuration: string,
    exitAnimationDuration: string
  ): void {
    const dialogRef = this.dialog.open(DialogEditComponent, {
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
