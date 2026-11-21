
import { Component, DestroyRef, inject } from '@angular/core';
import { interval, merge } from 'rxjs';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { ApiService } from '../../services/api.service';
import html2canvas from 'html2canvas';
import { jsPDF } from 'jspdf';

@Component({
  selector: 'app-dashboard',
  standalone: false,
  templateUrl: './dashboard.html',
  styleUrl: './dashboard.css'
})
export class Dashboard {
  private destroyRef = inject(DestroyRef);

  stats: any = { ventas: 0, pedidos: 0, productos: 0, stock: 0, producidos: 0 };
  ventasSemanales: any[] = [];
  productosVendidos: any[] = [];
  inventarioBajo: any[] = [];
  pedidosEstado: any[] = [];
  orders: any[] = [];

  galletas: any[] = [
    { nombre: 'Bubble Choco', imagen: 'bubble-choco.png', color: '#95c3e9', cantidad: 0 },
    { nombre: 'Double Fresa', imagen: 'double-fresa.png', color: '#f3d3df', cantidad: 0 },
    { nombre: 'Red Velvet', imagen: 'red-velvet.png', color: '#bd989a', cantidad: 0 },
    { nombre: 'Butter Cookies', imagen: 'butter-cookies.png', color: '#ecd6a0', cantidad: 0 },
    { nombre: 'Lemon Glass', imagen: 'lemon-glass.png', color: '#bbc5a7', cantidad: 0 }
  ];

  constructor(private api: ApiService) {
    merge(interval(5000), this.api.dataChanged)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(() => this.load());

    this.load();
  }

  // DATOS DE FLASK
  load(): void {
    this.api.get('dashboard').subscribe({
      next: (r: any) => {
        this.stats = {
          ventas: this.toNumber(r.stats?.ventas),
          pedidos: this.toNumber(r.stats?.pedidos),
          productos: this.toNumber(r.stats?.productos),
          stock: this.toNumber(r.stats?.stock),
          producidos: this.toNumber(r.stats?.producidos)
        };

        this.ventasSemanales = r.ventas_semanales || [];
        this.productosVendidos = r.productos_vendidos || [];
        this.inventarioBajo = r.inventario_bajo || [];
        this.pedidosEstado = r.pedidos_estado || [];
        this.orders = r.pedidos || [];

        this.actualizarGalletas();
      },
      error: (err: any) => console.error('Error al cargar el Dashboard:', err)
    });
  }

  toNumber(value: any): number {
    return Number(value) || 0;
  }

  // BARRAS E INVENTARIO
  getMaxValue(items: any[], field: string): number {
    return Math.max(...items.map(item => this.toNumber(item[field])), 0);
  }

  getBarWidth(value: any, items: any[], field: string): number {
    const max = this.getMaxValue(items, field);
    return max > 0 ? Math.max((this.toNumber(value) / max) * 100, 2) : 0;
  }

  getStockWidth(cantidad: any, minimo: any): number {
    const limite = this.toNumber(minimo);
    return limite > 0 ? Math.min((this.toNumber(cantidad) / limite) * 100, 100) : 0;
  }

  // GRÁFICA DE CRECIMIENTO
  getPointX(index: number): number {
    const total = this.ventasSemanales.length;
    return total > 1 ? (index / (total - 1)) * 700 : 350;
  }

  getPointY(field: 'ventas' | 'pedidos', value: any): number {
    const max = Math.max(this.getMaxValue(this.ventasSemanales, field), 1);
    return 178 - (this.toNumber(value) / max) * 166;
  }

  getLinePoints(field: 'ventas' | 'pedidos'): string {
    return this.ventasSemanales.map((item, i) =>
      `${this.getPointX(i)},${this.getPointY(field, item[field])}`
    ).join(' ');
  }

  getSmoothPath(field: 'ventas' | 'pedidos'): string {
    if (!this.ventasSemanales.length) return '';

    let camino = `M ${this.getPointX(0)} ${this.getPointY(field, this.ventasSemanales[0][field])}`;

    for (let i = 1; i < this.ventasSemanales.length; i++) {
      const x1 = this.getPointX(i - 1);
      const x2 = this.getPointX(i);
      const y1 = this.getPointY(field, this.ventasSemanales[i - 1][field]);
      const y2 = this.getPointY(field, this.ventasSemanales[i][field]);
      const medio = (x1 + x2) / 2;

      camino += ` C ${medio} ${y1}, ${medio} ${y2}, ${x2} ${y2}`;
    }

    return camino;
  }

  getAreaPath(field: 'ventas' | 'pedidos'): string {
    if (!this.ventasSemanales.length) return '';
    return `${this.getSmoothPath(field)} L 700 190 L 0 190 Z`;
  }

  // LAS CONSENTIDAS
  actualizarGalletas(): void {
    this.galletas = this.galletas.map(galleta => {
      const producto = this.productosVendidos.find(item =>
        String(item.nombre || '').toLowerCase().trim() === galleta.nombre.toLowerCase()
      );

      return { ...galleta, cantidad: this.toNumber(producto?.cantidad) };
    });
  }

  getMaxGalletas(): number {
    return Math.max(...this.galletas.map(g => g.cantidad), 1);
  }

  getAlturaGalleta(cantidad: number): number {
    return (cantidad / this.getMaxGalletas()) * 85;
  }

  getTotalGalletasVendidas(): number {
    return this.galletas.reduce((total, g) => total + g.cantidad, 0);
  }

  getGalletaFavorita(): any {
    return this.galletas.reduce(
      (mayor, g) => g.cantidad > mayor.cantidad ? g : mayor,
      this.galletas[0]
    );
  }

  getProductImage(producto: any): string {
    if (!producto.imagen) return '';
    return producto.imagen.startsWith('/assets/')
      ? producto.imagen
      : '/assets/bubblecookies/cookies/' + producto.imagen;
  }

  // ESTADOS DE PEDIDOS
  getStatusTotal(): number {
    return this.pedidosEstado.reduce(
      (total, item) => total + this.toNumber(item.cantidad), 0
    );
  }

  normalizarEstado(estado: string): string {
    return String(estado || '').toLowerCase()
      .replace(/_/g, ' ')
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '');
  }

  getStatusColor(estado: string): string {
    const colors: any = {
      pendiente: '#f5c66b',
      'en preparacion': '#e99bb5',
      completado: '#8bc9a5',
      cancelado: '#b9b3cc'
    };
    return colors[this.normalizarEstado(estado)] || '#a9b9df';
  }

  getStatusGradient(): string {
    const total = this.getStatusTotal();
    if (!total) return '#f1eee9';

    let actual = 0;

    const secciones = this.pedidosEstado.map(item => {
      const inicio = actual;
      actual += (this.toNumber(item.cantidad) / total) * 100;

      return `${this.getStatusColor(item.estado)} ${inicio}% ${actual}%`;
    });

    return `conic-gradient(${secciones.join(', ')})`;
  }

  getStatusLabel(estado: string): string {
    const labels: any = {
      pendiente: 'Pendientes',
      'en preparacion': 'En preparación',
      completado: 'Completados',
      cancelado: 'Cancelados'
    };
    return labels[this.normalizarEstado(estado)] || estado;
  }

  getOrderStatusClass(estado: string): string {
    const classes: any = {
      pendiente: 'status-pendiente',
      'en preparacion': 'status-preparacion',
      completado: 'status-completado',
      cancelado: 'status-cancelado'
    };
    return classes[this.normalizarEstado(estado)] || '';
  }
  async exportarReporte() {
    const dashboard = document.querySelector('.dashboard') as HTMLElement;
    const imagen = await html2canvas(dashboard);

    const pdf = new jsPDF('p', 'mm', 'a4');
    const ancho = pdf.internal.pageSize.getWidth();
    const alto = imagen.height * ancho / imagen.width;

    pdf.addImage(imagen.toDataURL('image/png'), 'PNG', 0, 0, ancho, alto);
    pdf.save('Dashboard_BubbleCookies.pdf');
  }
}

