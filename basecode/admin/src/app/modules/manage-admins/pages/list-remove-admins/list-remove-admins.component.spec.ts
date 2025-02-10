import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ListRemoveAdminsComponent } from './list-remove-admins.component';

describe('ListRemoveAdminsComponent', () => {
  let component: ListRemoveAdminsComponent;
  let fixture: ComponentFixture<ListRemoveAdminsComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ListRemoveAdminsComponent]
    })
    .compileComponents();
    
    fixture = TestBed.createComponent(ListRemoveAdminsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
