import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ManageDriversComponent } from './manage-drivers.component';

describe('ManageDriversComponent', () => {
  let component: ManageDriversComponent;
  let fixture: ComponentFixture<ManageDriversComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ManageDriversComponent]
    })
    .compileComponents();
    
    fixture = TestBed.createComponent(ManageDriversComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
