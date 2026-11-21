import { ComponentFixture, TestBed } from '@angular/core/testing';
import { AnaliticaMarketing } from './analitica-marketing';

describe('AnaliticaMarketing', () => {
  let component: AnaliticaMarketing;
  let fixture: ComponentFixture<AnaliticaMarketing>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [AnaliticaMarketing],
    }).compileComponents();

    fixture = TestBed.createComponent(AnaliticaMarketing);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
