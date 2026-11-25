import { Component } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-login-clientes',
  standalone: false,
  templateUrl: './login-clientes.html',
  styleUrl: './login-clientes.css'
})
export class LoginClientes {
  correo = '';
  password = '';
  error = '';
  loading = false;

  showRegister = false;
  nombreRegistro = '';
  correoRegistro = '';
  telefonoRegistro = '';
  passwordRegistro = '';
  confirmarPassword = '';
  aceptaTerminos = false;
  registroError = '';
  registroLoading = false;

  private returnUrl = '/catalogo';
  constructor(private api: ApiService, private router: Router, route: ActivatedRoute) {
    const requested = route.snapshot.queryParamMap.get('returnUrl');
    if (requested && requested.startsWith('/') && !requested.startsWith('//')) this.returnUrl = requested;
  }

  submit() {
    this.error = '';
    if (!this.correo.trim() || !this.password) {
      this.error = 'Escribe tu correo y contraseña.';
      return;
    }
    this.loading = true;
    this.api.loginClient({ correo: this.correo, password: this.password }).subscribe({
      next: r => {
        localStorage.setItem('bubblecookies-customer', JSON.stringify(r.usuario));
        this.loading = false;
        this.router.navigateByUrl(this.returnUrl);
      },
      error: e => {
        this.loading = false;
        this.error = e.error?.mensaje || 'No fue posible iniciar sesión. Verifica tus datos.';
      }
    });
  }

  openRegister() {
    this.registroError = '';
    this.showRegister = true;
  }

  closeRegister() {
    this.showRegister = false;
    this.registroError = '';
  }

  register() {
    this.registroError = '';
    if (!this.aceptaTerminos) {
      this.registroError = 'Debes aceptar los términos de la demostración.';
      return;
    }
    if (this.passwordRegistro !== this.confirmarPassword) {
      this.registroError = 'Las contraseñas no coinciden.';
      return;
    }
    this.registroLoading = true;
    this.api.registerClient({
      nombre: this.nombreRegistro,
      correo: this.correoRegistro,
      telefono: this.telefonoRegistro,
      password: this.passwordRegistro
    }).subscribe({
      next: r => {
        localStorage.setItem('bubblecookies-customer', JSON.stringify(r.usuario));
        this.registroLoading = false;
        this.showRegister = false;
        this.router.navigateByUrl(this.returnUrl);
      },
      error: e => {
        this.registroLoading = false;
        this.registroError = e.error?.mensaje || 'No fue posible crear tu cuenta.';
      }
    });
  }
}
