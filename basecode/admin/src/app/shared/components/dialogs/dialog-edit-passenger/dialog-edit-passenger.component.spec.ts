import { ComponentFixture, TestBed } from '@angular/core/testing';

import { DialogEditPassengerComponent } from './dialog-edit-passenger.component';

describe('DialogEditPassengerComponent', () => {
  let component: DialogEditPassengerComponent;
  let fixture: ComponentFixture<DialogEditPassengerComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [DialogEditPassengerComponent]
    })
    .compileComponents();
    
    fixture = TestBed.createComponent(DialogEditPassengerComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
