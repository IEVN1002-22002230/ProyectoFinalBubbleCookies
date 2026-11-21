import { Injectable } from '@angular/core';
import { CanActivate, ActivatedRouteSnapshot, Router, UrlTree } from '@angular/router';

@Injectable({ providedIn: 'root' })
export class RoleGuard implements CanActivate {
  constructor(private router: Router) {}
  canActivate(route: ActivatedRouteSnapshot): boolean | UrlTree {
    const raw = localStorage.getItem('bubblecookies-user');
    if (!raw) return this.router.parseUrl('/login-admin');
    try {
      const user = JSON.parse(raw);
      const allowed: string[] = route.data['roles'] || [];
      if (allowed.includes(user.rol) || (user.rol === 'superadmin' || user.rol === 'administrador')) return true;
      if (user.rol === 'cocinero') return this.router.parseUrl('/cocina');
      if (user.rol === 'marketing') return this.router.parseUrl('/marketing-panel');
    } catch {}
    return this.router.parseUrl('/login-admin');
  }
}
