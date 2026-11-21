import { ComponentFixture, TestBed } from '@angular/core/testing';
import { PedidosVentas } from './pedidos-ventas';

describe('PedidosVentas', () => {
  let component: PedidosVentas;
  let fixture: ComponentFixture<PedidosVentas>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [PedidosVentas],
    }).compileComponents();

    fixture = TestBed.createComponent(PedidosVentas);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
