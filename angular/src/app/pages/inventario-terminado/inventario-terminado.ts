
import { Component, DestroyRef, inject } from '@angular/core';
import { interval, merge } from 'rxjs';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-inventario-terminado',
  standalone: false,
  templateUrl: './inventario-terminado.html',
  styleUrl: './inventario-terminado.css'
})
export class InventarioTerminado {

  private destroyRef = inject(DestroyRef);

  products: any[] = [];
  selected: any = null;
  message = '';

  form: any = {
    existencia: 0,
    minimo: 0,
    observaciones: 'Ajuste manual'
  };

  constructor(private api: ApiService) {
    merge(interval(5000), this.api.dataChanged)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(() => this.load());

    this.load();
  }

  load() {
    this.api.products().subscribe({
      next: r => {
        this.products = Array.isArray(r?.productos) ? r.productos : [];
      },
      error: e => {
        this.message = e.error?.mensaje || 'No fue posible cargar el inventario.';
      }
    });
  }

  editar(p: any) {
    this.selected = p;
    this.form = {
      existencia: p.existencia || 0,
      minimo: p.minimo || 0,
      observaciones: 'Ajuste manual desde inventario'
    };
  }

  guardar() {
    this.api.put('inventario-productos', this.selected.id_producto, this.form)
      .subscribe({
        next: r => {
          this.message = r.mensaje;
          this.selected = null;
          this.load();
        },
        error: e => {
          this.message = e.error?.mensaje || 'No fue posible actualizar existencias.';
        }
      });
  }

  retirar(p: any) {
    if (!confirm('¿Retirar todas las existencias de ' + p.nombre +
      '? Se conservará el movimiento en el historial.')) return;

    this.api.delete('inventario-productos', p.id_producto)
      .subscribe({
        next: r => {
          this.message = r.mensaje;
          this.load();
        },
        error: e => {
          this.message = e.error?.mensaje || 'No se pudo retirar el inventario.';
        }
      });
  }

  // IMAGEN DE CADA GALLETA
  imagenProducto(p: any): string {
    if (p.imagen) return p.imagen;

    const nombre = (p.nombre || '').toLowerCase();

    if (nombre.includes('choco')) return '/assets/bubblecookies/cookies/bubble-choco.png';
    if (nombre.includes('fresa')) return '/assets/bubblecookies/cookies/double-fresa.png';
    if (nombre.includes('red velvet')) return '/assets/bubblecookies/cookies/red-velvet.png';
    if (nombre.includes('butter')) return '/assets/bubblecookies/cookies/butter-cookies.png';
    if (nombre.includes('lemon')) return '/assets/bubblecookies/cookies/lemon-glass.png';

    return '/assets/bubblecookies/cookies/bubble-choco.png';
  }

  imagenError(event: Event) {
    const img = event.target as HTMLImageElement;
    img.onerror = null;
    img.src = '/assets/bubblecookies/cookies/bubble-choco.png';
  }
}
