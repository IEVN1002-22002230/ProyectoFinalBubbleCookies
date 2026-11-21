import { ComponentFixture, TestBed } from '@angular/core/testing';
import { InventarioTerminado } from './inventario-terminado';

describe('InventarioTerminado', () => {
  let component: InventarioTerminado;
  let fixture: ComponentFixture<InventarioTerminado>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [InventarioTerminado],
    }).compileComponents();

    fixture = TestBed.createComponent(InventarioTerminado);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
