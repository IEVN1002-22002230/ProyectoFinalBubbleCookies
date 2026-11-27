import { platformBrowser } from '@angular/platform-browser';
import { isDevMode } from '@angular/core';
import { AppModule } from './app/app-module';

platformBrowser().bootstrapModule(AppModule)
  .then(() => {
    // El service worker solo se registra en producción y en navegadores compatibles.
    if ('serviceWorker' in navigator && window.isSecureContext && !isDevMode()) {
      navigator.serviceWorker.register('./sw.js').catch(error =>
        console.error('No se pudo registrar el service worker de BubbleCookies:', error)
      );
    }
  })
  .catch(err => console.error(err));
