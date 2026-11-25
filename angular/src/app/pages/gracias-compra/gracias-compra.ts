import { Component } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
@Component({ selector: 'app-gracias-compra', standalone: false, templateUrl: './gracias-compra.html', styleUrl: './gracias-compra.css' })
export class GraciasCompra {
  codigo = '';
  constructor(route: ActivatedRoute) { this.codigo = route.snapshot.queryParamMap.get('pedido') || ''; }
}
