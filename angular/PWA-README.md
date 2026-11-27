# BubbleCookies — versión PWA

Se agregó soporte de Progressive Web App (PWA) al frontend Angular, conservando los módulos y estilos existentes.

## Cambios realizados
- `public/manifest.webmanifest`: nombre, colores, modo independiente, orientación e iconos de instalación.
- `public/sw.js`: service worker para guardar la estructura principal y recursos estáticos, con fallback de navegación sin conexión.
- `public/assets/icons/`: iconos 192×192 y 512×512 generados a partir del logotipo del proyecto.
- `src/index.html`: metadatos móviles, manifest y Apple Touch Icon.
- `src/main.ts`: registro del service worker en compilación de producción y contextos seguros.

**Importante:** las peticiones `/api/` no se almacenan en caché. La PWA no convierte automáticamente el backend Flask en un servicio offline; las operaciones que requieren base de datos necesitan que Flask y su base de datos estén disponibles.

## Ejecutar en desarrollo
En la carpeta `angular`:

```bash
npm install
npm start
```

El modo `ng serve` se usa para desarrollar y no registra el service worker, por lo que no mostrará el comportamiento instalable/offline completo.

## Probar la PWA
1. Genera la compilación de producción:

```bash
npm run build
```

2. Publica el contenido generado de `dist/angular/browser` en un servidor HTTPS (o prueba en `localhost`).
3. Abre la URL desde Chrome en Android.
4. En el menú del navegador elige **Instalar aplicación** o **Agregar a pantalla principal**.

En iPhone/iPad, abre la página con Safari, toca **Compartir** y selecciona **Agregar a pantalla de inicio**.

## GitHub
Puedes subir el proyecto con GitHub, pero para instalar la PWA el sitio publicado debe servirse por HTTPS. Si publicas Angular en GitHub Pages bajo una ruta de proyecto, verifica también que el backend Flask tenga una URL pública y que la configuración de API apunte a ese backend; `localhost` desde el celular apunta al propio celular, no a tu PC.
