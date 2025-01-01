import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ListRemoveDriversComponent } from './list-remove-drivers.component';

describe('ListRemoveDriversComponent', () => {
  let component: ListRemoveDriversComponent;
  let fixture: ComponentFixture<ListRemoveDriversComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ListRemoveDriversComponent]
    })
    .compileComponents();
    
    fixture = TestBed.createComponent(ListRemoveDriversComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
