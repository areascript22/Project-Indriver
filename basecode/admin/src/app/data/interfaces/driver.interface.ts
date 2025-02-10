import { Roles } from '../../shared/utils/roles';
import { Ratings } from './ratings.interface';
import { Vehicle } from './vehicle.interface';

export interface GUser {
  id?: string;
  email?: string;
  name: string;
  lastName?: string;
  phone: string;
  profilePicture: string;
  ratings: Ratings;
  role: String[];
  vehicle?: Vehicle;
  access: String; //Granted, Denied
}
