# Capturas de pantalla

Estas imágenes son referenciadas por el README del proyecto. Mantén los nombres exactos.

| Archivo | Pantalla | Ruta en la app | Estado |
|---------|----------|----------------|--------|
| `menu.png` | Menú digital del cliente | `/` (público) | presente |
| `carrito.png` | Carrito con productos | `/cart` | presente |
| `recibo.png` | Recibo con QR de Nequi / Bre-B | `/checkout` o `/qr-view` | presente |
| `admin-dashboard.png` | Panel de control del admin | `/admin-dashboard` (login `admin`) | presente |
| `reportes-ventas.png` | Reportes y desempeño por mesero | `/admin-reports` (login `admin`) | presente |

Opcionales (agrega la línea correspondiente en el README si los tomas):

| Archivo | Pantalla | Ruta en la app |
|---------|----------|----------------|
| `login.png` | Inicio de sesión | `/login` |
| `kds.png` | Bandeja de cocina (KDS) | `/staff-dashboard` (login `staff`) |
| `admin-products.png` | Gestión de productos | `/admin-products` |
| `admin-debts.png` | Deudas externas | `/admin-debts` |
| `guardarropa.png` | Guardarropa / recibo de ticket | `/cloakroom-form`, `/cloakroom-receipt` |
| `ventas.png` | Ventas en tiempo real | `/sales` |
| `soporte.png` | Atención al cliente (PQRS) | `/customer-support` |
| `configuracion.png` | Configuración de Nequi / Bre-B | `/admin-settings` |

Notas:
- Esta carpeta **no** se empaqueta en el build de Flutter (`pubspec.yaml` solo incluye `assets/qr/` y `assets/logos/`), así que no infla el peso de la web.
- Para capturas limpias usa el modo claro/oscuro del navegador con zoom al 100% y una ventana de ~1280x800 para escritorio, o DevTools en modo móvil para las vistas de cliente.
- Asegúrate de que las capturas no muestren correos, contraseñas, teléfonos reales de clientes ni datos de pagos.
- No guardes aquí archivos ejecutables (`.exe`, `.dll`, `.bat`): el plan Spark de Firebase rechaza el deploy si los encuentra.
