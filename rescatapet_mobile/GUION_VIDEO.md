# Guion de Grabación - Demostración Taller Semana 9 (RescataPet EC)

**Duración recomendada:** 2 a 3 minutos.

---

### 1. Introducción (15 seg)
* **Acción:** Mostrar la pantalla completa con la terminal y VS Code.
* **Voz:** *"Hola, en este video presento la verificación y conexión del entorno móvil en Flutter para el proyecto RescataPet EC correspondiente a la Semana 9."*

### 2. Verificación del Entorno (30 seg)
* **Acción:** Ejecutar en terminal `flutter doctor`.
* **Voz:** *"Ejecutamos `flutter doctor` para comprobar que el SDK de Flutter, Android Toolchain y VS Code están correctamente configurados."*

### 3. Explicación de Variables de Entorno y Permisos (45 seg)
* **Acción:** Abrir `.env`, `AndroidManifest.xml` e `Info.plist`.
* **Voz:** *"Configuramos la URL base en el archivo `.env` apuntando a `10.0.2.2:3000` para emulador Android. Además, habilitamos `usesCleartextTraffic="true"` en AndroidManifest y `NSAppTransportSecurity` en iOS para autorizar peticiones HTTP no cifradas hacia nuestro backend local."*

### 4. Prueba de Conexión HTTP y Hot Reload (60 seg)
* **Acción:**
  1. Iniciar backend Node.js (`npm start`).
  2. Correr la app móvil (`flutter run`).
  3. Mostrar la lista de reportes cargada desde la API (`/api/reportes/publicos`).
  4. Realizar un cambio de color en `home_screen.dart` y presionar `r` para demostrar **Hot Reload** instantáneo.
* **Voz:** *"Como vemos, la aplicación realiza la petición GET a la API local y renderiza los reportes públicos. Demostramos el funcionamiento del Hot Reload modificando el tema visual en tiempo real."*

### 5. Cierre y Limitaciones (15 seg)
* **Voz:** *"Como limitación identificada, el uso de HTTP local requiere mapear las IP según el entorno (10.0.2.2 vs localhost vs IP privada en dispositivos físicos). ¡Con esto concluimos la entrega del taller!"*
