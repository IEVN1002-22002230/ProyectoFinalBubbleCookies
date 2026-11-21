import { Component, DestroyRef, inject } from '@angular/core';
import { interval, merge } from 'rxjs';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-pedidos-ventas',
  standalone: false,
  templateUrl: './pedidos-ventas.html',
  styleUrl: './pedidos-ventas.css'
})
export class PedidosVentas {
  private destroyRef = inject(DestroyRef);

  items: any[] = [];
  search = '';
  pedidoSeleccionado: any = null;
  detallePedido: any[] = [];
  detalleCargando = false;

  constructor(private api: ApiService) {
    merge(interval(5000), this.api.dataChanged)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(() => this.load());

    this.load();
  }

  load() {
    this.api.get('pedidos').subscribe(r => {
      this.items = Array.isArray(r) ? r : [];
      if (this.pedidoSeleccionado) {
        const actualizado = this.items.find(x => x.id_pedido === this.pedidoSeleccionado.id_pedido);
        if (actualizado) this.pedidoSeleccionado = actualizado;
      }
    });
  }

  get filtered() {
    const term = this.search.trim().toLowerCase();
    return this.items.filter(x =>
      `${x.codigo_pedido || ''} ${x.nombre_cliente || ''}`.toLowerCase().includes(term)
    );
  }

  abrirDetalle(x: any) {
    this.pedidoSeleccionado = x;
    this.detallePedido = [];
    this.detalleCargando = true;
    this.api.get(`pedidos/${x.id_pedido}/detalle`).subscribe({
      next: r => {
        this.detallePedido = Array.isArray(r) ? r : [];
        this.detalleCargando = false;
      },
      error: () => {
        this.detallePedido = [];
        this.detalleCargando = false;
      }
    });
  }

  cerrarDetalle() {
    this.pedidoSeleccionado = null;
    this.detallePedido = [];
  }

  cambiarEstado(estado: string) {
    if (!this.pedidoSeleccionado) return;
    this.status(this.pedidoSeleccionado, estado);
  }

  status(x: any, s: string) {
    this.api.put('pedidos', x.id_pedido, { estado: s }).subscribe({
      next: () => {
        x.estado = s;
        if (this.pedidoSeleccionado?.id_pedido === x.id_pedido) {
          this.pedidoSeleccionado = { ...this.pedidoSeleccionado, estado: s };
        }
        this.load();
      },
      error: e => alert(e.error?.mensaje || 'No se pudo actualizar el estado del pedido.')
    });
  }

  cancelar(x: any) {
    if (!confirm('¿Cancelar el pedido y devolver existencias al inventario?')) return;

    this.api.delete('pedidos', x.id_pedido).subscribe({
      next: r => {
        alert(r.mensaje);
        this.cerrarDetalle();
        this.load();
      },
      error: e => alert(e.error?.mensaje || 'No se pudo cancelar el pedido.')
    });
  }

  resumenProductos(x: any): string {
    const count = Number(x.cantidad_productos || x.total_productos || 0);
    return x.resumen_productos || (count ? `${count} productos` : 'Ver detalle');
  }

  iniciales(nombre: string): string {
    return (nombre || 'Cliente')
      .trim()
      .split(/\s+/)
      .slice(0, 2)
      .map(p => p.charAt(0).toUpperCase())
      .join('');
  }

  etiquetaEstado(estado: string): string {
    const labels: Record<string, string> = {
      pendiente: 'Pendiente',
      en_preparacion: 'En preparación',
      completado: 'Completado',
      cancelado: 'Cancelado'
    };
    return labels[estado] || estado;
  }

  claseEstado(estado: string): string {
    const classes: Record<string, string> = {
      pendiente: 'bg-[#fff4dc] text-[#b98a3e]',
      en_preparacion: 'bg-[#eaf4fc] text-[#6d9fc8]',
      completado: 'bg-[#edf3e9] text-[#829b73]',
      cancelado: 'bg-[#faeaea] text-[#b77c75]'
    };
    return classes[estado] || 'bg-[#f5f0eb] text-[#987f6d]';
  }

  puntoEstado(estado: string): string {
    const dots: Record<string, string> = {
      pendiente: 'bg-[#d5a34f]',
      en_preparacion: 'bg-[#80b6df]',
      completado: 'bg-[#9bb28b]',
      cancelado: 'bg-[#c88b84]'
    };
    return dots[estado] || 'bg-[#b9a493]';
  }

  tiempo(fecha: string): string {
    if (!fecha) return '—';
    const normalized = String(fecha).includes('T') ? String(fecha) : String(fecha).replace(' ', 'T');
    const date = new Date(normalized);
    if (Number.isNaN(date.getTime())) return '—';
    const minutes = Math.max(0, Math.floor((Date.now() - date.getTime()) / 60000));
    if (minutes < 1) return 'Hace un momento';
    if (minutes < 60) return `Hace ${minutes} min`;
    const hours = Math.floor(minutes / 60);
    if (hours < 24) return `Hace ${hours} h`;
    return `Hace ${Math.floor(hours / 24)} días`;
  }

  exportar() {
    const headers = ['Pedido', 'Cliente', 'Fecha', 'Total', 'Estado'];
    const rows = this.filtered.map(x => [
      x.codigo_pedido,
      x.nombre_cliente,
      x.fecha_pedido,
      x.total,
      this.etiquetaEstado(x.estado)
    ]);
    const csv = [headers, ...rows]
      .map(row => row.map(value => `"${String(value ?? '').replace(/"/g, '""')}"`).join(','))
      .join('\r\n');
    const blob = new Blob(['\ufeff' + csv], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = 'reporte-pedidos-bubblecookies.csv';
    link.click();
    URL.revokeObjectURL(url);
  }
}
