import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/geografia.dart';
import '../theme/app_theme.dart';

enum EstadoPermisoNativo {
  concedido,
  denegado,
  denegadoPermanente,
  servicioDesactivado,
  error,
}

class DireccionGeocodificada {
  final double latitud;
  final double longitud;
  final String calle;
  final String barrio;
  final String cantonOCiudad;
  final String provincia;
  final String pais;
  final String direccionCompleta;
  final CantonMatch cantonCatalogo;

  const DireccionGeocodificada({
    required this.latitud,
    required this.longitud,
    required this.calle,
    required this.barrio,
    required this.cantonOCiudad,
    required this.provincia,
    required this.pais,
    required this.direccionCompleta,
    required this.cantonCatalogo,
  });
}

class ResultadoUbicacion {
  final EstadoPermisoNativo estado;
  final Position? posicion;
  final DireccionGeocodificada? direccion;
  final String mensaje;

  const ResultadoUbicacion({
    required this.estado,
    this.posicion,
    this.direccion,
    required this.mensaje,
  });
}

class NativeLocationService {
  /// Solicita y obtiene la ubicación GPS en tiempo real gestionando los 4 estados
  /// precedido por un diálogo de explicación (Rationale Just-in-Time)
  static Future<ResultadoUbicacion> obtenerPosicionActual(
    BuildContext context, {
    bool mostrarDialogoPrevio = true,
  }) async {
    // 1. Verificar si los servicios de localización (hardware GPS) están encendidos
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        _mostrarDialogoServicioDesactivado(context);
      }
      return const ResultadoUbicacion(
        estado: EstadoPermisoNativo.servicioDesactivado,
        mensaje: 'El GPS del dispositivo está desactivado.',
      );
    }

    // 2. Verificar estado actual del permiso
    LocationPermission permission = await Geolocator.checkPermission();

    // Si ya está denegado permanentemente, guiar a ajustes
    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        _mostrarDialogoDenegadoPermanente(
          context,
          titulo: 'Permiso de Ubicación Necesario',
          descripcion:
              'El permiso de ubicación fue denegado permanentemente. Para detectar tu posición GPS precisa y calcular distancias en tiempo real, actívalo en los ajustes del sistema.',
        );
      }
      return const ResultadoUbicacion(
        estado: EstadoPermisoNativo.denegadoPermanente,
        mensaje: 'Permiso denegado permanentemente en el sistema.',
      );
    }

    // 3. Si aún no está concedido, mostrar diálogo explicativo previo (Rationale Just-in-Time)
    if (permission == LocationPermission.denied && mostrarDialogoPrevio) {
      if (!context.mounted) {
        return const ResultadoUbicacion(
          estado: EstadoPermisoNativo.error,
          mensaje: 'Contexto no disponible.',
        );
      }
      final aceptar = await _mostrarDialogoExplicacion(
        context,
        titulo: 'Acceso a tu Ubicación GPS',
        descripcion:
            'RescataPet EC utiliza tu ubicación en tiempo real exclusivamente para calcular la distancia a mascotas extraviadas y alertas SOS cercanas a ti, así como para georreferenciar incidentes de rescate.',
        icono: Icons.my_location_rounded,
      );

      if (aceptar != true) {
        return const ResultadoUbicacion(
          estado: EstadoPermisoNativo.denegado,
          mensaje: 'El usuario declinó la explicación de ubicación.',
        );
      }

      // Solicitar permiso nativo al sistema operativo
      permission = await Geolocator.requestPermission();
    }

    // 4. Evaluar respuesta del sistema
    if (permission == LocationPermission.denied) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ubicación denegada. Puedes seleccionar tu cantón manualmente o tocar en el mapa.',
            ),
            backgroundColor: AppTheme.alertCoral,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return const ResultadoUbicacion(
        estado: EstadoPermisoNativo.denegado,
        mensaje: 'Permiso de ubicación denegado.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        _mostrarDialogoDenegadoPermanente(
          context,
          titulo: 'Permiso Denegado Permanentemente',
          descripcion:
              'Has marcado "No volver a preguntar". Para activar el radar GPS, abre los ajustes del sistema.',
        );
      }
      return const ResultadoUbicacion(
        estado: EstadoPermisoNativo.denegadoPermanente,
        mensaje: 'Permiso de ubicación denegado permanentemente.',
      );
    }

    // 5. Permiso Concedido: Obtener coordenadas precisas con máxima exactitud
    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 12),
        ),
      );
    } catch (_) {
      position = await Geolocator.getLastKnownPosition();
    }

    if (position == null) {
      return const ResultadoUbicacion(
        estado: EstadoPermisoNativo.error,
        mensaje: 'No se pudo obtener la posición del satélite GPS.',
      );
    }

    // 6. Geocodificación Inversa: Traducir Lat/Lng a nombres exactos de calle, barrio, cantón
    final direccion = await resolverDireccionExacta(position.latitude, position.longitude);

    return ResultadoUbicacion(
      estado: EstadoPermisoNativo.concedido,
      posicion: position,
      direccion: direccion,
      mensaje: 'Ubicación GPS y dirección resuelta con éxito.',
    );
  }

  /// Geocodificación inversa de coordenadas a nombres legibles (Calle, Barrio, Ciudad/Cantón)
  static Future<DireccionGeocodificada> resolverDireccionExacta(double lat, double lng) async {
    final cantonCercano = CatalogoGeografico.encontrarCantonMasCercano(lat, lng);
    String calle = '';
    String barrio = '';
    String canton = cantonCercano.canton.nombre;
    String provincia = cantonCercano.provincia.nombre;
    String pais = cantonCercano.pais.nombre;

    try {
      final geocoding = Geocoding();
      final List<Placemark> placemarks = await geocoding
          .placemarkFromCoordinates(lat, lng)
          .timeout(const Duration(seconds: 4));

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        calle = [p.street, p.name].where((s) => s != null && s.isNotEmpty).toSet().join(' ');
        barrio = p.subLocality ?? p.subAdministrativeArea ?? '';
        if (p.locality != null && p.locality!.isNotEmpty) {
          canton = p.locality!;
        }
        if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty) {
          provincia = p.administrativeArea!;
        }
        if (p.country != null && p.country!.isNotEmpty) {
          pais = p.country!;
        }
      }
    } catch (_) {
      // Usar datos del catálogo si la geocodificación en línea falla o no tiene internet
    }

    final partes = <String>[];
    if (calle.isNotEmpty && calle != canton) partes.add(calle);
    if (barrio.isNotEmpty && barrio != canton && barrio != calle) partes.add(barrio);
    partes.add(canton);
    partes.add(provincia);
    partes.add(pais);

    return DireccionGeocodificada(
      latitud: lat,
      longitud: lng,
      calle: calle,
      barrio: barrio,
      cantonOCiudad: canton,
      provincia: provincia,
      pais: pais,
      direccionCompleta: partes.join(', '),
      cantonCatalogo: cantonCercano,
    );
  }

  // ==========================================================
  // DIÁLOGOS DE GESTIÓN DE PERMISOS
  // ==========================================================
  static Future<bool?> _mostrarDialogoExplicacion(
    BuildContext context, {
    required String titulo,
    required String descripcion,
    required IconData icono,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: isDark ? AppTheme.cardDark : AppTheme.cardLight,
          icon: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, color: AppTheme.primaryLight, size: 36),
          ),
          title: Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Text(
            descripcion,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                'Ahora no',
                style: TextStyle(
                  color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Permitir'),
            ),
          ],
        );
      },
    );
  }

  static void _mostrarDialogoServicioDesactivado(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          icon: const Icon(Icons.location_off_rounded, color: AppTheme.alertCoral, size: 40),
          title: const Text('Servicio GPS Desactivado', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            'El sensor de ubicación de tu dispositivo está apagado. Por favor enciéndelo para obtener coordenadas en tiempo real.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Geolocator.openLocationSettings();
              },
              child: const Text('Abrir Ajustes GPS'),
            ),
          ],
        );
      },
    );
  }

  static void _mostrarDialogoDenegadoPermanente(
    BuildContext context, {
    required String titulo,
    required String descripcion,
  }) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          icon: const Icon(Icons.settings_suggest_rounded, color: AppTheme.accent, size: 40),
          title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(descripcion, textAlign: TextAlign.center),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cerrar'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                Geolocator.openAppSettings();
              },
              icon: const Icon(Icons.settings_rounded, size: 18),
              label: const Text('Ir a Ajustes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}

class NativeMediaService {
  static final ImagePicker _picker = ImagePicker();

  /// Captura foto desde la cámara o galería con verificación estricta de permisos nativos y Rationale
  static Future<XFile?> seleccionarOtomarFoto(
    BuildContext context, {
    required ImageSource source,
  }) async {
    // 1. Verificar y justificar el permiso nativo según la fuente elegida
    if (source == ImageSource.camera) {
      final camStatus = await Permission.camera.status;
      if (camStatus.isPermanentlyDenied) {
        if (context.mounted) {
          NativeLocationService._mostrarDialogoDenegadoPermanente(
            context,
            titulo: 'Permiso de Cámara Requerido',
            descripcion:
                'Para tomar fotografías de rescate directamente con tu lente, activa el permiso de cámara en los ajustes de la aplicación.',
          );
        }
        return null;
      }

      if (!camStatus.isGranted) {
        if (!context.mounted) return null;
        final aceptar = await NativeLocationService._mostrarDialogoExplicacion(
          context,
          titulo: 'Permiso de Cámara',
          descripcion:
              'RescataPet EC necesita acceder a la cámara de tu dispositivo para capturar fotos nítidas de la mascota perdida, encontrada o en adopción.',
          icono: Icons.camera_alt_rounded,
        );

        if (aceptar != true) return null;

        final nuevoEstado = await Permission.camera.request();
        if (!nuevoEstado.isGranted) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permiso de cámara no concedido.'),
                backgroundColor: AppTheme.alertCoral,
              ),
            );
          }
          return null;
        }
      }
    } else {
      // Permiso de Galería de Fotos / Almacenamiento multimedia
      Permission photoPerm = Permission.photos;
      if (Platform.isAndroid) {
        // En Android 13+ (SDK 33+) se usa photos/media images, en anteriores storage
        final statusPhotos = await Permission.photos.status;
        final statusStorage = await Permission.storage.status;
        if (!statusPhotos.isGranted && !statusStorage.isGranted) {
          if (!context.mounted) return null;
          final aceptar = await NativeLocationService._mostrarDialogoExplicacion(
            context,
            titulo: 'Acceso a tu Galería de Fotos',
            descripcion:
                'RescataPet EC requiere permiso para acceder a tus fotos con el fin de seleccionar imágenes de la mascota desde tu galería y adjuntarlas a la ficha de rescate.',
            icono: Icons.photo_library_rounded,
          );

          if (aceptar != true) return null;

          final resPhotos = await Permission.photos.request();
          if (!resPhotos.isGranted) {
            await Permission.storage.request();
          }
        }
      } else {
        final status = await photoPerm.status;
        if (!status.isGranted) {
          if (!context.mounted) return null;
          final aceptar = await NativeLocationService._mostrarDialogoExplicacion(
            context,
            titulo: 'Acceso a tus Fotos',
            descripcion:
                'Permite a RescataPet EC cargar fotos de tu galería para adjuntarlas a los reportes de mascotas.',
            icono: Icons.photo_library_rounded,
          );
          if (aceptar != true) return null;
          await photoPerm.request();
        }
      }
    }

    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      return file;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo acceder a las imágenes: $e'),
            backgroundColor: AppTheme.alertCoral,
          ),
        );
      }
      return null;
    }
  }

  /// Despliega el menú modal de selección de origen (Cámara vs Galería)
  static Future<XFile?> mostrarOpcionesImagen(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet<XFile?>(
      context: context,
      backgroundColor: isDark ? AppTheme.cardDark : AppTheme.cardLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Adjuntar Fotografía Real',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Una foto real ayuda a la comunidad a identificar a la mascota rápidamente.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          final file = await seleccionarOtomarFoto(
                            context,
                            source: ImageSource.camera,
                          );
                          if (file != null && context.mounted) {
                            Navigator.of(context, rootNavigator: false).pop(file);
                          }
                        },
                        icon: const Icon(Icons.camera_alt_rounded, color: AppTheme.primary),
                        label: const Text('Tomar Foto'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          final file = await seleccionarOtomarFoto(
                            context,
                            source: ImageSource.gallery,
                          );
                          if (file != null && context.mounted) {
                            Navigator.of(context, rootNavigator: false).pop(file);
                          }
                        },
                        icon: const Icon(Icons.photo_library_rounded, color: Colors.white),
                        label: const Text('Abrir Galería'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
