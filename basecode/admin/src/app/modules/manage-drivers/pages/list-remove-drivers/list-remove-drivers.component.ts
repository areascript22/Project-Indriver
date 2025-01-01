import { Component, OnInit } from '@angular/core';
import { FirestoreService } from '../../../../shared/services/firestore/firestore.service';
import { MatDialog } from '@angular/material/dialog';
import { DialogBodyComponent } from '../../../../shared/components/dialogs/dialog-body/dialog-body.component';
import { Driver } from '../../../../data/interfaces/driver.interface';
import { CreateDriverComponent } from '../create-driver/create-driver.component';
import { DialogEditComponent } from '../../../../shared/components/dialogs/dialog-edit/dialog-edit.component';
import { BasicDialog } from '../../../../data/interfaces/basic.dialog';
import { title } from 'process';

@Component({
  selector: 'app-list-remove-drivers',
  templateUrl: './list-remove-drivers.component.html',
  styleUrl: './list-remove-drivers.component.css'
})
export class ListRemoveDriversComponent implements OnInit {
  items:any[] = [];

  constructor(private firestoreService:FirestoreService, private dialog:MatDialog){}


  ngOnInit(): void {
      this.firestoreService.getDrivers('drivers').subscribe(
        data=> {
          this.items = data;
          console.log('updated items: ',this.items);
          console.log('updated items: ',this.items[0].data.role);
        }
      );
  }

   // Delete Item
   async deleteItem(id: string): Promise<void> {
    await this.firestoreService.removeUserById('drivers',id);
  }

  //Open Remove confirmation Dialog
  openDialog(enterAnimationDuration: string, exitAnimationDuration: string, driver:Driver): void {
    const dialogContent:BasicDialog={
      title:'Confirmar acción',
      content:'¿Desea eliminar a '+driver.name+" ?",
      cancelText:'Cancelar',
      confirmText:'Confirmar',
    }
    const dialogRef =  this.dialog.open( DialogBodyComponent , {
      width: '250px',
      enterAnimationDuration,
      exitAnimationDuration,
      data:dialogContent,
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        console.log('Confirmed deletion', result);
        this.deleteItem(driver.id); // Call your delete function
      } else {
        console.log('Deletion canceled');
      }
    });

  }

  //Open Edit driver Dialog
  openEditDriverDialog(driver:Driver,enterAnimationDuration: string, exitAnimationDuration: string,):void{
  const dialogRef = this.dialog.open(DialogEditComponent,{
    width:'500px',
    enterAnimationDuration,
    exitAnimationDuration,
    data:driver,
    disableClose:true,
  });

  dialogRef.afterClosed().subscribe(result=>{
    if(result){
        console.log('Editing saved', result);
    }else{
      console.log('Driver data editing canceled');
    }
  });
  }
      

}
