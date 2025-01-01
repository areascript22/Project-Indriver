import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { HomeComponent } from './modules/home/pages/home/home.component';
import { authGuard } from './core/guards/auth.guard';


const routes: Routes = [
  //Authentication
  {
    path:'auth',
    loadChildren:()=>import("./modules/auth/auth.module").then(auth=>auth.AuthModule),
  },
  //Home
  {
    path:'',
    component:HomeComponent,
    loadChildren:()=>import("./modules/home/home.module").then(home=>home.HomeModule),
    canActivate:[authGuard]
    

  }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
