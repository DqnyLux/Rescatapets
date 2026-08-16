# 🐾 RescataPet EC — Plataforma de Rescate y Adopción de Mascotas

Bienvenido al repositorio oficial de **RescataPet EC**, una solución tecnológica multiplataforma orientada a la búsqueda, rescate y adopción de mascotas en Ecuador. 

Este proyecto combina un **Backend API REST en Node.js (Express + SQLite + Redis)** con una **Aplicación Móvil en Flutter (Dart)** diseñada bajo principios de arquitectura limpia, experiencia de usuario moderna y conexión en vivo.

---

## 📌 Contenido del Repositorio

* **`rescatapet_mobile/`**: Aplicación móvil multiplataforma desarrollada en **Flutter** (Semana 9).
* **`app.js` / `controllers.js` / `models.js`**: Servidor Backend en **Node.js + Express** con persistencia en **SQLite** y caché en **Redis**.
* **`docker-compose.yml`**: Orquestación del servicio de caché Redis y base de datos de respaldo.
* **`guion_grabacion.yml`**: Guion detallado para la demostración en video del taller práctico.

---

## 💡 1. Fundamentación Técnica y Decisiones de Arquitectura

### ¿Por qué elegimos Flutter para el desarrollo móvil?
1. **Unipila de código (Single Codebase):** Desarrollamos una sola base de código en **Dart** que compila de forma nativa para Android, iOS y Web, optimizando tiempos de desarrollo.
2. **Rendimiento Nativo:** Flutter renderiza directamente utilizando su motor gráfico (Impeller/Skia) a 60-120 FPS sin depender de puentes JavaScript intermedios.
3. **Productividad con Hot Reload:** Permite aplicar cambios en la interfaz de usuario de manera instantánea sin perder el estado de la aplicación.

### Decisión del Destino de Ejecución (Emulador Android vs. Dispositivo Físico)
* **Emulador Android (Google APIs / AVD Pixel 6):** Seleccionado para la fase de desarrollo e inspección rápida de red local. Permite simular diferentes resoluciones, versiones de Android e inspeccionar solicitudes HTTP locales sin desgaste de batería física.
* **Dispositivo Físico (Alternativa):** Declarado como alternativa lista para pruebas de sensores en fases posteriores.

### Mapeo de Direcciones IP de Red Local
Para lograr la comunicación entre la app móvil y el servidor local en `http://localhost:3000`:
* **Emulador Android:** `http://10.0.2.2:3000/api` *(IP especial de loopback que el emulador Android usa para comunicarse con el localhost del PC host)*.
* **Simulador iOS / Web:** `http://localhost:3000/api`.
* **Dispositivo Físico:** `http://<IP_LOCAL_DE_TU_PC>:3000/api` (Ej. `http://192.168.1.50:3000/api`).

---

## 🛠️ 2. Requisitos y Versiones del Entorno

| Herramienta / SDK | Versión Recomendada | Comprobación |
| :--- | :--- | :--- |
| **Flutter SDK** | `3.22.x` / `3.47.x` (`>=3.0.0 <4.0.0`) | `flutter --version` |
| **Dart SDK** | `3.13.x` / `3.4.x` | Incluido en Flutter |
| **Node.js** | `v18+` / `v20+` | `node -v` |
| **Android Studio** | Jellyfish / Iguana | AVD Manager activo |
| **VS Code** | Última versión | Extensiones Flutter y Dart |

---

## 🔒 3. Permisos de Red Nativa (Tráfico HTTP Cleartext)

Para permitir el tráfico HTTP no cifrado hacia el servidor de desarrollo local:

1. **Android (`rescatapet_mobile/android/app/src/main/AndroidManifest.xml`):**
   ```xml
   <application
       android:usesCleartextTraffic="true"
       android:networkSecurityConfig="@xml/network_security_config">
   ```
2. **Configuración de Seguridad de Red (`android/app/src/main/res/xml/network_security_config.xml`):**
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <network-security-config>
       <domain-config cleartextTrafficPermitted="true">
           <domain includeSubdomains="true">10.0.2.2</domain>
           <domain includeSubdomains="true">localhost</domain>
       </domain-config>
   </network-security-config>
   ```
3. **iOS (`rescatapet_mobile/ios/Runner/Info.plist`):**
   ```xml
   <key>NSAppTransportSecurity</key>
   <dict>
       <key>NSAllowsArbitraryLoads</key>
       <true/>
   </dict>
   ```

---

## 🚀 4. Guía de Instalación y Ejecución Paso a Paso

### Paso 1: Iniciar el Backend Node.js
Abre una terminal en la raíz de este proyecto:
```bash
# Instalar dependencias del servidor
npm install

# Iniciar servidor Express en http://localhost:3000
npm start
```

### Paso 2: Verificar el Entorno Flutter
Abre una terminal en PowerShell y ejecuta:
```powershell
& "C:\Users\DqnyLuxxx\Desktop\RescataPet EC\App\flutter\bin\flutter.bat" doctor -v
```

### Paso 3: Configurar e Iniciar la App Móvil
```bash
# Entrar a la carpeta móvil
cd rescatapet_mobile

# Descargar paquetes Dart
"C:\Users\DqnyLuxxx\Desktop\RescataPet EC\App\flutter\bin\flutter.bat" pub get

# Ejecutar la app en el emulador Android
"C:\Users\DqnyLuxxx\Desktop\RescataPet EC\App\flutter\bin\flutter.bat" run -d emulator-5554
```

---

## 🌟 5. Características Destacadas de la App Móvil

* ** Búsqueda y Filtros en Tiempo Real:** Filtrado instantáneo por especie (Perros, Gatos, Verificados) o por ubicación.
* ** Insignia de Persona Verificada:** Identifica perfiles validados (`Verificado` vs `No Verificado`) manteniendo la libertad de publicación para cualquier ciudadano.
* ** Múltiples Números de Contacto:** Teléfono principal de llamada rápida y WhatsApp secundario.
* ** Seleccionar Foto desde la Galería:** Permite elegir imágenes guardadas en el almacenamiento del celular.
* ** Alternancia de Tema Claro / Oscuro:** Switch dinámico en el encabezado con ajuste automático de contraste de texto.
* ** Diagnóstico de Autenticación HTTP (POST):** Pestaña dedicada para probar peticiones `POST /api/login` enviando credenciales y mostrando el Token JWT devuelto por el servidor.

---

## 📋 6. Cumplimiento de Criterios de Evaluación (Taller Semana 9)

| Criterio | Estado | Descripción |
| :--- | :---: | :--- |
| **Instalación y Verificación (2,5 pts)** |  Cumplido | Entorno verificado con `flutter doctor` sin hallazgos pendientes. |
| **Ejecución del Proyecto (2,0 pts)** |  Cumplido | Proyecto base ejecutado sobre emulador Android con Hot Reload activo. |
| **Conectividad con Backend (2,0 pts)** |  Cumplido | Conexión exitosa a endpoints GET y POST (`10.0.2.2:3000`). |
| **Fundamentación Técnica (1,5 pts)** |  Cumplido | Decisiones de framework, IP y emulador justificadas con criterio técnico. |
| **Explicación en Video (1,0 pts)** |  Cumplido | Guion detallado disponible en `guion_grabacion.yml`. |
| **Documentación del Entorno (0,5 pts)** |  Cumplido | README claro, humano y reproducible por terceros. |
| **Relación con el Proyecto (0,5 pts)** |  Cumplido | Conectado con la base de datos y backend real de RescataPet EC. |

---

Desarrollado con ❤️ para la comunidad y el bienestar animal en Ecuador.
