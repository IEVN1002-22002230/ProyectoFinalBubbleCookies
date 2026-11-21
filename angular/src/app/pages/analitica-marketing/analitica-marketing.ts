
import { Component, DestroyRef, inject } from '@angular/core';
import { interval, merge } from 'rxjs';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-analitica-marketing',
  standalone: false,
  templateUrl: './analitica-marketing.html',
  styleUrl: './analitica-marketing.css'
})
export class AnaliticaMarketing {

  private destroyRef = inject(DestroyRef);

  stats: any = {};
  campaigns: any[] = [];
  showForm = false;
  message = '';

  form: any = {
    nombre: '',
    canal: 'Google Ads',
    fecha_inicio: '',
    fecha_fin: '',
    presupuesto: 0,
    estado: 'activa'
  };

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
      }
    });
  }

  nuevo() {
    this.form = {
      nombre: '',
      canal: 'Google Ads',
      fecha_inicio: '',
      fecha_fin: '',
      presupuesto: 0,
      estado: 'activa'
    };

    this.showForm = true;
  }

  editar(c: any) {
    this.form = {
      ...c,
      fecha_inicio: c.fecha_inicio?.substring(0, 10) || '',
      fecha_fin: c.fecha_fin?.substring(0, 10) || ''
    };

    this.showForm = true;
  }

  eliminar(c: any) {
    if (!confirm('¿Eliminar esta campaña? Si tiene métricas históricas se conservará como registro finalizado.')) return;

    this.api.delete('campanias', c.id_campania)
      .subscribe({
        next: r => {
          this.message = r.mensaje;
          this.load();
        },
        error: e => {
          this.message = e.error?.mensaje || 'No se pudo eliminar la campaña.';
        }
      });
  }

  guardar() {
    const req = this.form.id_campania
      ? this.api.put('campanias', this.form.id_campania, this.form)
      : this.api.post('campanias', this.form);

    req.subscribe({
      next: r => {
        this.message = r.mensaje || 'Campaña guardada.';
        this.showForm = false;
        this.load();
      },
      error: e => {
        this.message = e.error?.mensaje || 'No fue posible guardar la campaña.';
      }
    });
  }

}
