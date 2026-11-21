import { Component, OnInit, DestroyRef, inject, ChangeDetectorRef } from '@angular/core';
import { interval, merge } from 'rxjs';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-catalogo',
  standalone: false,
  templateUrl: './catalogo.html',
  styleUrl: './catalogo.css'
})
export class Catalogo implements OnInit {
  private destroyRef = inject(DestroyRef);
  private cdr = inject(ChangeDetectorRef);
  
  products: any[] = [];
  message = '';
  loading = true;
  error = '';
  stockModalOpen = false;
  stockModalTitle = 'No hay stock suficiente';
  stockModalMessage = '';
  stockAvailable: number | null = null;
  private addedThisSession: Record<number, number> = {};
  private loaded = false;
  readonly stories = [
    { image: '/assets/bubblecookies/cookies/bubble-choco.png', title: 'Más que galletas, horneamos recuerdos.', first: 'BubbleCookies nació de una idea sencilla: los mejores momentos se comparten. Por eso, elegimos cada ingrediente con cuidado y preparamos cada lote a mano, como en casa.', second: 'Una pausa, un regalo o un “pensé en ti”. Siempre hay una buena razón para compartir algo dulce.', sign: 'Con amor, BubbleCookies' },
    { image: '/assets/bubblecookies/cookies/double-fresa.png', title: 'Un detalle dulce dice mucho.', first: 'Cada galleta se prepara con paciencia y buenos ingredientes, para acompañar esos momentos que quieres guardar.', second: 'Hechas para regalar, compartir y disfrutar sin prisa.', sign: 'Con cariño, BubbleCookies' },
    { image: '/assets/bubblecookies/cookies/lemon-glass.png', title: 'Pequeñas galletas. Grandes momentos.', first: 'Nos inspiran las recetas de casa, los sabores frescos y la alegría de compartir algo recién horneado.', second: 'Gracias por hacerle un espacio a BubbleCookies en tu mesa.', sign: 'Siempre recién horneadas' }
  ];
  storyIndex = 0;

  constructor(private api: ApiService) {}

  previousStory() { this.storyIndex = (this.storyIndex + this.stories.length - 1) % this.stories.length; }
  nextStory() { this.storyIndex = (this.storyIndex + 1) % this.stories.length; }
  cookieColor(index: number) { return ['#d8eaf8', '#f6e5ef', '#f2e1dc', '#f0edda', '#e7f1e8'][index % 5]; }

  ngOnInit() {
    this.load();
    merge(interval(5000), this.api.dataChanged)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(() => this.load());
  }

  load() {
    if (!this.loaded) this.loading = true;
    this.api.products().subscribe({
      next: r => {
        this.products = Array.isArray(r?.productos) ? r.productos : [];
        this.loaded = true;
        this.loading = false;
        this.error = '';
        this.cdr.detectChanges(); // Fuerza a Angular a pintar los productos al instante
      },
      error: e => {
        this.loading = false;
        // Conserva los productos ya visibles y no muestra error si ya cargó antes
        if (!this.loaded) {
          this.products = [];
          this.error = e.error?.mensaje || 'No fue posible cargar el catálogo. Comprueba que Flask esté activo.';
        }
        this.cdr.detectChanges();
      }
    });
  }

  add(id: number) {
    const product = this.products.find(p => Number(p.id_producto) === Number(id));
    const stock = Number(product?.existencia ?? 0);
    const added = this.addedThisSession[id] || 0;

    if (!product || stock <= added) {
      this.openStockModal(product?.nombre || 'Este producto', Math.max(0, stock - added));
      return;
    }

    this.api.addCart(id).subscribe({
      next: r => {
        this.addedThisSession[id] = added + 1;
        this.message = r.mensaje || 'Producto agregado.';
        this.cdr.detectChanges();
      },
      error: e => {
        if (e.status === 409) {
          const available = Number(e.error?.stock_disponible ?? Math.max(0, stock - added));
          this.openStockModal(product.nombre, available, e.error?.mensaje);
        } else {
          this.message = e.error?.mensaje || 'No fue posible agregar el producto.';
        }
        this.cdr.detectChanges();
      }
    });
  }

  openStockModal(nombre: string, available: number, message?: string) {
    this.stockModalTitle = 'No hay stock suficiente';
    this.stockAvailable = available;
    this.stockModalMessage = message ||
      (available > 0
        ? `Solo hay ${available} unidad(es) disponible(s) de ${nombre}. No puedes agregar más unidades de las que tenemos en existencia.`
        : `${nombre} está agotado por el momento. No es posible agregarlo al carrito.`);
    this.stockModalOpen = true;
    this.cdr.detectChanges();
  }

  closeStockModal() {
    this.stockModalOpen = false;
    this.stockModalMessage = '';
  }
}
