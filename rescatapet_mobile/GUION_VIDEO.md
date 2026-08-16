# 🎬 Guion de Grabación y Paso a Paso para la Entrega (Semana 9)

**Proyecto:** RescataPet EC  
**Framework:** Flutter (Dart)  
**Backend:** Node.js + Express + SQLite / Redis  
**Duración orientativa:** 2:30 a 3:30 minutos.

---

## 📹 1. PREPARACIÓN ANTES DE GRABAR

1. **Ventanas que debes tener abiertas:**
   * **Terminal 1:** Ejecutando el backend (`cd Rescatapets` -> `npm start`).
   * **VS Code:** Mostrando el proyecto `Rescatapets/rescatapet_mobile` con la terminal abierta.
   * **Emulador Android Studio:** Funcionando con la app **RescataPet EC** abierta.
2. **Software de grabación:** OBS Studio, Camtasia, Loom, Snipping Tool de Windows (Win + Shift + R), etc.

---

## 🗣️ 2. GUION PASO A PASO DURANTE EL VIDEO

### ⏱️ 0:00 - 0:30 | Presentación y Justificación Técnica
* **Qué mostrar:** Tu rostro (opcional o voz) y la pantalla de VS Code.
* **Qué decir:**
  > *"Hola, mi nombre es [Tu Nombre] y presento el taller práctico de la Semana 9 para el proyecto integrador **RescataPet EC**. Elegimos **Flutter** como framework móvil multiplataforma por su arquitectura unipila Dart, excelente rendimiento nativo y velocidad de iteración con Hot Reload. Seleccionamos el **Emulador Android** como destino para inspeccionar el tráfico de red local de forma ágil en desarrollo."*

---

### ⏱️ 0:30 - 1:00 | Diagnóstico de Entorno (`flutter doctor`)
* **Qué hacer:** En la terminal de VS Code, ejecuta el comando:
  ```bash
  "C:\Users\DqnyLuxxx\Desktop\RescataPet EC\App\flutter\bin\flutter.bat" doctor -v
  ```
* **Qué mostrar:** Muestra la salida en la terminal con los vistos verdes en Flutter SDK, Android Toolchain y VS Code.
* **Qué decir:**
  > *"Ejecutamos `flutter doctor -v` para comprobar que las variables de entorno, la cadena de herramientas de Android SDK y nuestro editor estén completamente verificados y sin hallazgos pendientes."*

---

### ⏱️ 1:00 - 1:45 | Permisos de Red Nativa y Variables de Entorno
* **Qué hacer:** En VS Code abre los archivos: `.env`, `AndroidManifest.xml` e `Info.plist`.
* **Qué decir:**
  > *"Para la conectividad local definimos la variable `API_URL` en el archivo `.env` apuntando a `http://10.0.2.2:3000/api`, que es la dirección de loopback que conecta el emulador Android con nuestra máquina host. Autorizamos el tráfico HTTP no cifrado de forma acotada habilitando `usesCleartextTraffic="true"` y la configuración de seguridad de red en Android, así como `NSAppTransportSecurity` en iOS."*

---

### ⏱️ 1:45 - 2:45 | Demostración en Vivo de Conectividad y Recarga en Caliente (Hot Reload)
* **Qué hacer:**
  1. Muestra el emulador con la lista de mascotas rescatadas cargadas desde la API `GET /api/reportes/publicos`.
  2. Haz clic en la pestaña **"Diagnóstico API"**, presiona **"Ejecutar Petición POST (Login API)"** y muestra en pantalla la recepción del **Token JWT**.
  3. Muestra el botón de **Switch Modo Oscuro/Claro** en el AppBar comprobando la legibilidad de los textos en ambos temas.
  4. Presiona el botón flotante **"Reportar Mascota"** y muestra la opción de cargar fotos desde la **Galería del Teléfono**.
  5. **Demostración de Hot Reload:** En la consola de Flutter presiona la tecla `r` para mostrar la recarga instantánea.
* **Qué decir:**
  > *"Como observamos, la aplicación realiza solicitudes HTTP exitosas a nuestro backend local. En la pestaña de diagnóstico ejecutamos una petición POST a `/api/login` recibiendo el Token JWT devuelto por el servidor. La interfaz cuenta con temas Claro y Oscuro con contraste ajustado, galería para subir fotos de mascotas y la recarga en caliente funciona en tiempo real."*

---

### ⏱️ 2:45 - 3:15 | Limitaciones y Conclusión
* **Qué decir:**
  > *"Como limitación identificada durante el desarrollo, la resolución de direcciones IP varía según el destino (10.0.2.2 para emuladores Android vs localhost para iOS/Web o IP privada para celulares físicos), requiriendo acotar la autorización de tráfico cleartext antes de cualquier entorno de producción. Con esto concluimos el taller de la Semana 9."*

---

## 📌 3. LO QUE DEBES ENVIAR EN MOODLE
1. **Enlace al Video:** (YouTube unlisted, Google Drive público o Loom).
2. **Enlace al Repositorio de GitHub:** `https://github.com/DqnyLux/Rescatapets.git`
