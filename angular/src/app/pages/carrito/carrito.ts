import { Component, DestroyRef, inject, ChangeDetectorRef } from '@angular/core';
import { interval, merge } from 'rxjs';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { ApiService } from '../../services/api.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-carrito',
  standalone: false,
  templateUrl: './carrito.html',
  styleUrl: './carrito.css'
})
export class Carrito {
  private destroyRef = inject(DestroyRef);
  private cdr = inject(ChangeDetectorRef);

  cart: any = { items: [], total: 0, cantidad_total: 0 };
  message = '';
  showCheckout = false;
  loginRequired = false;
  submitting = false;
  order: any = {
    nombre_cliente: '',
    correo_cliente: '',
    telefono_cliente: '',
    direccion_entrega: '',
    mensaje_regalo: '',
    metodo_pago: 'efectivo'
  };
  tarjetaDemo: any = { titular: '', numero: '', vencimiento: '', cvv: '' };

  constructor(private api: ApiService, private router: Router) {
    const customer = this.getLoggedCustomer();
    if (customer) {
      this.order.nombre_cliente = [customer.nombre, customer.apellidos].filter(Boolean).join(' ');
      this.order.correo_cliente = customer.correo || '';
      this.order.telefono_cliente = customer.telefono || '';
    }

    merge(interval(5000), this.api.dataChanged, this.api.cartChanged)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(() => this.load());
    this.load();
  }

  /**
   * La sesión de cliente utilizada por el módulo de Login se guarda
   * en localStorage con la clave bubblecookies-customer.
   */
  private getLoggedCustomer(): any | null {
    try {
      const customer = JSON.parse(localStorage.getItem('bubblecookies-customer') || 'null');
      return customer && typeof customer === 'object' ? customer : null;
    } catch {
      return null;
    }
  }

  private isCustomerLoggedIn(): boolean {
    return !!this.getLoggedCustomer();
  }

  closeLoginRequired() {
    this.loginRequired = false;
  }

  goToCustomerLogin() {
    this.loginRequired = false;
    this.router.navigate(['/login-clientes'], { queryParams: { returnUrl: '/carrito' } });
  }

  load() {
    this.api.getCart().subscribe({
      next: r => {
        this.cart = r || { items: [], total: 0, cantidad_total: 0 };
        this.cdr.detectChanges();
      },
      error: () => this.cdr.detectChanges()
    });
  }

  openCheckout() {
    this.message = '';

    // No abrir el formulario de compra si no existe una sesión de cliente.
    if (!this.isCustomerLoggedIn()) {
      this.showCheckout = false;
      this.loginRequired = true;
      return;
    }

    this.loginRequired = false;
    this.showCheckout = true;
  }

  closeCheckout() {
    if (this.submitting) return;
    this.showCheckout = false;
  }

  imageFor(item: any): string {
    return item?.imagen || '/assets/bubblecookies/cookies/bubble-choco.png';
  }

  change(x: any, delta: number) {
    this.api.updateCart(x.id_producto, Math.max(0, Number(x.cantidad) + delta)).subscribe({
      next: () => this.load(),
      error: e => {
        this.message = e.error?.mensaje || 'No fue posible actualizar la cantidad.';
        this.cdr.detectChanges();
      }
    });
  }

  remove(x: any) {
    this.api.updateCart(x.id_producto, 0).subscribe({
      next: () => this.load(),
      error: e => {
        this.message = e.error?.mensaje || 'No fue posible retirar el producto.';
        this.cdr.detectChanges();
      }
    });
  }

  checkout() {
    // Segunda validación justo antes de llamar al endpoint de compra.
    // Así también se bloquea si la sesión se cerró con el modal abierto.
    if (!this.isCustomerLoggedIn()) {
      this.showCheckout = false;
      this.loginRequired = true;
      this.cdr.detectChanges();
      return;
    }

    if (this.submitting || !this.order.nombre_cliente.trim()) {
      this.message = 'Escribe el nombre de la persona que recibirá el pedido.';
      return;
    }
    if (this.order.metodo_pago === 'tarjeta') {
      const numero = String(this.tarjetaDemo.numero || '').replace(/\s/g, '');
      if (!this.tarjetaDemo.titular.trim() || !/^\d{13,19}$/.test(numero) || !/^\d{2}\/\d{2}$/.test(this.tarjetaDemo.vencimiento) || !/^\d{3,4}$/.test(this.tarjetaDemo.cvv)) {
        this.message = 'Completa los datos de la tarjeta de demostración. No se almacenarán ni se enviarán al servidor.';
        return;
      }
    }
    this.submitting = true;
    // Solo se envía el método de pago. Los datos simulados de tarjeta nunca salen del formulario.
    const payload = { ...this.order, metodo_pago: this.order.metodo_pago };
    this.api.checkout(payload).subscribe({
      next: r => {
        this.showCheckout = false;
        this.submitting = false;
        this.tarjetaDemo = { titular: '', numero: '', vencimiento: '', cvv: '' };
        this.router.navigate(['/gracias-compra'], { queryParams: { pedido: r.codigo_pedido || '' } });
        this.load();
        this.cdr.detectChanges();
      },
      error: e => {
        this.message = e.error?.mensaje || 'No se pudo crear el pedido.';
        this.submitting = false;
        this.cdr.detectChanges();
      }
    });
  }
}
