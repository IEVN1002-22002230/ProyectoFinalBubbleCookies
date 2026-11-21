
import { Component, DestroyRef, inject } from '@angular/core';
import { interval, merge, finalize, timeout } from 'rxjs';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-produccion',
  standalone: false,
  templateUrl: './produccion.html',
  styleUrl: './produccion.css'
})
export class Produccion {

  private destroyRef = inject(DestroyRef);

  products: any[] = [];
  recipes: any[] = [];
  ingredients: any[] = [];
  history: any[] = [];

  form: any = {
    id_producto: 1,
    cantidad_lotes: 1,
    observaciones: ''
  };

  message = '';
  registrando = false;

  constructor(private api: ApiService) {
    merge(interval(5000), this.api.dataChanged)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(() => this.cargarHistorial());

    this.load();
  }

  // CARGAR DATOS
  load() {
    this.api.products().subscribe({
      next: r => {
        this.products = Array.isArray(r)
          ? r
          : r?.productos || [];

        if (
          this.products.length &&
          !this.products.some(
            p => p.id_producto == this.form.id_producto
          )
        ) {
          this.form.id_producto = this.products[0].id_producto;
        }
      },
      error: e => {
        console.error('Error al cargar productos:', e);
        this.message = 'No fue posible cargar los productos.';
      }
    });

    this.api.get('recetas').subscribe({
      next: r => {
        this.recipes = Array.isArray(r)
          ? r
          : r?.recetas || [];
      },
      error: e => console.error('Error al cargar recetas:', e)
    });

    this.api.get('ingredientes').subscribe({
      next: r => {
        this.ingredients = Array.isArray(r)
          ? r
          : r?.ingredientes || [];
      },
      error: e => console.error('Error al cargar ingredientes:', e)
    });

    this.cargarHistorial();
  }

  // HISTORIAL
  cargarHistorial() {
    this.api.get('producciones').subscribe({
      next: r => {
        this.history = Array.isArray(r)
          ? r
          : r?.producciones || [];
      },
      error: e => {
        console.error('Error al cargar historial:', e);
        this.message = e.error?.mensaje ||
          `No se pudo cargar el historial (HTTP ${e.status || 0}).`;
      }
    });
  }

  // PRODUCTO SELECCIONADO
  get productoSeleccionado() {
    return this.products.find(
      p => p.id_producto == this.form.id_producto
    );
  }

  // RECETA SELECCIONADA
  get recetaSeleccionada() {
    return this.recipes.find(
      r => r.id_producto == this.form.id_producto
    );
  }

  // CALCULAR GALLETAS
  get unidades() {
    const lotes = Number(this.form.cantidad_lotes) || 0;

    const porLote =
      this.recetaSeleccionada?.unidades_por_lote ||
      this.productoSeleccionado?.unidades_por_lote ||
      12;

    return Number(porLote) * lotes;
  }

  // INGREDIENTES NECESARIOS
  get ingredientesNecesarios() {
    const lotes = Number(this.form.cantidad_lotes) || 0;
    const detalles = this.recetaSeleccionada?.ingredientes || [];

    return detalles.map((ing: any) => {
      const ingrediente = this.ingredients.find(
        x => x.id_ingrediente == ing.id_ingrediente
      );

      return {
        nombre: ingrediente?.nombre || 'Ingrediente',
        consumo: Number(ing.cantidad) * lotes,
        unidad: ing.unidad || ingrediente?.unidad || ''
      };
    });
  }

  selectProduct() {
    this.message = '';
  }

  // REGISTRAR PRODUCCION
  producir() {
    if (this.registrando) return;

    const idProducto = Number(this.form.id_producto);
    const lotes = Number(this.form.cantidad_lotes);

    if (!idProducto || !Number.isInteger(lotes) || lotes < 1) {
      this.message =
        'Selecciona un producto y una cantidad válida de lotes.';
      return;
    }

    const datos = {
      id_producto: idProducto,
      cantidad_lotes: lotes,
      observaciones: this.form.observaciones || ''
    };

    this.registrando = true;
    this.message = '';

    this.api.post('producciones', datos)
      .pipe(
        timeout(15000),
        finalize(() => {
          this.registrando = false;
        })
      )
      .subscribe({
        next: r => {
          this.message = r?.mensaje ||
            'Producción registrada correctamente.';

          this.load();
        },
        error: e => {
          console.error('Error al registrar producción:', e);

          if (e.name === 'TimeoutError') {
            this.message =
              'La solicitud tardó demasiado. Revisa el historial antes de volver a intentar.';
          } else {
            this.message = e.error?.mensaje ||
              `No se pudo registrar la producción (HTTP ${e.status || 0}).`;
          }
        }
      });
  }

  // CANCELAR PRODUCCION
  cancelar(x: any) {
    if (!confirm(
      '¿Cancelar el lote y revertir sus movimientos de inventario?'
    )) {
      return;
    }

    this.api.delete('producciones', x.id_produccion).subscribe({
      next: r => {
        this.message = r?.mensaje || 'Lote cancelado.';
        this.load();
      },
      error: e => {
        console.error('Error al cancelar producción:', e);
        this.message = e.error?.mensaje ||
          'No se pudo cancelar el lote.';
      }
    });
  }
}
