import { Injectable } from '@angular/core';
import { AngularFirestore } from '@angular/fire/compat/firestore';
import { GUser } from '../../../data/interfaces/driver.interface';
import { MatSnackBar } from '@angular/material/snack-bar';
import { firstValueFrom, map, Observable } from 'rxjs';
import { collection } from '@angular/fire/firestore';
import { HttpClient } from '@angular/common/http';
import { user } from '@angular/fire/auth';
import { access } from 'fs';
import { deleteObject, ref, Storage } from '@angular/fire/storage';

@Injectable({
  providedIn: 'root',
})
export class FirestoreService {
  private baseUrl = 'https://deleteuser-4wrgni2wda-uc.a.run.app'; //To delete authenticated user

  constructor(
    private firestore: AngularFirestore,
    private storage: Storage,
    private matSnackBar: MatSnackBar,
    private http: HttpClient
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
  async saveDriverData(driver: GUser): Promise<void> {
    try {
      // Save user data
      await this.firestore
        .collection('g_user')
        .doc(driver.id)
        .set({
          email: driver.email,
          name: driver.name,
          lastName: driver.lastName ?? '',
          profilePicture: driver.profilePicture,
          phone: driver.phone,
          vehicle: driver.vehicle,
          ratings: driver.ratings,
          role: driver.role,
          access: driver.access,
        });
      this.matSnackBar.open('Usuario creado Correctamente', 'Cerrar', {
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
  async updateDriverData(driver: GUser): Promise<void> {
    try {
      // Validate driver ID
      if (!driver.id) {
        this.matSnackBar.open('El ID del conductor es obligatorio', 'Cerrar', {
          duration: 4000,
        });
        return;
      }

      // Update driver data
      await this.firestore
        .collection('g_user')
        .doc(driver.id)
        .update({
          email: driver.email,
          name: driver.name,
          lastName: driver.lastName ?? '',
          profilePicture: driver.profilePicture,
          phone: driver.phone,
          vehicle: driver.vehicle,
          ratings: driver.ratings,
          role: driver.role,
          access: driver.access,
        });

      this.matSnackBar.open('Datos actualizados correctamente', 'Cerrar', {
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
  getDrivers(collectionName: string): Observable<GUser[]> {
    return this.firestore
      .collection(collectionName)
      .snapshotChanges()
      .pipe(
        map((actions) =>
          actions.map((a) => {
            const data = a.payload.doc.data() as any;
            const id = a.payload.doc.id;
            return { id, ...data } as GUser;
          })
        )
      );
  }

  //Remove driver by id
  async removeUserById(collectionName: string, id: string): Promise<void> {
    try {
      await this.firestore.collection(collectionName).doc(id).delete();
      this.matSnackBar.open('Conductor removido', 'Cerrar', { duration: 4000 });
    } catch (error: any) {
      this.matSnackBar.open('No se pudo borrar el Conductor.', 'Cerrar', {
        duration: 4000,
      });
    }
  }

  //delete authenticated user (UID)
  deleteAuthenticatedUser(userId: string): Promise<any> {
    console.log('Trying to remove: ', userId);
    return firstValueFrom(
      this.http.post(this.baseUrl, {
        userId: userId,
      })
    );
  }

  //delete image
  deleteImage(imagePath: string): Promise<void> {
    return new Promise((resolve, reject) => {
      const imageRef = ref(this.storage, imagePath);
      deleteObject(imageRef)
        .then(() => {
          console.log(`Image deleted: ${imagePath}`);
          resolve();
        })
        .catch((error) => {
          console.error('Error deleting image:', error);
          reject(error);
        });
    });
  }
}
