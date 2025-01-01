import { TestBed } from '@angular/core/testing';

import { FirebaseErrorCodeService } from './firebase-error-code.service';

describe('FirebaseErrorCodeService', () => {
  let service: FirebaseErrorCodeService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(FirebaseErrorCodeService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
