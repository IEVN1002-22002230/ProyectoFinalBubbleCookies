# BubbleCookies — despliegue PWA en celular (GitHub Pages)

Este repositorio conserva el proyecto BubbleCookies existente. El alcance de esta entrega es publicar el frontend Angular y permitir instalarlo como PWA en un teléfono. No agrega módulos, no cambia pantallas ni modifica el diseño.

## 1. Subir a GitHub

1. Crea un repositorio en GitHub.
2. Sube el contenido de la carpeta `BUBBLECOOKIES` (debe quedar `angular/` y `flask/` en la raíz del repositorio).
3. La rama principal debe llamarse `main`.

## 2. Activar GitHub Pages

1. En GitHub abre el repositorio.
2. Entra a **Settings > Pages**.
3. En **Build and deployment**, selecciona **GitHub Actions**.
4. Guarda los cambios.

El archivo `.github/workflows/deploy-pwa.yml` compila Angular y publica automáticamente el frontend cada vez que haces `push` a `main`. También puedes ejecutarlo desde **Actions > Deploy BubbleCookies PWA to GitHub Pages > Run workflow**.

## 3. Abrir e instalar en el celular

Cuando el workflow termine correctamente:

1. Abre **Settings > Pages** o el último workflow para copiar la URL publicada.
2. Abre esa URL en el celular.
3. **Android (Chrome):** menú ⋮ > **Instalar aplicación** o **Agregar a pantalla principal**.
4. **iPhone (Safari):** botón **Compartir** > **Agregar a pantalla de inicio**.

La PWA se abre en una ventana independiente, con el nombre e iconos de BubbleCookies.

## 4. Qué funciona sin conexión

El Service Worker guarda la estructura principal y recursos estáticos que ya se hayan cargado. Si no hay internet, puede mostrar la aplicación almacenada. Las consultas, inicio de sesión, carrito, pedidos y demás operaciones que dependen de Flask/base de datos requieren conexión y un backend accesible.

## IMPORTANTE: conexión con Flask

GitHub Pages publica sitios estáticos; **no ejecuta Flask ni MySQL**. En el código actual hay servicios Angular que apuntan a `http://localhost:5000/api`. Esa dirección solo funciona en la computadora donde corre Flask; en un teléfono `localhost` significa el propio teléfono.

Por eso, esta publicación permite desplegar e instalar la interfaz PWA, pero para que los datos, el login, el carrito y los CRUD funcionen desde el celular también hay que publicar el backend Flask en un servidor y cambiar las URL `localhost:5000` por la URL HTTPS pública del backend. Ese cambio no se hizo para respetar el alcance de solo despliegue móvil.

## Actualizaciones

Después de subir cambios a la rama `main`, GitHub Actions volverá a compilar y publicar la PWA. Puede ser necesario cerrar y volver a abrir la aplicación instalada para recibir la versión nueva.
