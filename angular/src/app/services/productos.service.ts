
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

import {
  Producto,
  RespuestaProductos,
  RespuestaCarrito
} from '../models/producto';

@Injectable({
  providedIn: 'root'
})
export class ProductosService {

  private apiUrl = 'http://localhost:5000/api';

  constructor(private http: HttpClient) {}

  private obtenerToken(): string {
    let token = localStorage.getItem('bubblecookies_token');

    if (!token) {
      token = typeof crypto !== 'undefined' && crypto.randomUUID
        ? crypto.randomUUID()
        : 'bc-' + Date.now() + '-' + Math.random().toString(36).slice(2);

      localStorage.setItem('bubblecookies_token', token);
    }

    return token;
  }

  obtenerProductos(): Observable<RespuestaProductos> {
    return this.http.get<RespuestaProductos>(
      `${this.apiUrl}/productos`, { withCredentials: true }
    );
  }

  obtenerCarrito(): Observable<RespuestaCarrito> {
    const token = this.obtenerToken();

    return this.http.get<RespuestaCarrito>(
      `${this.apiUrl}/carrito/${token}`, { withCredentials: true }
    );
  }

  agregarAlCarrito(idProducto: number): Observable<any> {
    const token = this.obtenerToken();

    return this.http.post(
      `${this.apiUrl}/carrito/${token}`,
      { id_producto: idProducto }, { withCredentials: true }
    );
  }

  vaciarCarrito(): Observable<any> {
    const token = this.obtenerToken();

    return this.http.delete(
      `${this.apiUrl}/carrito/${token}`, { withCredentials: true }
    );
  }
}
