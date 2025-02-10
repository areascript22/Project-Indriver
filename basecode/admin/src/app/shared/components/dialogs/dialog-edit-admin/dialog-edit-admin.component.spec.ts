import { ComponentFixture, TestBed } from '@angular/core/testing';

import { DialogEditAdminComponent } from './dialog-edit-admin.component';

describe('DialogEditAdminComponent', () => {
  let component: DialogEditAdminComponent;
  let fixture: ComponentFixture<DialogEditAdminComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [DialogEditAdminComponent]
    })
    .compileComponents();
    
    fixture = TestBed.createComponent(DialogEditAdminComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
