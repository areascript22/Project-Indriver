import { Roles } from "../../shared/utils/roles";
import { Ratings } from "./ratings.interface";
import { Vehicle } from "./vehicle.interface";

export  interface Driver {
  id: string;
  email: string;
  name: string;
  phone: string;
  profilePicture:string,
  license: string;
  vehicle:Vehicle,
  ratings:Ratings,
  role:Roles
}
