import { TestBed } from '@angular/core/testing';

import { GUserService } from './g-user.service';

describe('GUserService', () => {
  let service: GUserService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(GUserService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
