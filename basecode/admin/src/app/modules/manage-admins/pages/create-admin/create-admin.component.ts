import { Component } from '@angular/core';
import {
  AbstractControl,
  FormBuilder,
  FormGroup,
  Validators,
} from '@angular/forms';
import { AuthService } from '../../../auth/services/auth.service';
import { FirestoreService } from '../../../../shared/services/firestore/firestore.service';
import { MatSnackBar } from '@angular/material/snack-bar';
import { GUser } from '../../../../data/interfaces/driver.interface';
import { Roles } from '../../../../shared/utils/roles';
import { Access } from '../../../../shared/utils/access';
import { Ratings } from '../../../../data/interfaces/ratings.interface';
import { Vehicle } from '../../../../data/interfaces/vehicle.interface';
import {
  getDownloadURL,
  ref,
  Storage,
  uploadBytesResumable,
} from '@angular/fire/storage';

@Component({
  selector: 'app-create-admin',
  templateUrl: './create-admin.component.html',
  styleUrl: './create-admin.component.css',
})
export class CreateAdminComponent {
  dataUser: any;

  adminForm!: FormGroup;
  selectedFile: File | null = null;
  submitted = false;
  loading: Boolean = false; //True: Creating driver

  constructor(
    private formBuilder: FormBuilder,
    private authService: AuthService,
    private firestoreService: FirestoreService,
    private storage: Storage,
    private matSnackBar: MatSnackBar
  ) {
    //Init forms
    this.adminForm = this.formBuilder.group({
      profileImage: ['', this.fileValidator],
      email: ['', [Validators.required, Validators.email]],
      name: ['', Validators.required],
      lastName: ['', Validators.required],
      phone: ['', [Validators.required, Validators.pattern('^[0-9]{10}$')]], // Validates 10 digit phone number
      // vehicleModel: ['', Validators.required],
      // taxiCode: ['', [Validators.required]],
      // carRegistrationNumber: ['', [Validators.required]],
      // license: ['', [Validators.required]],
    });
  }

  // Custom file validator to ensure a file is selected
  fileValidator(control: AbstractControl): { [key: string]: any } | null {
    const file = control.value;
    return file ? null : { required: true }; // Return error if no file is selected
  }

  //Submit Form
  async onSubmit() {
    this.loading = true;
    //get data from Form
    const {
      email,
      name,
      lastName,
      phone,
      // vehicleModel,
      // taxiCode,
      // carRegistrationNumber,
      // license,
    } = this.adminForm.value;
    const file = this.selectedFile;
    //Check if there is an selected image
    if (!file) {
      this.loading = false;
      this.matSnackBar.open('Selecciona una imagen', 'Error', {
        duration: 4000,
      });
      return;
    }

    //Check if phone number already exists
    const phoneAlreadyExist = await this.firestoreService.checkPhoneNumber(
      phone
    );
    if (phoneAlreadyExist == null) {
      this.loading = false;
      return;
    }
    if (phoneAlreadyExist) {
      this.loading = false;
      return;
    }
    //Generate temp password of twelve characters
    const tempPassword = this.generateRandomPassword(12);

    //Create Driver account
    const driverCredentials = await this.authService.createDriverAccount(
      email,
      tempPassword
    );
    if (driverCredentials == null) {
      this.loading = false;
      return;
    }

    //Once driver's account created, send password reset email
    await this.authService.sendPasswordReset(email);

    //Once driver's account was created succesfully. Get driver's id
    const driverId = driverCredentials.user?.uid;

    //Upload profile image
    const filePath = `users/profile_image/${driverId}`;
    const storageRef = ref(this.storage, filePath);
    const uploadTask = await uploadBytesResumable(storageRef, file!);
    const downloadUrl = await getDownloadURL(uploadTask.ref);

    //Define Vahicle fields
    const vehicle: Vehicle = {
      license: '',
      taxiCode: '',
      model: '',
      carRegistrationNumber: '',
    };

    //Define Ratings
    const ratings: Ratings = {
      rating: 0,
      ratingCount: 0,
      totalRatingScore: 0,
    };

    //Save driver data in Firestore
    let formatedPhone = phone.replace(/^0/, '');
    const driver: GUser = {
      id: driverId,
      email,
      name,
      lastName: lastName ?? '',
      phone: '+593' + formatedPhone,
      profilePicture: downloadUrl,
      vehicle: vehicle,
      ratings: ratings,
      role: [Roles.admin],
      access: Access.granted,
    };

    await this.firestoreService.saveDriverData(driver);
    this.loading = false;
  }

  //Generate a temp password for driver account creating
  generateRandomPassword(length: number): string {
    const characters =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let password = '';
    for (let i = 0; i < length; i++) {
      password += characters.charAt(
        Math.floor(Math.random() * characters.length)
      );
    }
    return password;
  }
  //Detect when an image file is selected
  onFileSelected(event: any) {
    this.selectedFile = event.target.files[0];
    console.log('A file was selected ');
    console.log(this.selectedFile);
  }
}
