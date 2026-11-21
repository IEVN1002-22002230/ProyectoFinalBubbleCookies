import { Component, DestroyRef, inject } from '@angular/core';
import { interval, merge } from 'rxjs';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-marketing-panel',
  standalone: false,
  templateUrl: './marketing-panel.html',
  styleUrl: './marketing-panel.css'
})
export class MarketingPanel {

  private destroyRef = inject(DestroyRef);

  stats: any = {};
  campaigns: any[] = [];
  sabores: any[] = [];
  canales: any[] = [];

  colores = ['#8fc3ed', '#efb7ca', '#b78f91', '#ecd49c', '#b9c6a8'];

  constructor(private api: ApiService) {
    merge(interval(5000), this.api.dataChanged)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(() => this.load());

    this.load();
  }

  load() {
    this.api.get('marketing').subscribe({
      next: r => {
        this.stats = r.stats || {};
        this.campaigns = r.campanias || [];
        this.sabores = r.sabores || [];
        this.canales = r.canales || [];
      }
    });
  }

  totalSabores() {
    return this.sabores.reduce((total, s) => total + Number(s.cantidad), 0);
  }

  porcentaje(cantidad: number) {
    return this.totalSabores()
      ? Number(cantidad) * 100 / this.totalSabores()
      : 0;
  }

  graficaSabores() {
    let inicio = 0;
    let partes = [];

    for (let i = 0; i < this.sabores.length; i++) {
      let fin = inicio + this.porcentaje(this.sabores[i].cantidad);
      partes.push(`${this.colores[i]} ${inicio}% ${fin}%`);
      inicio = fin;
    }

    return partes.length
      ? `conic-gradient(${partes.join(', ')})`
      : '#f4eee9';
  }

  anchoCanal(roas: number) {
    const maximo = Math.max(...this.canales.map(c => Number(c.roas)), 1);
    return Number(roas) / maximo * 100;
  }
}