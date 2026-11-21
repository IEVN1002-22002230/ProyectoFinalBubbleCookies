
import { Component, DestroyRef, inject } from '@angular/core';
import { interval, merge } from 'rxjs';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-proveedores-compras',
  standalone: false,
  templateUrl: './proveedores-compras.html',
  styleUrl: './proveedores-compras.css'
})
export class ProveedoresCompras {

  private destroyRef = inject(DestroyRef);

  providers: any[] = [];
  purchases: any[] = [];
  ingredients: any[] = [];

  show = false;
  showPurchase = false;
  message = '';

  purchaseForm: any = {
    id_proveedor: 0,
    id_ingrediente: 0,
    cantidad: 1,
    costo_unitario: 0,
    observaciones: ''
  };

  form: any = {
    nombre: '',
    contacto: '',
    telefono: '',
    correo: ''
  };

  constructor(private api: ApiService) {
    merge(interval(5000), this.api.dataChanged)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(() => this.load());

    this.load();
  }

  load() {
    this.api.get('proveedores').subscribe({
      next: r => {
        this.providers = Array.isArray(r) ? r : [];
      }
    });

    this.api.get('compras').subscribe({
      next: r => {
        this.purchases = Array.isArray(r) ? r : [];
      }
    });

    this.api.get('ingredientes').subscribe({
      next: r => {
        this.ingredients = Array.isArray(r) ? r : [];
      }
    });
  }

  nuevo() {
    this.form = {
      nombre: '',
      contacto: '',
      telefono: '',
      correo: ''
    };

    this.show = true;
  }

  editar(x: any) {
    this.form = { ...x };
    this.show = true;
  }

  save() {
    const req = this.form.id_proveedor
      ? this.api.put('proveedores', this.form.id_proveedor, this.form)
      : this.api.post('proveedores', this.form);

    req.subscribe({
      next: r => {
        this.message = r.mensaje || 'Proveedor guardado.';
        this.show = false;
        this.load();
      },
      error: e => {
        this.message = e.error?.mensaje || 'No fue posible guardar el proveedor.';
      }
    });
  }

  nuevaCompra() {
    this.purchaseForm = {
      id_proveedor: this.providers[0]?.id_proveedor || 0,
      id_ingrediente: this.ingredients[0]?.id_ingrediente || 0,
      cantidad: 1,
      costo_unitario: 0,
      observaciones: ''
    };

    this.showPurchase = true;
  }

  guardarCompra() {
    this.api.post('compras', {
      id_proveedor: this.purchaseForm.id_proveedor,
      observaciones: this.purchaseForm.observaciones,
      detalles: [
        {
          id_ingrediente: this.purchaseForm.id_ingrediente,
          cantidad: this.purchaseForm.cantidad,
          costo_unitario: this.purchaseForm.costo_unitario
        }
      ]
    }).subscribe({
      next: r => {
        this.message = r.mensaje;
        this.showPurchase = false;
        this.load();
      },
      error: e => {
        this.message = e.error?.mensaje || 'No se pudo registrar la compra.';
      }
    });
  }

  cancelarCompra(x: any) {
    if (!confirm('¿Cancelar la compra y revertir la materia prima?')) return;

    this.api.delete('compras', x.id_compra).subscribe({
      next: r => {
        this.message = r.mensaje;
        this.load();
      },
      error: e => {
        this.message = e.error?.mensaje || 'No se pudo cancelar la compra.';
      }
    });
  }

  eliminar(x: any) {
    if (!confirm(`¿Eliminar al proveedor ${x.nombre}? Si tiene compras históricas, se desactivará para conservarlas.`)) return;

    this.api.delete('proveedores', x.id_proveedor).subscribe({
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
