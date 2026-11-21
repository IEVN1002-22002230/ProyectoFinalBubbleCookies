
import { Component } from '@angular/core';
import { ApiService } from '../../services/api.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-login-admin',
  standalone: false,
  templateUrl: './login-admin.html',
  styleUrl: './login-admin.css'
})
export class LoginAdmin {

  correo = '';
  password = '';
  error = '';

  constructor(
    private api: ApiService,
    private router: Router
  ) {}

  submit() {
    this.api.login({
      correo: this.correo,
      password: this.password
    }).subscribe({
      next: r => {
        localStorage.setItem(
          'bubblecookies-user',
          JSON.stringify(r.usuario)
        );

        const role = r.usuario?.rol;

        this.router.navigate([
          role === 'cocinero'
            ? '/cocina'
            : role === 'marketing'
              ? '/marketing-panel'
              : '/dashboard'
        ]);
      },
      error: e => {
        this.error = e.error?.mensaje ||
          'No fue posible iniciar sesión. Verifica tus datos.';
      }
    });
  }

}
