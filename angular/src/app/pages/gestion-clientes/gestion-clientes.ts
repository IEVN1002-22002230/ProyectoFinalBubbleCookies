
import { Component, DestroyRef, inject } from '@angular/core';
import { interval, merge } from 'rxjs';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-gestion-clientes',
  standalone: false,
  templateUrl: './gestion-clientes.html',
  styleUrl: './gestion-clientes.css'
})
export class GestionClientes {

  private destroyRef = inject(DestroyRef);

  clients: any[] = [];
  showForm = false;
  message = '';

  form: any = {
    nombre: '',
    apellidos: '',
    correo: '',
    telefono: '',
    ciudad: ''
  };

  constructor(private api: ApiService) {
    merge(interval(5000), this.api.dataChanged)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(() => this.load());

    this.load();
  }

  load() {
    this.api.get('clientes').subscribe({
      next: r => {
        this.clients = Array.isArray(r) ? r : [];
      },
      error: e => {
        this.message = e.error?.mensaje || 'Error al cargar clientes.';
      }
    });
  }

  nuevo() {
    this.form = {
      nombre: '',
      apellidos: '',
      correo: '',
      telefono: '',
      ciudad: ''
    };

    this.showForm = true;
  }

  editar(x: any) {
    this.form = { ...x };
    this.showForm = true;
  }

  guardar() {
    const req = this.form.id_cliente
      ? this.api.put('clientes', this.form.id_cliente, this.form)
      : this.api.post('clientes', this.form);

    req.subscribe({
      next: r => {
        this.message = r.mensaje || 'Cliente guardado.';
        this.showForm = false;
        this.load();
      },
      error: e => {
        this.message = e.error?.mensaje || 'No fue posible guardar el cliente.';
      }
    });
  }

  exportarCSV() {
    if (!this.clients.length) {
      this.message = 'No hay clientes para exportar.';
      return;
    }

    const headers = ['ID', 'Nombre', 'Apellidos', 'Correo', 'Telefono', 'Ciudad', 'Fecha de registro'];
    const rows = this.clients.map(x => [
      x.id_cliente,
      x.nombre,
      x.apellidos,
      x.correo,
      x.telefono,
      x.ciudad,
      x.creado_en
    ]);
    const csv = [headers, ...rows]
      .map(row => row.map(value => `"${String(value ?? '').replace(/"/g, '""')}"`).join(','))
      .join('\\r\\n');
    const blob = new Blob(['\\ufeff' + csv], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `clientes-bubblecookies-${new Date().toISOString().slice(0, 10)}.csv`;
    document.body.appendChild(link);
    link.click();
    link.remove();
    URL.revokeObjectURL(url);
    this.message = 'Reporte CSV de clientes generado correctamente.';
  }

  eliminar(x: any) {
    if (!confirm(`¿Eliminar al cliente ${x.nombre}? Si tiene pedidos históricos, se desactivará para conservarlos.`)) return;

    this.api.delete('clientes', x.id_cliente)
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
