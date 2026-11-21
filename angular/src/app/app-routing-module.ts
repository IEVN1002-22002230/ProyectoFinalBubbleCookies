import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { LoginAdmin } from './pages/login-admin/login-admin';
import { LoginClientes } from './pages/login-clientes/login-clientes';
import { MisPedidos } from './pages/mis-pedidos/mis-pedidos';
import { Dashboard } from './pages/dashboard/dashboard';
import { MateriaPrima } from './pages/materia-prima/materia-prima';
import { ProductosRecetas } from './pages/productos-recetas/productos-recetas';
import { Produccion } from './pages/produccion/produccion';
import { InventarioTerminado } from './pages/inventario-terminado/inventario-terminado';
import { Catalogo } from './pages/catalogo/catalogo';
import { Carrito } from './pages/carrito/carrito';
import { PedidosVentas } from './pages/pedidos-ventas/pedidos-ventas';
import { GestionClientes } from './pages/gestion-clientes/gestion-clientes';
import { AnaliticaMarketing } from './pages/analitica-marketing/analitica-marketing';
import { ProveedoresCompras } from './pages/proveedores-compras/proveedores-compras';
import { Cocina } from './pages/cocina/cocina';
import { MarketingPanel } from './pages/marketing-panel/marketing-panel';
import { RoleGuard } from './guards/role.guard';

const routes: Routes = [
  { path: '', redirectTo: 'catalogo', pathMatch: 'full' },
  { path: 'login-admin', component: LoginAdmin },
  { path: 'login-clientes', component: LoginClientes },
  { path: 'dashboard', component: Dashboard, canActivate:[RoleGuard], data:{roles:['superadmin','administrador']} },
  { path: 'cocina', component: Cocina, canActivate:[RoleGuard], data:{roles:['cocinero']} },
  { path: 'marketing-panel', component: MarketingPanel, canActivate:[RoleGuard], data:{roles:['marketing']} },
  { path: 'materia-prima', component: MateriaPrima, canActivate:[RoleGuard], data:{roles:['superadmin','administrador','cocinero']} },
  { path: 'productos-recetas', component: ProductosRecetas, canActivate:[RoleGuard], data:{roles:['superadmin','administrador','cocinero']} },
  { path: 'produccion', component: Produccion, canActivate:[RoleGuard], data:{roles:['superadmin','administrador','cocinero']} },
  { path: 'inventario-terminado', component: InventarioTerminado, canActivate:[RoleGuard], data:{roles:['superadmin','administrador','cocinero']} },
  { path: 'catalogo', component: Catalogo },
  { path: 'carrito', component: Carrito },
  { path: 'mis-pedidos', component: MisPedidos },
  { path: 'pedidos-ventas', component: PedidosVentas, canActivate:[RoleGuard], data:{roles:['superadmin','administrador']} },
  { path: 'gestion-clientes', component: GestionClientes, canActivate:[RoleGuard], data:{roles:['superadmin','administrador']} },
  { path: 'analitica-marketing', component: AnaliticaMarketing, canActivate:[RoleGuard], data:{roles:['superadmin','administrador','marketing']} },
  { path: 'proveedores-compras', component: ProveedoresCompras, canActivate:[RoleGuard], data:{roles:['superadmin','administrador']} },
  { path: '**', redirectTo: 'login-admin' }
];
@NgModule({imports:[RouterModule.forRoot(routes)],exports:[RouterModule]})
export class AppRoutingModule {}
