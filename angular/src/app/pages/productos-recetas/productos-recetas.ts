
import { Component, DestroyRef, inject } from '@angular/core';
import { interval, merge } from 'rxjs';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-productos-recetas',
  standalone: false,
  templateUrl: './productos-recetas.html',
  styleUrl: './productos-recetas.css'
})
export class ProductosRecetas {

  private destroyRef = inject(DestroyRef);

  get role() {
    try {
      return JSON.parse(
        localStorage.getItem('bubblecookies-user') || '{}'
      ).rol || '';
    } catch {
      return '';
    }
  }

  products: any[] = [];
  recipes: any[] = [];
  ingredients: any[] = [];

  selected: any = null;

  showForm = false;
  showRecipeForm = false;
  message = '';

  form: any = {
    nombre: '',
    descripcion: '',
    precio: 0,
    imagen: '',
    color_hex: '#8cc0eb',
    etiqueta: ''
  };

  recipeForm: any = {
    id_producto: 0,
    nombre: '',
    unidades_por_lote: 12,
    instrucciones: '',
    ingredientes: []
  };

  constructor(private api: ApiService) {
    merge(interval(5000), this.api.dataChanged)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(() => this.load());

    this.load();
  }

  load() {
    this.api.products().subscribe({
      next: r => {
        this.products = Array.isArray(r?.productos) ? r.productos : [];

        if (this.products.length) {
          this.selected = this.products.find(
            p => p.id_producto === this.selected?.id_producto
          ) || this.products[0];
        } else {
          this.selected = null;
        }
      }
    });

    this.api.get('recetas').subscribe({
      next: r => {
        this.recipes = Array.isArray(r) ? r : [];
      }
    });

    this.api.get('ingredientes').subscribe({
      next: r => {
        this.ingredients = Array.isArray(r) ? r : [];
      }
    });
  }

  seleccionar(p: any) {
    this.selected = p;
    this.showForm = false;
    this.showRecipeForm = false;
  }

  get recetaSeleccionada() {
    return this.recipes.find(
      r => r.id_producto === this.selected?.id_producto
    ) || null;
  }

  nombreIngrediente(ing: any) {
    return ing.nombre ||
      ing.ingrediente ||
      this.ingredients.find(
        x => x.id_ingrediente === ing.id_ingrediente
      )?.nombre ||
      'Ingrediente';
  }

  imagenError(event: Event) {
    const img = event.target as HTMLImageElement;
    img.onerror = null;
    img.style.visibility = 'hidden';
  }

  nuevo() {
    this.form = {
      nombre: '',
      descripcion: '',
      precio: 0,
      imagen: '/assets/bubblecookies/cookies/',
      color_hex: '#8cc0eb',
      etiqueta: ''
    };

    this.showForm = true;
  }

  editar(p: any) {
    this.form = { ...p };
    this.showForm = true;
  }

  guardar() {
    const req = this.form.id_producto
      ? this.api.put('productos', this.form.id_producto, this.form)
      : this.api.post('productos', this.form);

    req.subscribe({
      next: r => {
        this.message = r.mensaje || 'Producto guardado.';
        this.showForm = false;
        this.load();
      },
      error: e => {
        this.message = e.error?.mensaje ||
          'No fue posible guardar el producto.';
      }
    });
  }

  nuevaReceta() {
    this.recipeForm = {
      id_producto: this.selected?.id_producto || this.products[0]?.id_producto || 0,
      nombre: '',
      unidades_por_lote: 12,
      instrucciones: '',
      ingredientes: []
    };

    this.showRecipeForm = true;
  }

  agregarIngredienteReceta() {
    this.recipeForm.ingredientes.push({
      id_ingrediente: this.ingredients[0]?.id_ingrediente || 0,
      cantidad: 0,
      unidad: this.ingredients[0]?.unidad || 'kg'
    });
  }

  editarReceta(r: any) {
    this.recipeForm = {
      id_receta: r.id_receta,
      id_producto: r.id_producto,
      nombre: r.nombre,
      unidades_por_lote: r.unidades_por_lote,
      instrucciones: r.instrucciones || '',
      ingredientes: (r.ingredientes || []).map(
        (x: any) => ({ ...x })
      )
    };

    this.showRecipeForm = true;
  }

  guardarReceta() {
    const req = this.recipeForm.id_receta
      ? this.api.put('recetas', this.recipeForm.id_receta, this.recipeForm)
      : this.api.post('recetas', this.recipeForm);

    req.subscribe({
      next: r => {
        this.message = r.mensaje || 'Receta guardada.';
        this.showRecipeForm = false;
        this.load();
      },
      error: e => {
        this.message = e.error?.mensaje ||
          'No se pudo guardar la receta.';
      }
    });
  }

  eliminarReceta(r: any) {
    if (!confirm('¿Desactivar la receta ' + r.nombre + '?')) return;

    this.api.delete('recetas', r.id_receta).subscribe({
      next: r => {
        this.message = r.mensaje;
        this.load();
      },
      error: e => {
        this.message = e.error?.mensaje ||
          'No se pudo eliminar la receta.';
      }
    });
  }

  eliminar(p: any) {
    if (!confirm(`¿Desactivar ${p.nombre} del catálogo?`)) return;

    this.api.delete('productos', p.id_producto).subscribe({
      next: r => {
        this.message = r.mensaje;
        this.load();
      },
      error: e => {
        this.message = e.error?.mensaje ||
          'No fue posible eliminar el producto.';
      }
    });
  }

}
