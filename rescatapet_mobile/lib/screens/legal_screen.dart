import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información Legal'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _seccion(
            'Términos y Condiciones de Uso',
            '''Al utilizar RescataPet EC, usted acepta los siguientes términos:

1. Propósito de la aplicación
RescataPet EC es una plataforma colaborativa destinada exclusivamente a facilitar el reporte, búsqueda y rescate de mascotas extraviadas, encontradas o en situación de adopción en el territorio ecuatoriano. No constituye un servicio de emergencias ni sustituye a las autoridades competentes.

2. Registro y veracidad de información
El usuario se compromete a proporcionar información veraz y actualizada en sus reportes. La publicación de información falsa, engañosa o con fines de estafa podrá resultar en la suspensión permanente de la cuenta y las acciones legales correspondientes.

3. Contenido generado por usuarios
Los reportes, fotografías y datos de contacto publicados son responsabilidad exclusiva de cada usuario. RescataPet EC actúa como intermediario tecnológico y no verifica la exactitud de cada publicación.

4. Uso aceptable
Queda prohibido utilizar la plataforma para:
  • Comercialización ilegal de animales
  • Publicación de contenido ofensivo, violento o que promueva el maltrato animal
  • Suplantación de identidad
  • Cualquier actividad contraria a las leyes vigentes del Ecuador

5. Limitación de responsabilidad
RescataPet EC no se hace responsable por transacciones, acuerdos o situaciones que ocurran entre usuarios fuera de la plataforma, incluyendo pero no limitado a adopciones, recompensas y encuentros presenciales.

6. Modificaciones
Nos reservamos el derecho de modificar estos términos en cualquier momento. El uso continuado de la aplicación constituye la aceptación de los términos vigentes.''',
            isDark,
          ),
          const SizedBox(height: 24),
          _seccion(
            'Política de Privacidad',
            '''RescataPet EC respeta y protege la privacidad de sus usuarios conforme a la Ley Orgánica de Protección de Datos Personales del Ecuador (LOPDP).

1. Datos que recopilamos
  • Nombre, correo electrónico y contraseña (cifrada) al crear una cuenta
  • Ubicación GPS (solo cuando el usuario lo autoriza explícitamente)
  • Fotografías seleccionadas por el usuario para adjuntar a reportes
  • Números de teléfono de contacto proporcionados voluntariamente

2. Uso de los datos
Sus datos se utilizan exclusivamente para:
  • Mostrar reportes de mascotas geolocalizados
  • Facilitar el contacto entre usuarios para fines de rescate
  • Calcular distancias y zonas de cobertura de alertas

3. Permisos del dispositivo
La aplicación solicita acceso a:
  • Cámara: para fotografiar mascotas encontradas o perdidas
  • Ubicación GPS: para georreferenciar reportes y calcular proximidad
  • Galería de fotos: para adjuntar imágenes existentes a los reportes

Cada permiso se solicita con una explicación previa (Just-in-Time Rationale) y puede ser revocado en cualquier momento desde los ajustes del dispositivo.

4. Almacenamiento y seguridad
Los datos se almacenan en servidores protegidos. Las contraseñas se cifran mediante algoritmos estándar de la industria. No vendemos, compartimos ni cedemos información personal a terceros.

5. Derechos del usuario
Conforme a la LOPDP, usted tiene derecho a:
  • Acceder a sus datos personales
  • Rectificar información inexacta
  • Solicitar la eliminación de su cuenta y datos asociados
  • Oponerse al tratamiento de sus datos

Para ejercer estos derechos, contacte a: soporte@rescatapet.ec''',
            isDark,
          ),
          const SizedBox(height: 24),
          _seccion(
            'Licencia y Créditos',
            '''RescataPet EC © 2026. Proyecto universitario desarrollado como trabajo de titulación.

Tecnologías utilizadas:
  • Flutter (Google) — Framework de interfaz móvil
  • Node.js — Servidor backend
  • SQLite + Prisma — Base de datos relacional
  • OpenStreetMap — Cartografía abierta

Las imágenes de mascotas provienen de los usuarios de la plataforma. Los íconos de Material Design son propiedad de Google bajo licencia Apache 2.0.

Este software se distribuye con fines académicos y sin garantía de ningún tipo.''',
            isDark,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _seccion(String titulo, String contenido, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
            color: isDark ? Colors.white : AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? const Color(0xFF404040) : const Color(0xFFE5E5E5),
            ),
          ),
          child: Text(
            contenido,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.6,
              color: isDark ? const Color(0xFFD4D4D4) : const Color(0xFF404040),
            ),
          ),
        ),
      ],
    );
  }
}
