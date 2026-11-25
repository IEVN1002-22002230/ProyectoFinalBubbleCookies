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
  private previewObjectUrl: string | null = null;

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
  selectedImage: File | null = null;
  imagePreview = '';

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
            p => Number(p.id_producto) === Number(this.selected?.id_producto)
          ) || this.products[0];
        } else {
          this.selected = null;
        }
      },
      error: e => {
        this.message = e.error?.mensaje || 'No fue posible cargar los productos.';
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
      r => Number(r.id_producto) === Number(this.selected?.id_producto)
    ) || null;
  }

  colorProducto(color: string): string {
    return /^#[0-9A-Fa-f]{6}$/.test(String(color || '')) ? color : '#EDF7FD';
  }

  nombreIngrediente(ing: any) {
    return ing.nombre ||
      ing.ingrediente ||
      this.ingredients.find(
        x => Number(x.id_ingrediente) === Number(ing.id_ingrediente)
      )?.nombre ||
      'Ingrediente';
  }

  imagenError(event: Event) {
    const img = event.target as HTMLImageElement;
    img.onerror = null;
    img.src = '/assets/bubblecookies/cookies/bubble-choco.png';
  }

  private limpiarVistaPrevia() {
    if (this.previewObjectUrl) {
      URL.revokeObjectURL(this.previewObjectUrl);
      this.previewObjectUrl = null;
    }
  }

  nuevo() {
    this.limpiarVistaPrevia();
    this.form = {
      nombre: '',
      descripcion: '',
      precio: 0,
      imagen: '',
      color_hex: '#8cc0eb',
      etiqueta: ''
    };
    this.selectedImage = null;
    this.imagePreview = '';
    this.message = '';
    this.showForm = true;
  }

  editar(p: any) {
    this.limpiarVistaPrevia();
    this.form = { ...p };
    this.selectedImage = null;
    this.imagePreview = p.imagen || '';
    this.message = '';
    this.showForm = true;
  }

  seleccionarImagen(event: Event) {
    const input = event.target as HTMLInputElement;
    const file = input.files?.[0] || null;
    if (!file) return;

    const formatosPermitidos = ['image/png', 'image/jpeg', 'image/webp'];
    if (!formatosPermitidos.includes(file.type)) {
      this.message = 'Formato no válido. Selecciona PNG, JPG o WEBP.';
      input.value = '';
      return;
    }

    if (file.size > 5 * 1024 * 1024) {
      this.message = 'La imagen no debe superar 5 MB.';
      input.value = '';
      return;
    }

    this.limpiarVistaPrevia();
    this.selectedImage = file;
    this.previewObjectUrl = URL.createObjectURL(file);
    this.imagePreview = this.previewObjectUrl;
    this.message = '';
  }

  private guardarProducto() {
    const esEdicion = !!this.form.id_producto;
    const solicitud = esEdicion
      ? this.api.put('productos', this.form.id_producto, this.form)
      : this.api.post('productos', this.form);

    solicitud.subscribe({
      next: r => {
        this.message = r?.mensaje || 'Producto guardado correctamente.';
        this.showForm = false;
        this.selectedImage = null;
        this.limpiarVistaPrevia();
        this.imagePreview = '';
        this.load();
      },
      error: e => {
        this.message = e.error?.mensaje || 'No fue posible guardar el producto.';
      }
    });
  }

  guardar() {
    const hex = String(this.form.color_hex || '').trim();
    if (!/^#[0-9A-Fa-f]{6}$/.test(hex)) {
      this.message = 'El color debe tener formato hexadecimal #RRGGBB.';
      return;
    }

    this.form.color_hex = hex.toLowerCase();
    this.message = '';

    // Si el usuario eligió una imagen, primero se sube a Flask.
    if (this.selectedImage) {
      this.api.uploadProductImage(this.selectedImage).subscribe({
        next: r => {
          if (!r?.imagen) {
            this.message = 'Flask no devolvió la dirección de la imagen.';
            return;
          }

          // La URL se guarda en el campo imagen del producto en MySQL.
          this.form.imagen = r.imagen;
          this.guardarProducto();
        },
        error: e => {
          this.message = e.error?.mensaje || 'No se pudo subir la imagen.';
        }
      });
      return;
    }

    // Si no se seleccionó una imagen nueva, conserva la imagen existente.
    this.guardarProducto();
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

  cambiarIngredienteReceta(ing: any) {
    const item = this.ingredients.find(
      x => Number(x.id_ingrediente) === Number(ing.id_ingrediente)
    );
    if (item) ing.unidad = item.unidad;
  }

  editarReceta(r: any) {
    this.recipeForm = {
      id_receta: r.id_receta,
      id_producto: r.id_producto,
      nombre: r.nombre,
      unidades_por_lote: r.unidades_por_lote,
      instrucciones: r.instrucciones || '',
      ingredientes: (r.ingredientes || []).map((x: any) => ({ ...x }))
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
        this.message = e.error?.mensaje || 'No se pudo guardar la receta.';
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
        this.message = e.error?.mensaje || 'No se pudo eliminar la receta.';
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
        this.message = e.error?.mensaje || 'No fue posible eliminar el producto.';
      }
    });
  }
}
