import { Component, OnInit, ChangeDetectorRef, DestroyRef, inject } from '@angular/core';
import { interval } from 'rxjs';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { ApiService } from '../../services/api.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-mis-pedidos',
  standalone: false,
  templateUrl: './mis-pedidos.html'
})
export class MisPedidos implements OnInit {
  private destroyRef = inject(DestroyRef);
  pedidos: any[] = [];
  loading = true;
  error = '';
  expanded: number | null = null;

  constructor(private api: ApiService, private router: Router, private cdr: ChangeDetectorRef) {}

  ngOnInit() {
    this.load();
    interval(5000).pipe(takeUntilDestroyed(this.destroyRef)).subscribe(() => this.load());
  }

  load() {
    this.loading = true;
    this.api.get('mis-pedidos').subscribe({
      next: r => { this.pedidos = r?.pedidos || []; this.loading = false; this.error = ''; this.cdr.detectChanges(); },
      error: e => { this.loading = false; this.error = e.error?.mensaje || 'No fue posible consultar tus pedidos.'; this.cdr.detectChanges(); }
    });
  }

  toggle(id: number) { this.expanded = this.expanded === id ? null : id; }
  statusLabel(status: string) {
    return status === 'en_preparacion' ? 'En preparación' : status === 'completado' ? 'Completado' : status === 'cancelado' ? 'Cancelado' : 'Pendiente';
  }
  statusClass(status: string) {
    return status === 'completado' ? 'bg-emerald-50 text-emerald-700' : status === 'en_preparacion' ? 'bg-sky-50 text-sky-700' : status === 'cancelado' ? 'bg-rose-50 text-rose-700' : 'bg-amber-50 text-amber-700';
  }
  progress(status: string) { return status === 'completado' ? 3 : status === 'en_preparacion' ? 2 : status === 'cancelado' ? 0 : 1; }
  date(value: string) { return value ? new Date(value).toLocaleString('es-MX', { dateStyle: 'medium', timeStyle: 'short' }) : ''; }
}
