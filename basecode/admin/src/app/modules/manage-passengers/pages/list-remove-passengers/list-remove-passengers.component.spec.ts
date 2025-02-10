import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ListRemovePassengersComponent } from './list-remove-passengers.component';

describe('ListRemovePassengersComponent', () => {
  let component: ListRemovePassengersComponent;
  let fixture: ComponentFixture<ListRemovePassengersComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ListRemovePassengersComponent]
    })
    .compileComponents();
    
    fixture = TestBed.createComponent(ListRemovePassengersComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
