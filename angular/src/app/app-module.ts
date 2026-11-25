import { NgModule, provideBrowserGlobalErrorListeners } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { provideHttpClient } from '@angular/common/http';
import { AppRoutingModule } from './app-routing-module';
import { App } from './app';
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
import { GraciasCompra } from './pages/gracias-compra/gracias-compra';

@NgModule({declarations:[App,
LoginAdmin,
LoginClientes,
MisPedidos,
Dashboard,
MateriaPrima,
ProductosRecetas,
Produccion,
InventarioTerminado,
Catalogo,
Carrito,
PedidosVentas,
GestionClientes,
AnaliticaMarketing,
ProveedoresCompras,
Cocina,
MarketingPanel,GraciasCompra],imports:[BrowserModule,CommonModule,FormsModule,AppRoutingModule],providers:[provideBrowserGlobalErrorListeners(),provideHttpClient()],bootstrap:[App]})
export class AppModule {}
