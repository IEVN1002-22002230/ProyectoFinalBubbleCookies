
import { Component, DestroyRef, inject } from '@angular/core';
import { interval, merge } from 'rxjs';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-cocina',
  standalone: false,
  templateUrl: './cocina.html',
  styleUrl: './cocina.css'
})
export class Cocina {

  private destroyRef = inject(DestroyRef);

  products: any[] = [];
  ingredients: any[] = [];
  productions: any[] = [];
  message = '';

  constructor(private api: ApiService) {
    merge(interval(5000), this.api.dataChanged)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(() => this.load());

    this.load();
  }

  load() {
    this.api.products().subscribe({
      next: r => {
        this.products = r.productos || [];
      }
    });

    this.api.get('ingredientes').subscribe({
      next: r => {
        this.ingredients = r || [];
      }
    });

    this.api.get('producciones').subscribe({
      next: r => {
        this.productions = r || [];
      }
    });
  }

}
