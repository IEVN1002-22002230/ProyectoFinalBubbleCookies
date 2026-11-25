import { Injectable, ApplicationRef } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { BehaviorSubject, Observable, Subject, tap } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class ApiService {
  readonly base = 'http://localhost:5000/api';
  readonly token = 'bubblecookies-session';
  readonly cartChanged = new Subject<void>();
  /** Estado único compartido del carrito para evitar desfaces entre el Navbar y la tabla */
  readonly cartState$ = new BehaviorSubject<any>({ items: [], total: 0, cantidad_total: 0 });
  /** Notifica a las pantallas abiertas cuando una operación modifica datos. */
  readonly dataChanged = new Subject<void>();

  constructor(private http: HttpClient, private appRef: ApplicationRef) {}

  private tick() {
    queueMicrotask(() => this.appRef.tick());
  }

  private sync<T>(request: Observable<T>): Observable<T> {
    return request.pipe(
      tap({
        next: () => this.tick(),
        error: () => this.tick()
      })
    );
  }

  private refreshCartState() {
    this.http
      .get<any>(`${this.base}/carrito/${this.token}?t=${Date.now()}`, { withCredentials: true })
      .subscribe({
        next: res => {
          this.cartState$.next(res || { items: [], total: 0, cantidad_total: 0 });
          this.cartChanged.next();
          this.tick();
        }
      });
  }


  uploadProductImage(file: File): Observable<any> {
    const data = new FormData();
    data.append('imagen', file);
    return this.http.post(`${this.base}/upload/producto`, data, { withCredentials: true });
  }

  products(): Observable<any> {
    return this.sync(
      this.http.get(`${this.base}/productos?t=${Date.now()}`, { withCredentials: true })
    );
  }

  getCart(): Observable<any> {
    return this.sync(
      this.http.get<any>(`${this.base}/carrito/${this.token}?t=${Date.now()}`, { withCredentials: true }).pipe(
        tap(res => {
          if (res) this.cartState$.next(res);
        })
      )
    );
  }

  addCart(id: number): Observable<any> {
    return this.http
      .post(`${this.base}/carrito/${this.token}`, { id_producto: id }, { withCredentials: true })
      .pipe(
        tap(() => { this.refreshCartState(); this.dataChanged.next(); })
      );
  }

  updateCart(id: number, cantidad: number): Observable<any> {
    return this.http
      .patch(`${this.base}/carrito/${this.token}`, { id_producto: id, cantidad }, { withCredentials: true })
      .pipe(
        tap(() => { this.refreshCartState(); this.dataChanged.next(); })
      );
  }

  clearCart(): Observable<any> {
    return this.http
      .delete(`${this.base}/carrito/${this.token}`, { withCredentials: true })
      .pipe(
        tap(() => { this.refreshCartState(); this.dataChanged.next(); })
      );
  }

  checkout(data: any): Observable<any> {
    return this.http
      .post(`${this.base}/pedidos`, data, { withCredentials: true })
      .pipe(
        tap(() => { this.refreshCartState(); this.dataChanged.next(); })
      );
  }

  get(path: string): Observable<any> {
    return this.sync(
      this.http.get(`${this.base}/${path}`, { withCredentials: true })
    );
  }

  post(path: string, data: any): Observable<any> {
    return this.http
      .post(`${this.base}/${path}`, data, { withCredentials: true })
      .pipe(
        tap(() => {
          this.dataChanged.next();
          this.tick();
        })
      );
  }

  put(path: string, id: number, data: any): Observable<any> {
    return this.http
      .put(`${this.base}/${path}/${id}`, data, { withCredentials: true })
      .pipe(
        tap(() => {
          this.dataChanged.next();
          this.tick();
        })
      );
  }

  delete(path: string, id: number): Observable<any> {
    return this.http
      .delete(`${this.base}/${path}/${id}`, { withCredentials: true })
      .pipe(
        tap(() => {
          this.dataChanged.next();
          this.tick();
        })
      );
  }

  logout(): Observable<any> {
    return this.sync(
      this.http.post(`${this.base}/auth/logout`, {}, { withCredentials: true })
    );
  }

  login(data: any): Observable<any> {
    return this.sync(
      this.http.post(`${this.base}/auth/admin`, data, { withCredentials: true })
    );
  }

  loginClient(data: any): Observable<any> {
    return this.sync(
      this.http.post(`${this.base}/auth/cliente`, data, { withCredentials: true })
    );
  }

  registerClient(data: any): Observable<any> {
    return this.sync(
      this.http.post(`${this.base}/auth/registro-cliente`, data, { withCredentials: true })
    );
  }
}