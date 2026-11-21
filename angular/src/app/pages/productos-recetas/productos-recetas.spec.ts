import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ProductosRecetas } from './productos-recetas';

describe('ProductosRecetas', () => {
  let component: ProductosRecetas;
  let fixture: ComponentFixture<ProductosRecetas>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ProductosRecetas],
    }).compileComponents();

    fixture = TestBed.createComponent(ProductosRecetas);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
