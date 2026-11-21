
import { Component } from '@angular/core';
import { NavigationEnd, Router } from '@angular/router';
import { filter } from 'rxjs';
import { ApiService } from './services/api.service';
import { initFlowbite } from 'flowbite';

@Component({
  selector: 'app-root',
  standalone: false,
  templateUrl: './app.html',
  styleUrl: './app.css'
})
export class App {

  path = '';
  pageTitle = 'Dashboard general';
  cartCount = 0;
  user: any = this.readUser();
  customer: any = this.readCustomer();

  constructor(
    private router: Router,
    private api: ApiService
  ) {
    this.router.events
      .pipe(filter(e => e instanceof NavigationEnd))
      .subscribe(() => {
        this.path = this.router.url.split(/[?#]/)[0];
        this.pageTitle = this.titles[this.path] || 'Panel administrativo';
        this.user = this.readUser();
        this.customer = this.readCustomer();
        this.refreshCart();

        requestAnimationFrame(() => initFlowbite());
      });

    this.api.cartChanged.subscribe(() => this.refreshCart());
    this.refreshCart();
  }

  titles: Record<string, string> = {
    '/dashboard': 'Dashboard general',
    '/materia-prima': 'Materia prima',
    '/productos-recetas': 'Productos y recetas',
    '/produccion': 'Producción',
    '/inventario-terminado': 'Producto terminado',
    '/proveedores-compras': 'Proveedores y compras',
    '/pedidos-ventas': 'Pedidos y ventas',
    '/gestion-clientes': 'Clientes',
    '/analitica-marketing': 'Marketing y analítica',
    '/cocina': 'Panel de cocina',
    '/marketing-panel': 'Panel de marketing'
  };

  get isAuth() {
    return this.path === '/login-admin' ||
           this.path === '/login-clientes';
  }

  get isCustomer() {
    return this.path === '/' ||
           this.path === '/catalogo' ||
           this.path === '/carrito' ||
           this.path === '/mis-pedidos';
  }

  get adminDestination() {
    return this.user
      ? this.roleHome[this.role] || '/login-admin'
      : '/login-admin';
  }

  private roleHome: Record<string, string> = {
    superadmin: '/dashboard',
    administrador: '/dashboard',
    cocinero: '/cocina',
    marketing: '/marketing-panel'
  };

  readUser() {
    try {
      return JSON.parse(
        localStorage.getItem('bubblecookies-user') || 'null'
      );
    } catch {
      return null;
    }
  }

  readCustomer() {
    try {
      return JSON.parse(localStorage.getItem('bubblecookies-customer') || 'null');
    } catch {
      return null;
    }
  }

  logoutCustomer() {
    this.api.logout().subscribe({
      complete: () => this.finishCustomerLogout(),
      error: () => this.finishCustomerLogout()
    });
  }

  private finishCustomerLogout() {
    localStorage.removeItem('bubblecookies-customer');
    this.customer = null;
    this.router.navigate(['/catalogo']);
  }

  get role() {
    return this.user?.rol || '';
  }

  logout() {
    this.api.logout().subscribe({
      complete: () => {
        localStorage.removeItem('bubblecookies-user');
        this.user = null;
        this.router.navigate(['/login-admin']);
      },
      error: () => {
        localStorage.removeItem('bubblecookies-user');
        this.user = null;
        this.router.navigate(['/login-admin']);
      }
    });
  }

  refreshCart() {
    this.api.getCart().subscribe({
      next: r => {
        this.cartCount = r.cantidad_total || 0;
      },
      error: () => {
        this.cartCount = 0;
      }
    });
  }

}
