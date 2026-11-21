
export interface Producto {
  id_producto: number;
  nombre: string;
  descripcion: string;
  precio: number | string;
  imagen: string;
  color_hex: string;
  etiqueta: string;
  activo: number;
  existencia: number;
  minimo: number;
}

export interface ProductoCarrito {
  id_producto: number;
  nombre: string;
  precio: number;
  imagen: string;
  cantidad: number;
  subtotal: number;
}

export interface RespuestaProductos {
  estado: string;
  total: number;
  productos: Producto[];
}

export interface RespuestaCarrito {
  estado: string;
  items: ProductoCarrito[];
  cantidad_total: number;
  total: number;
}
