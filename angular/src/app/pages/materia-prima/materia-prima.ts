
import { Component, DestroyRef, inject } from '@angular/core';
import { interval, merge } from 'rxjs';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-materia-prima',
  standalone: false,
  templateUrl: './materia-prima.html',
  styleUrl: './materia-prima.css'
})
export class MateriaPrima {

  private destroyRef = inject(DestroyRef);

  items: any[] = [];
  search = '';
  showForm = false;
  message = '';

  form: any = {
    nombre: '',
    unidad: 'kg',
    stock_minimo: 0
  };

  constructor(private api: ApiService) {
    merge(interval(5000), this.api.dataChanged)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(() => this.load());

    this.load();
  }

  load() {
    this.api.get('ingredientes').subscribe({
      next: r => {
        this.items = Array.isArray(r) ? r : [];
      },
      error: e => {
        this.message = e.error?.mensaje || 'Error al cargar ingredientes.';
      }
    });
  }

  get filtered() {
    return this.items.filter(x =>
      (x.nombre || '')
        .toLowerCase()
        .includes(this.search.toLowerCase())
    );
  }

  get low() {
    return this.items.filter(x => this.isLow(x)).length;
  }

  isLow(x: any) {
    return Number(x.cantidad) < Number(x.stock_minimo);
  }

  nuevo() {
    this.form = {
      nombre: '',
      unidad: 'kg',
      stock_minimo: 0
    };

    this.showForm = true;
  }

  editar(x: any) {
    this.form = { id_ingrediente: x.id_ingrediente, nombre: x.nombre, unidad: x.unidad, stock_minimo: x.stock_minimo };
    this.showForm = true;
  }

  guardar() {
    const payload = { nombre: String(this.form.nombre || '').trim(), unidad: this.form.unidad, stock_minimo: Number(this.form.stock_minimo || 0) };
    if (!payload.nombre || !['kg', 'pza', 'L'].includes(payload.unidad)) {
      this.message = 'Indica un nombre y selecciona una unidad válida (kg, piezas o L).';
      return;
    }
    const req = this.form.id_ingrediente
      ? this.api.put('ingredientes', this.form.id_ingrediente, payload)
      : this.api.post('ingredientes', payload);

    req.subscribe({
      next: r => {
        this.message = r.mensaje || 'Ingrediente guardado.';
        this.showForm = false;
        this.load();
      },
      error: e => {
        this.message = e.error?.mensaje || 'No fue posible guardar el ingrediente.';
      }
    });
  }

  eliminar(x: any) {
    if (!confirm(`¿Eliminar el ingrediente ${x.nombre}? Si tiene recetas o movimientos históricos, se desactivará para proteger esos registros.`)) return;

    this.api.delete('ingredientes', x.id_ingrediente)
      .subscribe({
        next: r => {
          this.message = r.mensaje;
          this.load();
        },
        error: e => {
          this.message = e.error?.mensaje || 'No fue posible eliminar.';
        }
      });
  }

}
