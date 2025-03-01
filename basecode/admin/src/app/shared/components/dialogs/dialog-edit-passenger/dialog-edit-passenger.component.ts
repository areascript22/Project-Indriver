import { Component, Inject } from '@angular/core';
import {
  AbstractControl,
  FormBuilder,
  FormGroup,
  Validators,
} from '@angular/forms';
import {
  MAT_DIALOG_DATA,
  MatDialog,
  MatDialogRef,
} from '@angular/material/dialog';
import { FirestoreService } from '../../../services/firestore/firestore.service';
import { GUser } from '../../../../data/interfaces/driver.interface';
import { Roles } from '../../../utils/roles';
import { Vehicle } from '../../../../data/interfaces/vehicle.interface';
import {
  deleteObject,
  getDownloadURL,
  ref,
  Storage,
  uploadBytesResumable,
} from '@angular/fire/storage';
import { BasicDialog } from '../../../../data/interfaces/basic.dialog';
import { DialogBodyComponent } from '../dialog-body/dialog-body.component';

@Component({
  selector: 'app-dialog-edit-passenger',
  templateUrl: './dialog-edit-passenger.component.html',
  styleUrl: './dialog-edit-passenger.component.css',
})
export class DialogEditPassengerComponent {
  dataUser: any;

  driverForm!: FormGroup;
  selectedFile: File | null = null;
  submitted = false;
  loading: Boolean = false; //True: Creating driver
  selectedImage: string | ArrayBuffer | null = null;
  imageChanged: boolean = false; // Track if the image has changed

  constructor(
    private dialog: MatDialog,
    private formBuilder: FormBuilder,
    private firestoreService: FirestoreService,
    private storage: Storage,
    @Inject(MAT_DIALOG_DATA) public data: GUser,
    public dialogRef: MatDialogRef<DialogEditPassengerComponent>
  ) {
    //Init forms
    this.driverForm = this.formBuilder.group({
      profileImage: [data.profilePicture, Validators.required],
      email: [data.email, [Validators.email]],
      name: [data.name, Validators.required],
      lastname: [data.lastName],
      phone: [
        data.phone,
        [Validators.required, Validators.pattern('^[0-9]{10}$')],
      ], // Validates 10 digit phone number
      // vehicleModel: [data.vehicle!.model, Validators.required],
      // taxiCode: [data.vehicle!.taxiCode, [Validators.required]],
      // carRegistrationNumber: [
      //   data.vehicle!.carRegistrationNumber,
      //   [Validators.required],
      // ],
      // license: [data.vehicle!.license, [Validators.required]],
      accessStatus: [data.access, [Validators.required]],
    });
  }

  ngOnInit(): void {
    console.log(this.data);
  }

  // Custom file validator to ensure a file is selected
  fileValidator(control: AbstractControl): { [key: string]: any } | null {
    const file = control.value;
    return file ? null : { required: true }; // Return error if no file is selected
  }

  triggerFileInput(): void {
    const fileInput: HTMLElement | null =
      document.querySelector('#profileImage');
    fileInput?.click();
  }

  onFileSelected(event: Event): void {
    const fileInput = event.target as HTMLInputElement;
    if (fileInput.files && fileInput.files[0]) {
      const file = fileInput.files[0];
      this.selectedFile = file;
      this.imageChanged = true; // Mark image as changed

      // Display the selected image
      const reader = new FileReader();
      reader.onload = (e: ProgressEvent<FileReader>) => {
        this.selectedImage = e.target!.result; // Save the preview URL
      };
      reader.readAsDataURL(file);

      // Update form control with file
      this.driverForm.patchValue({ profileImage: file });
      this.driverForm.get('profileImage')?.markAsTouched();
    }
  }

  // Check if the form or image has changed
  canSaveChanges(): boolean {
    return !this.driverForm.pristine || this.imageChanged;
  }

  //Mat action Buttons
  async saveData() {
    this.loading = true;

    //get filed from driverForm

    const {
      email,
      name,
      lastname,
      phone,
      // license,
      // taxiCode,
      // vehicleModel,
      // carRegistrationNumber,
      accessStatus,
    } = this.driverForm.value;
    //Define Vahicle fields
    // const vehicle: Vehicle = {
    //   license: license,
    //   taxiCode: taxiCode,
    //   model: vehicleModel,
    //   carRegistrationNumber: carRegistrationNumber,
    // };

    //Upload image
    let downloadUrl = '';
    if (this.imageChanged) {
      const filePath = `users/profile_image/${this.data.id}`;
      const storageRef = ref(this.storage, filePath);
      //delete previos image
      try {
        await deleteObject(storageRef);
        console.log('Existing image deleted successfully');
      } catch (error: any) {
        console.log('No se pudo eliminar la imagen previo:  ', error);
      }

      //Upload profile image

      const uploadTask = await uploadBytesResumable(
        storageRef,
        this.selectedFile!
      );
      downloadUrl = await getDownloadURL(uploadTask.ref);
    }

    //Save driver data in Firestore
    const driver: GUser = {
      id: this.data.id,
      email,
      name,
      lastName: lastname ?? '',
      phone,
      profilePicture: this.imageChanged
        ? downloadUrl
        : this.data.profilePicture,
      vehicle: this.data.vehicle,
      ratings: this.data.ratings,
      role: this.data.role,
      access: accessStatus,
    };
    await this.firestoreService.updateDriverData(driver);

    this.loading = false;
    this.dialogRef.close();
  }

  //Close Editing Dialog
  closeEditingData(): void {
    const dialogContent: BasicDialog = {
      title: 'Confirmar acción',
      content: '¿Cerrar sin guardar?',
      cancelText: 'No',
      confirmText: 'Sí',
    };
    if (this.canSaveChanges() && this.driverForm.valid) {
      const dialogRefConfirm = this.dialog.open(DialogBodyComponent, {
        width: '250px',
        data: dialogContent,
      });

      dialogRefConfirm.afterClosed().subscribe((result: boolean) => {
        if (result) {
          //Close without saving
          this.dialogRef.close();
        }
      });
    } else {
      this.dialogRef.close();
    }
  }
}
