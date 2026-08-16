# RescataPet EC - Aplicación Móvil (Taller Semana 9)

Este repositorio contiene la aplicación móvil oficial de **RescataPet EC** construida en **Flutter**, así como la configuración y prueba de conectividad con el backend local (Node.js + Express + SQLite/Redis) para el **Taller Práctico de la Semana 9**.

---

## 📋 1. Fundamentación Técnica

### ¿Por qué Flutter?
* **Unipila de Código:** Permite publicar en Android, iOS y Web compartiendo más del 90% del código fuente Dart.
* **Alto Rendimiento:** Renderizado nativo a 60-120 FPS mediante Impeller/Skia sin pasar por puentes JS lentos.
* **Productividad (Hot Reload):** Permite iterar en la UI y lógica en tiempo real sin recompilar toda la aplicación.

### Decisión de Destino de Ejecución (Emulador vs. Dispositivo Físico)
* **Emulador Android (Google APIs / AVD):** Seleccionado para la fase de desarrollo e inspección rápida de red local. Permite simular diferentes tamaños de pantalla y APIs de Android sin desgaste de batería física.
* **Dispositivo Físico (Alternativa):** Útil para probar sensores de cámara o ubicación en etapas posteriores.

### Mapeo de Direcciones de Red (IP Base)
Para comunicar la app móvil con el backend local en `http://localhost:3000`:
* **Emulador Android:** `http://10.0.2.2:3000/api` (Mapeo de la interfaz de loopback del host por el emulador de Android).
* **Simulador iOS / Web:** `http://localhost:3000/api`.
* **Dispositivo Físico:** `http://<IP_LOCAL_DE_TU_PC>:3000/api` (Ej. `192.168.1.50:3000`).

---

## 🛠️ 2. Requisitos y Versiones del Entorno

* **Flutter SDK:** `3.22.x` o superior (`>=3.0.0 <4.0.0`)
* **Dart SDK:** `3.4.x`
* **Node.js (Backend):** `v18+` / `v20+`
* **Android Studio:** Giraffe / Iguana / Jellyfish (con Android SDK Command-line Tools)
* **VS Code Extensiones:** Flutter, Dart, Awesome Flutter Snippets

---

## 🔒 3. Autorización de Tráfico HTTP (Cleartext Traffic)

Dado que en desarrollo la API opera bajo `http://` no cifrado:

1. **Android (`android/app/src/main/AndroidManifest.xml`):**
   ```xml
   <application
       android:usesCleartextTraffic="true"
       android:networkSecurityConfig="@xml/network_security_config">
   ```
2. **Android Security Config (`android/app/src/main/res/xml/network_security_config.xml`):**
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <network-security-config>
       <domain-config cleartextTrafficPermitted="true">
           <domain includeSubdomains="true">10.0.2.2</domain>
           <domain includeSubdomains="true">localhost</domain>
       </domain-config>
   </network-security-config>
   ```
3. **iOS (`ios/Runner/Info.plist`):**
   ```xml
   <key>NSAppTransportSecurity</key>
   <dict>
       <key>NSAllowsArbitraryLoads</key>
       <true/>
   </dict>
   ```

---

## 🏃 4. Pasos para Reproducir el Entorno

### Paso 1: Iniciar el Backend Node.js
```bash
cd Rescatapets
npm install
npm start
```
*Servidor corriendo en `http://localhost:3000`.*

### Paso 2: Configurar la App Móvil
```bash
cd ../rescatapet_mobile
flutter pub get
```

Asegúrate de tener el archivo `.env` en la raíz de `rescatapet_mobile/`:
```env
API_URL=http://10.0.2.2:3000/api
```

### Paso 3: Ejecutar Diagnóstico de Flutter
```bash
flutter doctor -v
```
*(Verificar que no existan errores pendientes en Android toolchain o VS Code).*

### Paso 4: Lanzar la Aplicación
```bash
flutter run
```

---

## 📱 5. Características de la Aplicación Móvil
1. **Pestaña Reportes Públicos:** Consume `GET /api/reportes/publicos` y muestra la lista de mascotas rescatadas/perdidas con indicador de estado y pull-to-refresh.
2. **Pestaña Prueba API Auth:** Consume `POST /api/login` (enviando `juan@test.com`) y muestra el token JWT devuelto por el servidor.
3. **Manejo de Errores:** Pantalla interactiva con botón "Reintentar" en caso de fallos de red.
