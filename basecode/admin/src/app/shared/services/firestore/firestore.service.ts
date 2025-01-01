import { Injectable } from '@angular/core';
import { AngularFirestore } from '@angular/fire/compat/firestore';
import { Driver } from '../../../data/interfaces/driver.interface';
import { MatSnackBar } from '@angular/material/snack-bar';
import { map, Observable } from 'rxjs';
import { collection } from '@angular/fire/firestore';

@Injectable({
  providedIn: 'root',
})
export class FirestoreService {
  constructor(
    private firestore: AngularFirestore,
    private matSnackBar: MatSnackBar
  ) {}

  //Check if the phone number already exists
  async checkPhoneNumber(phone: string): Promise<any> {
    try {
      const phoneQuerySnapshot = await this.firestore
        .collection('drivers')
        .ref.where('phone', '==', phone)
        .get();
      if (!phoneQuerySnapshot.empty) {
        this.matSnackBar.open(
          'El número de celular ya ha sido registrado',
          'Cerrar',
          { duration: 4000 }
        );
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return null;
    }
  }

  //Save driver's data in Firestore
  async saveDriverData(driver: Driver): Promise<void> {
    try {
      // Save user data
      await this.firestore.collection('drivers').doc(driver.id).set({
        email: driver.email,
        name: driver.name,
        profilePicture: driver.profilePicture,
        phone: driver.phone,
        vehicle: driver.vehicle,
        license: driver.license,
        ratings: driver.ratings,
        role: driver.role,
      });
      this.matSnackBar.open('Conductor creado Correctamente', 'Cerrar', {
        duration: 4000,
      });
    } catch (error: any) {
      this.matSnackBar.open(
        'No se pudo guardar los datos del conductor',
        'Cerrar',
        { duration: 4000 }
      );
    }
  }

  //Update data 
  async updateDriverData(driver: Driver): Promise<void> {
    try {
      // Validate driver ID
      if (!driver.id) {
        this.matSnackBar.open('El ID del conductor es obligatorio', 'Cerrar', {
          duration: 4000,
        });
        return;
      }
  
      // Update driver data
      await this.firestore.collection('drivers').doc(driver.id).update({
        email: driver.email,
        name: driver.name,
        profilePicture: driver.profilePicture,
        phone: driver.phone,
        vehicle: driver.vehicle,
        license: driver.license,
        ratings: driver.ratings,
        role: driver.role,
      });
  
      this.matSnackBar.open('Datos del conductor actualizados correctamente', 'Cerrar', {
        duration: 4000,
      });
    } catch (error: any) {
      console.error('Error updating driver data:', error);
      this.matSnackBar.open(
        'No se pudo actualizar los datos del conductor. Inténtalo de nuevo.',
        'Cerrar',
        { duration: 4000 }
      );
    }
  }
  

  //get Driver's data and observe changes
  getDrivers(collectionName: string): Observable<Driver[]> {
    return this.firestore
      .collection(collectionName)
      .snapshotChanges()
      .pipe(
        map((actions) =>
          actions.map((a) => {
            const data = a.payload.doc.data() as any;
            const id = a.payload.doc.id;
            return { id, ...data } as Driver;
          })
        )
      );
  }

  //Remove driver by id
  async removeUserById(collectionName:string, id:string):Promise<void> {
    try {
      await this.firestore.collection(collectionName).doc(id).delete();
      this.matSnackBar.open(
        'Conductor removido',
        'Cerrar',
        { duration: 4000 }
      );
    } catch (error:any) {
      this.matSnackBar.open(
        'No se pudo borrar el Conductor.',
        'Cerrar',
        { duration: 4000 }
      );
    }

    
    
  

  }
}
