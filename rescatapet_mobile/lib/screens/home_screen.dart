import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../models/geografia.dart';
import '../models/reporte.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
import '../services/native_services.dart';
import '../theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  late Future<List<Reporte>> _futureReportes;
  final List<Reporte> _reportesLocalesAdicionales = [];

  // Filtros y Búsqueda
  String _searchQuery = '';
  TipoAlerta? _filtroTipoAlerta; // null = Todos
  String _filtroEspecie = 'Todos';
  double _radioDistanciaKm = 50.0; // 50km por defecto (Todos)

  final TextEditingController _searchController = TextEditingController();

  // Ubicación actual del usuario (Simulada / GPS)
  final List<UbicacionReferencia> _ciudadesEcuador = const [
    UbicacionReferencia(
      nombre: 'Quito Norte - La Carolina',
      ciudad: 'Quito',
      latitud: -0.1807,
      longitud: -78.4842,
    ),
    UbicacionReferencia(
      nombre: 'Quito Centro - Plaza Grande',
      ciudad: 'Quito',
      latitud: -0.2201,
      longitud: -78.5123,
    ),
    UbicacionReferencia(
      nombre: 'Quito Sur - El Recreo',
      ciudad: 'Quito',
      latitud: -0.2483,
      longitud: -78.5218,
    ),
    UbicacionReferencia(
      nombre: 'Cumbayá / Tumbaco',
      ciudad: 'Quito',
      latitud: -0.2033,
      longitud: -78.4312,
    ),
    UbicacionReferencia(
      nombre: 'Guayaquil - Malecón 2000',
      ciudad: 'Guayaquil',
      latitud: -2.1894,
      longitud: -79.8891,
    ),
    UbicacionReferencia(
      nombre: 'Guayaquil - Samborondón',
      ciudad: 'Guayaquil',
      latitud: -2.1400,
      longitud: -79.8650,
    ),
    UbicacionReferencia(
      nombre: 'Cuenca - Parque Calderón',
      ciudad: 'Cuenca',
      latitud: -2.9001,
      longitud: -79.0059,
    ),
    UbicacionReferencia(
      nombre: 'Manta - El Murciélago',
      ciudad: 'Manta',
      latitud: -0.9500,
      longitud: -80.7333,
    ),
    UbicacionReferencia(
      nombre: 'Ambato - Ficoa',
      ciudad: 'Ambato',
      latitud: -1.2417,
      longitud: -78.6197,
    ),
  ];

  late UbicacionReferencia _ubicacionUsuario;

  @override
  void initState() {
    super.initState();
    _ubicacionUsuario = _ciudadesEcuador[0]; // Quito La Carolina por defecto
    _cargarReportes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _cargarReportes() {
    setState(() {
      _futureReportes = ApiService.fetchReportesPublicos();
    });
  }

  // ==========================================================
  // ==========================================================
  // SELECTOR DE UBICACIÓN ACTUAL DEL USUARIO CON MAPA Y RADIO
  // ==========================================================
  void _mostrarSelectorUbicacionUsuario() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    double tempLat = _ubicacionUsuario.latitud;
    double tempLng = _ubicacionUsuario.longitud;
    String tempNombre = _ubicacionUsuario.nombre;
    String tempCiudad = _ubicacionUsuario.ciudad;
    double tempRadio = _radioDistanciaKm;
    final mapController = MapController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.90,
              maxChildSize: 0.96,
              minChildSize: 0.60,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(22, 12, 22, 32),
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.radar_rounded, color: AppTheme.primaryLight, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Radio de Cobertura y GPS',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : AppTheme.textDark,
                                  ),
                                ),
                                Text(
                                  'Toca en el mapa o usa el GPS satelital nativo',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // MAPA INTERACTIVO CON CÍRCULO DE RADIO DINÁMICO
                      Container(
                        height: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            FlutterMap(
                              mapController: mapController,
                              options: MapOptions(
                                initialCenter: LatLng(tempLat, tempLng),
                                initialZoom: tempRadio <= 3 ? 14.0 : (tempRadio <= 10 ? 12.5 : 10.5),
                                onTap: (tapPosition, point) async {
                                  setModalState(() {
                                    tempLat = point.latitude;
                                    tempLng = point.longitude;
                                  });
                                  // Geocodificación inversa para nombre de calle/barrio/ciudad
                                  final dir = await NativeLocationService.resolverDireccionExacta(
                                    point.latitude,
                                    point.longitude,
                                  );
                                  setModalState(() {
                                    tempNombre = dir.barrio.isNotEmpty
                                        ? '${dir.cantonOCiudad} - ${dir.barrio}'
                                        : dir.cantonOCiudad;
                                    tempCiudad = dir.cantonOCiudad;
                                  });
                                },
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.rescatapet_mobile',
                                ),
                                CircleLayer(
                                  circles: [
                                    CircleMarker(
                                      point: LatLng(tempLat, tempLng),
                                      radius: (tempRadio * 1000).toDouble(),
                                      useRadiusInMeter: true,
                                      color: AppTheme.primary.withValues(alpha: 0.18),
                                      borderColor: AppTheme.primary,
                                      borderStrokeWidth: 2.0,
                                    ),
                                  ],
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(tempLat, tempLng),
                                      width: 44,
                                      height: 44,
                                      child: const Icon(
                                        Icons.location_on_rounded,
                                        color: AppTheme.alertCoral,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.75),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Radio: ${tempRadio.toInt()} km',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Información de Dirección Resuelta
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.pin_drop_rounded, color: AppTheme.primaryLight, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '$tempNombre (${tempLat.toStringAsFixed(3)}, ${tempLng.toStringAsFixed(3)})',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // SELECTOR DE RADIO EN KM
                      const Text(
                        'Ajustar Radio de Búsqueda:',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [1.0, 3.0, 5.0, 10.0, 50.0].map((r) {
                            final sel = tempRadio == r;
                            final lbl = r == 50.0 ? 'Todo el País (50 km+)' : '${r.toInt()} km';
                            return Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: ChoiceChip(
                                label: Text(lbl),
                                selected: sel,
                                onSelected: (_) {
                                  setModalState(() => tempRadio = r);
                                },
                                selectedColor: AppTheme.primary,
                                labelStyle: TextStyle(
                                  color: sel ? Colors.white : (isDark ? Colors.white70 : AppTheme.textDark),
                                  fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                                  fontSize: 12,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Botón Nativo GPS Satelital
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final res = await NativeLocationService.obtenerPosicionActual(context);
                            if (res.estado == EstadoPermisoNativo.concedido && res.posicion != null) {
                              final pos = res.posicion!;
                              final dir = res.direccion;
                              final nom = dir != null && dir.calle.isNotEmpty
                                  ? '${dir.cantonOCiudad}, ${dir.calle}'
                                  : 'GPS (${pos.latitude.toStringAsFixed(3)}, ${pos.longitude.toStringAsFixed(3)})';
                              setModalState(() {
                                tempLat = pos.latitude;
                                tempLng = pos.longitude;
                                tempNombre = nom;
                                tempCiudad = dir?.cantonOCiudad ?? 'Ecuador';
                              });
                              mapController.move(LatLng(pos.latitude, pos.longitude), 14.0);
                            }
                          },
                          icon: const Icon(Icons.gps_fixed_rounded, size: 18),
                          label: const Text(
                            'Autodetectar con GPS Satelital',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryLight,
                            side: const BorderSide(color: AppTheme.primaryLight, width: 1.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Botón Confirmar
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _ubicacionUsuario = UbicacionReferencia(
                                nombre: tempNombre,
                                ciudad: tempCiudad,
                                latitud: tempLat,
                                longitud: tempLng,
                              );
                              _radioDistanciaKm = tempRadio;
                            });
                            Navigator.pop(modalCtx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Radar configurado a $tempNombre (${tempRadio.toInt()} km)'),
                                backgroundColor: AppTheme.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_circle_rounded, size: 20),
                          label: const Text(
                            'Confirmar Ubicación y Radio',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // SECTORES DE REFERENCIA RÁPIDA
                      Text(
                        'O Selecciona una Ciudad / Sector de Referencia:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                        ),
                      ),
                      const SizedBox(height: 8),

                      ..._ciudadesEcuador.map((ubi) {
                        final esActual = ubi.nombre == tempNombre;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Material(
                            color: esActual
                                ? AppTheme.primary.withValues(alpha: 0.12)
                                : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(14),
                            child: ListTile(
                              dense: true,
                              onTap: () {
                                setModalState(() {
                                  tempLat = ubi.latitud;
                                  tempLng = ubi.longitud;
                                  tempNombre = ubi.nombre;
                                  tempCiudad = ubi.ciudad;
                                });
                                mapController.move(LatLng(ubi.latitud, ubi.longitud), 13.0);
                              },
                              leading: Icon(
                                Icons.location_city_rounded,
                                color: esActual ? AppTheme.primaryLight : (isDark ? Colors.white70 : Colors.black54),
                                size: 20,
                              ),
                              title: Text(
                                ubi.nombre,
                                style: TextStyle(
                                  fontWeight: esActual ? FontWeight.w900 : FontWeight.w700,
                                  color: isDark ? Colors.white : AppTheme.textDark,
                                  fontSize: 13,
                                ),
                              ),
                              subtitle: Text(
                                '${ubi.ciudad} • (${ubi.latitud.toStringAsFixed(3)}, ${ubi.longitud.toStringAsFixed(3)})',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                                ),
                              ),
                              trailing: esActual
                                  ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryLight, size: 18)
                                  : null,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ==========================================================
  // HELPER PARA RENDERIZAR FOTOS (URL O ARCHIVO LOCAL NATIVO)
  // ==========================================================
  Widget _buildFotoMascota(
    String pathOrUrl, {
    BorderRadius? borderRadius,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final esInvalidaOUnsplash = pathOrUrl.trim().isEmpty ||
        pathOrUrl.contains('unsplash.com') ||
        pathOrUrl.contains('placeholder');

    if (esInvalidaOUnsplash) {
      final placeholderWidget = Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                : [const Color(0xFFE2E8F0), const Color(0xFFCBD5E1)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.pets_rounded,
                size: (height != null && height < 120) ? 28 : 42,
                color: AppTheme.primaryLight.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 4),
              Text(
                'Foto Real no disponible',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                ),
              ),
            ],
          ),
        ),
      );
      return placeholderWidget;
    }

    final isLocal = !pathOrUrl.startsWith('http://') && !pathOrUrl.startsWith('https://');
    Widget imgWidget;

    if (isLocal) {
      imgWidget = Image.file(
        File(pathOrUrl),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: AppTheme.primary.withValues(alpha: 0.15),
          child: const Center(child: Icon(Icons.pets, size: 48, color: AppTheme.primary)),
        ),
      );
    } else {
      imgWidget = Image.network(
        pathOrUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: AppTheme.primary.withValues(alpha: 0.15),
          child: const Center(child: Icon(Icons.pets, size: 48, color: AppTheme.primary)),
        ),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius, child: imgWidget);
    }
    return imgWidget;
  }

  // ==========================================================
  // DETALLE COMPLETO DE MASCOTA CON RADAR & CONTACTO
  // ==========================================================
  void _mostrarDetalleMascota(Reporte reporte) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final distanciaTexto = reporte.formatearDistancia(_ubicacionUsuario.latitud, _ubicacionUsuario.longitud);
    final distanciaKm = reporte.calcularDistanciaKm(_ubicacionUsuario.latitud, _ubicacionUsuario.longitud);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.90,
          maxChildSize: 0.96,
          minChildSize: 0.55,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // Hero Image with Overlays
                  Stack(
                    children: [
                      _buildFotoMascota(
                        reporte.imagenUrl,
                        height: 260,
                        width: double.infinity,
                        borderRadius: BorderRadius.circular(24),
                        fit: BoxFit.cover,
                      ),
                      // Tipo de alerta Badge
                      Positioned(
                        top: 14,
                        left: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(reporte.tipoAlerta.colorHex),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.notification_important_rounded, size: 14, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                reporte.tipoAlerta.label.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Distancia Badge Flotante
                      Positioned(
                        bottom: 14,
                        left: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.near_me_rounded, color: Color(0xFF5EEAD4), size: 14),
                              const SizedBox(width: 6),
                              Text(
                                distanciaTexto,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Header Mascota + Recompensa
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reporte.mascota,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                                color: isDark ? Colors.white : AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${reporte.especie} • ${reporte.raza}',
                              style: const TextStyle(
                                color: AppTheme.primaryLight,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (reporte.recompensa != null && reporte.recompensa!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'RECOMPENSA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                reporte.recompensa!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Radar de Geolocalización Exacta & Coordenadas
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDFA),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFF99F6E4),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.radar_rounded, color: AppTheme.primaryLight, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Punto de Geolocalización GPS',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      color: isDark ? Colors.white : AppTheme.textDark,
                                    ),
                                  ),
                                  Text(
                                    '${reporte.ubicacion} (${reporte.ciudad})',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.primaryLight,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (distanciaKm <= 3.0 ? AppTheme.successGreen : AppTheme.primary)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                distanciaTexto,
                                style: TextStyle(
                                  color: distanciaKm <= 3.0 ? AppTheme.successGreen : AppTheme.primaryLight,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.pin_drop_rounded, size: 16, color: AppTheme.alertCoral),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Coordenadas: ${reporte.latitud.toStringAsFixed(5)}, ${reporte.longitud.toStringAsFixed(5)}',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(
                                    text: '${reporte.latitud},${reporte.longitud}',
                                  ));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Coordenadas GPS copiadas al portapapeles.'),
                                      backgroundColor: AppTheme.primary,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  );
                                },
                                child: const Icon(Icons.copy_rounded, size: 16, color: AppTheme.primaryLight),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Ficha de Atributos Físicos (Grid)
                  Text(
                    'Características de Identificación',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 3.2,
                    children: [
                      _buildChipCaracteristica('Tamaño', reporte.tamano, Icons.straighten_rounded, isDark),
                      _buildChipCaracteristica('Sexo', reporte.sexo, Icons.male_rounded, isDark),
                      _buildChipCaracteristica('Color', reporte.color, Icons.palette_rounded, isDark),
                      _buildChipCaracteristica(
                        'Collar',
                        reporte.tieneCollar ? 'Con Collar' : 'Sin Collar',
                        Icons.check_circle_outline_rounded,
                        isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Descripción detallada
                  Text(
                    'Detalles & Rasgos Particulares',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      reporte.descripcion,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.5,
                        color: isDark ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Acciones de Rescate y Contacto Inmediato
                  Text(
                    'Contacto Directo con el Rescatista',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Botón WhatsApp Directo
                  _buildBotonContactoAccion(
                    titulo: 'WhatsApp Inmediato',
                    subtitulo: 'Envía un mensaje de rescate directo',
                    numero: reporte.telefonoSecundario ?? reporte.telefonoPrincipal,
                    icono: Icons.chat_rounded,
                    color: AppTheme.successGreen,
                    accionLabel: 'Abrir Chat',
                    onTap: () {
                      final mensaje =
                          'Hola, vi el reporte de ${reporte.mascota} (${reporte.tipoAlerta.label}) en RescataPet EC en ${reporte.ubicacion}. Tengo información relevante:';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Mensaje WhatsApp preparado:\n"$mensaje"'),
                          backgroundColor: AppTheme.successGreen,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),

                  // Botón Llamada Telefónica
                  _buildBotonContactoAccion(
                    titulo: 'Llamada Directa',
                    subtitulo: 'Llamar al número del dueño / rescatista',
                    numero: reporte.telefonoPrincipal,
                    icono: Icons.phone_in_talk_rounded,
                    color: AppTheme.primary,
                    accionLabel: 'Llamar',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Marcando a ${reporte.telefonoPrincipal}...'),
                          backgroundColor: AppTheme.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),

                  // Botón Reportar Avistamiento con GPS
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.pin_drop_rounded, color: Colors.white),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '¡Nuevo avistamiento registrado en tu ubicación (${_ubicacionUsuario.nombre})!',
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: AppTheme.primaryLight,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    icon: const Icon(Icons.remove_red_eye_rounded, size: 18),
                    label: const Text('¡Lo vi aquí! Registrar Avistamiento'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryLight,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppTheme.primaryLight, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChipCaracteristica(String label, String valor, IconData icono, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Icon(icono, size: 16, color: AppTheme.primaryLight),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  valor,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonContactoAccion({
    required String titulo,
    required String subtitulo,
    required String numero,
    required IconData icono,
    required Color color,
    required String accionLabel,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icono, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                  ),
                ),
                Text(
                  numero,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(accionLabel, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // MODAL CREAR REPORTE ULTRA COMPLETO CON GPS & FOTOS
  // ==========================================================
  void _mostrarDialogoNuevoReporte() {
    final mascotaCtrl = TextEditingController();
    TipoAlerta tipoSeleccionado = TipoAlerta.perdido;
    String especieSeleccionada = 'Perro';
    final razaCtrl = TextEditingController();
    final sectorCtrl = TextEditingController();
    final tel1Ctrl = TextEditingController();
    final tel2Ctrl = TextEditingController();
    final descCtrl = TextEditingController();
    final recompensaCtrl = TextEditingController();
    String tamanoSeleccionado = 'Mediano';
    String sexoSeleccionado = 'Macho';
    bool tieneCollar = true;
    bool tieneMicrochip = false;

    // Estado geográfico en cascada (País -> Provincia -> Cantón/Pueblo)
    PaisInfo paisSeleccionado = CatalogoGeografico.ecuador;
    ProvinciaInfo provinciaSeleccionada = paisSeleccionado.provincias.first;
    CantonInfo cantonSeleccionado = provinciaSeleccionada.cantones.first;
    double latitudReporte = cantonSeleccionado.latitud;
    double longitudReporte = cantonSeleccionado.longitud;
    bool esGpsPersonalizado = false;

    String imagenSeleccionada = '';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.94,
              maxChildSize: 0.98,
              minChildSize: 0.65,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.add_location_alt_rounded,
                              color: AppTheme.primaryLight,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Reportar Mascota con GPS',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Publicación georreferenciada para alertas comunitarias en tiempo real.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Selector de Tipo de Alerta
                      Text(
                        '1. Tipo de Alerta / Estado',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: isDark ? Colors.white : AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: TipoAlerta.values.map((tipo) {
                          final isSel = tipoSeleccionado == tipo;
                          final color = Color(tipo.colorHex);
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setModalState(() => tipoSeleccionado = tipo),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSel ? color : color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSel ? color : color.withValues(alpha: 0.3),
                                    width: isSel ? 2 : 1,
                                  ),
                                ),
                                child: Text(
                                  tipo.label,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: isSel ? Colors.white : (isDark ? Colors.white70 : color),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),

                      // Selector de Foto
                      Text(
                        '2. Fotografía Real de la Mascota',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: isDark ? Colors.white : AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),

                      GestureDetector(
                        onTap: () {
                          _mostrarGaleriaTelefono((nuevaImg) {
                            setModalState(() => imagenSeleccionada = nuevaImg);
                          });
                        },
                        child: imagenSeleccionada.isNotEmpty
                            ? Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  _buildFotoMascota(
                                    imagenSeleccionada,
                                    height: 180,
                                    width: double.infinity,
                                    borderRadius: BorderRadius.circular(20),
                                    fit: BoxFit.cover,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        _mostrarGaleriaTelefono((nuevaImg) {
                                          setModalState(() => imagenSeleccionada = nuevaImg);
                                        });
                                      },
                                      icon: const Icon(Icons.photo_camera_rounded, size: 18),
                                      label: const Text('Cambiar Foto'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primary,
                                        foregroundColor: Colors.white,
                                        elevation: 4,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                height: 130,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppTheme.primary.withValues(alpha: 0.4),
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary.withValues(alpha: 0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.add_a_photo_rounded,
                                          size: 28,
                                          color: AppTheme.primaryLight,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Adjuntar Fotografía Real (Cámara o Galería)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                          color: isDark ? Colors.white : AppTheme.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Toca para abrir cámara o galería nativa',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 18),

                      // Datos de Mascota
                      Text(
                        '3. Datos de Identificación',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: isDark ? Colors.white : AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: mascotaCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de la Mascota *',
                          prefixIcon: Icon(Icons.pets),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: especieSeleccionada,
                              dropdownColor: isDark ? AppTheme.cardDark : Colors.white,
                              style: TextStyle(
                                color: isDark ? Colors.white : AppTheme.textDark,
                                fontSize: 14,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Especie',
                                prefixIcon: Icon(Icons.category_rounded),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'Perro', child: Text('🐶 Perro')),
                                DropdownMenuItem(value: 'Gato', child: Text('🐱 Gato')),
                                DropdownMenuItem(value: 'Ave', child: Text('🦜 Ave')),
                                DropdownMenuItem(value: 'Conejo', child: Text('🐰 Conejo')),
                                DropdownMenuItem(value: 'Otro', child: Text('🐾 Otro')),
                              ],
                              onChanged: (val) => setModalState(() => especieSeleccionada = val!),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: tamanoSeleccionado,
                              dropdownColor: isDark ? AppTheme.cardDark : Colors.white,
                              style: TextStyle(
                                color: isDark ? Colors.white : AppTheme.textDark,
                                fontSize: 14,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Tamaño',
                                prefixIcon: Icon(Icons.straighten_rounded),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'Pequeño', child: Text('Pequeño')),
                                DropdownMenuItem(value: 'Mediano', child: Text('Mediano')),
                                DropdownMenuItem(value: 'Grande', child: Text('Grande')),
                              ],
                              onChanged: (val) => setModalState(() => tamanoSeleccionado = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: razaCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Raza / Color predominante',
                          hintText: 'ej. Mestizo, Golden, Siamés',
                          prefixIcon: Icon(Icons.style_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Switches de Collar y Microchip
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_outline, size: 18, color: AppTheme.primaryLight),
                                  const SizedBox(width: 6),
                                  const Expanded(
                                    child: Text('Collar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                  ),
                                  Switch(
                                    value: tieneCollar,
                                    activeThumbColor: AppTheme.primaryLight,
                                    onChanged: (v) => setModalState(() => tieneCollar = v),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.qr_code_2_rounded, size: 18, color: AppTheme.primaryLight),
                                  const SizedBox(width: 6),
                                  const Expanded(
                                    child: Text('Microchip', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                  ),
                                  Switch(
                                    value: tieneMicrochip,
                                    activeThumbColor: AppTheme.primaryLight,
                                    onChanged: (v) => setModalState(() => tieneMicrochip = v),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Ubicación Geográfica en Cascada & GPS
                      Text(
                        '4. Ubicación Geográfica (País / Provincia / Cantón)',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: isDark ? Colors.white : AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Selector de País
                      DropdownButtonFormField<PaisInfo>(
                        initialValue: paisSeleccionado,
                        dropdownColor: isDark ? AppTheme.cardDark : Colors.white,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppTheme.textDark,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'País de Residencia / Alerta *',
                          prefixIcon: Icon(Icons.public_rounded, color: AppTheme.primaryLight),
                        ),
                        items: CatalogoGeografico.paises.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Text(p.nombreConBandera),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              paisSeleccionado = val;
                              provinciaSeleccionada = val.provincias.first;
                              cantonSeleccionado = provinciaSeleccionada.cantones.first;
                              latitudReporte = cantonSeleccionado.latitud;
                              longitudReporte = cantonSeleccionado.longitud;
                              esGpsPersonalizado = false;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 10),

                      // Selector de Provincia / Departamento
                      DropdownButtonFormField<ProvinciaInfo>(
                        key: ValueKey('prov_${paisSeleccionado.id}'),
                        initialValue: provinciaSeleccionada,
                        dropdownColor: isDark ? AppTheme.cardDark : Colors.white,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppTheme.textDark,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Provincia / Departamento *',
                          prefixIcon: Icon(Icons.map_outlined, color: AppTheme.accent),
                        ),
                        items: paisSeleccionado.provincias.map((prov) {
                          return DropdownMenuItem(
                            value: prov,
                            child: Text(prov.nombre),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              provinciaSeleccionada = val;
                              cantonSeleccionado = val.cantones.first;
                              latitudReporte = cantonSeleccionado.latitud;
                              longitudReporte = cantonSeleccionado.longitud;
                              esGpsPersonalizado = false;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 10),

                      // Selector de Cantón / Ciudad / Pueblo
                      DropdownButtonFormField<CantonInfo>(
                        key: ValueKey('cant_${provinciaSeleccionada.nombre}'),
                        initialValue: cantonSeleccionado,
                        dropdownColor: isDark ? AppTheme.cardDark : Colors.white,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppTheme.textDark,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Cantón / Ciudad / Sector de Referencia *',
                          prefixIcon: Icon(Icons.location_city_rounded, color: AppTheme.alertCoral),
                        ),
                        items: provinciaSeleccionada.cantones.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text(c.nombre),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              cantonSeleccionado = val;
                              latitudReporte = val.latitud;
                              longitudReporte = val.longitud;
                              esGpsPersonalizado = false;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 10),

                      // Botón GPS Nativo de Alta Precisión
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final resultado = await NativeLocationService.obtenerPosicionActual(context);
                            if (resultado.estado == EstadoPermisoNativo.concedido && resultado.posicion != null) {
                              final pos = resultado.posicion!;
                              setModalState(() {
                                latitudReporte = pos.latitude;
                                longitudReporte = pos.longitude;
                                esGpsPersonalizado = true;
                                sectorCtrl.text = 'GPS Exacto: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
                              });
                            }
                          },
                          icon: Icon(
                            esGpsPersonalizado ? Icons.gps_fixed_rounded : Icons.my_location_rounded,
                            size: 18,
                            color: esGpsPersonalizado ? AppTheme.successGreen : AppTheme.primaryLight,
                          ),
                          label: Text(
                            esGpsPersonalizado
                                ? 'GPS Calibrado (${latitudReporte.toStringAsFixed(3)}, ${longitudReporte.toStringAsFixed(3)})'
                                : 'Sobrescribir con GPS Satelital Exacto',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: esGpsPersonalizado ? AppTheme.successGreen : AppTheme.primaryLight,
                            side: BorderSide(
                              color: esGpsPersonalizado ? AppTheme.successGreen : AppTheme.primaryLight,
                              width: esGpsPersonalizado ? 1.5 : 1.0,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: sectorCtrl,
                        decoration: InputDecoration(
                          labelText: 'Detalle de la Calle / Barrio / Referencia',
                          hintText: 'ej. Av. 10 de Agosto y Colón, cerca a la panadería',
                          prefixIcon: const Icon(Icons.signpost_rounded),
                          suffixIcon: Tooltip(
                            message: 'Coordenadas del reporte: ${latitudReporte.toStringAsFixed(4)}, ${longitudReporte.toStringAsFixed(4)}',
                            child: const Icon(Icons.info_outline_rounded, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Contactos
                      Text(
                        '5. Contacto Telefónico (${paisSeleccionado.codigoTelefonico}) & Recompensa',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: isDark ? Colors.white : AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: tel1Ctrl,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Teléfono Principal de Contacto *',
                          hintText: 'ej. 0998765432',
                          prefixIcon: const Icon(Icons.phone_rounded),
                          prefixText: '${paisSeleccionado.codigoTelefonico} ',
                          prefixStyle: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: tel2Ctrl,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          labelText: 'WhatsApp Directo (Opcional)',
                          hintText: 'ej. 0987654321',
                          prefixIcon: const Icon(Icons.chat_rounded, color: AppTheme.successGreen),
                          prefixText: '${paisSeleccionado.codigoTelefonico} ',
                          prefixStyle: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: recompensaCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          labelText: 'Recompensa Económica (Opcional)',
                          hintText: 'ej. 100',
                          prefixIcon: Icon(Icons.monetization_on_rounded, color: AppTheme.accent),
                          prefixText: '\$ ',
                          suffixText: ' USD',
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: descCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Descripción detallada (comportamiento, salud, collar...)',
                          prefixIcon: Icon(Icons.description_rounded),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Botón Enviar
                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final nombreMascota = mascotaCtrl.text.trim().isEmpty
                                ? 'Mascota Perdidita'
                                : mascotaCtrl.text.trim();
                            final sector = sectorCtrl.text.trim().isEmpty
                                ? cantonSeleccionado.nombre
                                : sectorCtrl.text.trim();
                            final lugarCompleto = '$sector, ${cantonSeleccionado.nombre} (${paisSeleccionado.nombre})';
                            final telP = tel1Ctrl.text.trim().isEmpty
                                ? '${paisSeleccionado.codigoTelefonico} 0998765432'
                                : '${paisSeleccionado.codigoTelefonico} ${tel1Ctrl.text.trim()}';
                            final telS = tel2Ctrl.text.trim().isNotEmpty
                                ? '${paisSeleccionado.codigoTelefonico} ${tel2Ctrl.text.trim()}'
                                : null;
                            final rec = recompensaCtrl.text.trim().isNotEmpty
                                ? '\$${recompensaCtrl.text.trim()} USD'
                                : null;

                            // Crear reporte local enriquecido
                            final nuevoReporte = Reporte(
                              id: DateTime.now().millisecondsSinceEpoch,
                              mascota: nombreMascota,
                              especie: especieSeleccionada,
                              raza: razaCtrl.text.trim().isEmpty ? 'Mestizo' : razaCtrl.text.trim(),
                              ubicacion: lugarCompleto,
                              ciudad: cantonSeleccionado.nombre,
                              sector: sector,
                              latitud: latitudReporte,
                              longitud: longitudReporte,
                              tipoAlerta: tipoSeleccionado,
                              estado: 'PUBLICO',
                              imagenUrl: imagenSeleccionada,
                              telefonoPrincipal: telP,
                              telefonoSecundario: telS,
                              esVerificado: true,
                              descripcion: descCtrl.text.trim().isEmpty
                                  ? 'Reporte publicado en $lugarCompleto. Por favor comunicarse si la observas.'
                                  : descCtrl.text.trim(),
                              recompensa: rec,
                              fecha: 'Hace un momento',
                              tamano: tamanoSeleccionado,
                              sexo: sexoSeleccionado,
                              tieneCollar: tieneCollar,
                              esterilizado: true,
                            );

                            final messenger = ScaffoldMessenger.of(context);
                            Navigator.pop(context);

                            setState(() {
                              _reportesLocalesAdicionales.insert(0, nuevoReporte);
                            });

                            try {
                              await ApiService.crearReporte(
                                mascota: '$nombreMascota ($especieSeleccionada)',
                                ubicacion: lugarCompleto,
                                estado: 'PUBLICO',
                              );
                            } catch (_) {
                              // El backend puede estar en modo local/mock, el reporte local ya se agregó
                            }

                            messenger.showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: Colors.white),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        '¡Alerta de $nombreMascota publicada en ${cantonSeleccionado.nombre} con éxito!',
                                        style: const TextStyle(fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: AppTheme.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.campaign_rounded, size: 22),
                          label: const Text(
                            'Publicar Alerta Comunitaria',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _mostrarGaleriaTelefono(Function(String) onImagenSeleccionada) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: isDark ? AppTheme.cardDark : AppTheme.cardLight,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_a_photo_rounded, color: AppTheme.primaryLight, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Adjuntar Fotografía Real',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Elige el origen de la foto. Se solicitará el permiso del sistema operativo con explicación previa.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                  ),
                ),
                const SizedBox(height: 20),

                // Botones Nativos: Cámara y Galería
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final file = await NativeMediaService.seleccionarOtomarFoto(
                            context,
                            source: ImageSource.camera,
                          );
                          if (file != null) {
                            onImagenSeleccionada(file.path);
                            if (context.mounted) Navigator.pop(context);
                          }
                        },
                        icon: const Icon(Icons.camera_alt_rounded, size: 20),
                        label: const Text('Tomar Foto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final file = await NativeMediaService.seleccionarOtomarFoto(
                            context,
                            source: ImageSource.gallery,
                          );
                          if (file != null) {
                            onImagenSeleccionada(file.path);
                            if (context.mounted) Navigator.pop(context);
                          }
                        },
                        icon: const Icon(Icons.photo_library_rounded, size: 20),
                        label: const Text('Abrir Galería'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          foregroundColor: isDark ? Colors.white : AppTheme.textDark,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // BUILD PRINCIPAL
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.pets_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RescataPet EC',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Red Comunitaria de Rescate Animal',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFCCFBF1),
                  ),
                ),
              ],
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                  : [AppTheme.primary, AppTheme.primaryLight],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? AppTheme.accent : Colors.white,
            ),
            tooltip: isDark ? 'Activar Modo Claro' : 'Activar Modo Oscuro',
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar Feed',
            onPressed: _cargarReportes,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Cerrar Sesión',
            onPressed: () => _confirmarCerrarSesion(),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildReportesTab(authState),
          _buildRefugiosTab(),
          _buildPerfilTab(authState),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _mostrarDialogoNuevoReporte,
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.add_location_alt_rounded),
              label: const Text(
                'Reportar Mascota',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore_rounded),
            label: 'Explorar & GPS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety_outlined),
            activeIcon: Icon(Icons.health_and_safety_rounded),
            label: 'Refugios & SOS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Mi Perfil',
          ),
        ],
      ),
    );
  }

  void _confirmarCerrarSesion() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.logout_rounded, color: AppTheme.alertCoral),
              SizedBox(width: 10),
              Text('Cerrar Sesión'),
            ],
          ),
          content: const Text('¿Estás seguro de que deseas salir de tu cuenta en RescataPet EC?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.alertCoral,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(context);
                await ref.read(authProvider.notifier).cerrarSesion();
                if (!context.mounted) return;
                context.go('/login');
              },
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // TAB 1: FEED DE MASCOTAS CON FILTRO DE DISTANCIA GPS & ALERTAS
  // ==========================================================
  Widget _buildReportesTab(SesionUsuario? usuario) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Header con Ubicación GPS & Filtros
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                  : [AppTheme.primary, AppTheme.primaryLight],
            ),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra de Ubicación Actual del Usuario
              GestureDetector(
                onTap: _mostrarSelectorUbicacionUsuario,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.my_location_rounded, color: Color(0xFF5EEAD4), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TU UBICACIÓN GPS:',
                              style: TextStyle(
                                color: Color(0xFFCCFBF1),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              _ubicacionUsuario.nombre,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'Cambiar',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                            Icon(Icons.arrow_drop_down_rounded, color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Buscador
              TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre, raza o sector...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? const Color(0xFF334155) : Colors.white,
                  hintStyle: TextStyle(
                    color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                    fontSize: 13,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark),
              ),
              const SizedBox(height: 12),

              // Chips de Tipo de Alerta y Especie
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildChipTipoAlerta(null, 'Todos', Icons.dashboard_rounded),
                    const SizedBox(width: 8),
                    _buildChipTipoAlerta(TipoAlerta.perdido, '🔴 Perdidos', Icons.search_rounded),
                    const SizedBox(width: 8),
                    _buildChipTipoAlerta(TipoAlerta.encontrado, '🟢 Encontrados', Icons.check_circle_rounded),
                    const SizedBox(width: 8),
                    _buildChipTipoAlerta(TipoAlerta.sos, '🚨 SOS Urgente', Icons.warning_rounded),
                    const SizedBox(width: 8),
                    _buildChipTipoAlerta(TipoAlerta.adopcion, '🐾 En Adopción', Icons.favorite_rounded),
                    const SizedBox(width: 12),
                    Container(height: 20, width: 1, color: Colors.white24),
                    const SizedBox(width: 12),
                    _buildChipEspecie('Todos', 'Todas esp.'),
                    const SizedBox(width: 8),
                    _buildChipEspecie('Perros', '🐕 Perros'),
                    const SizedBox(width: 8),
                    _buildChipEspecie('Gatos', '🐈 Gatos'),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Barra de Radio de Distancia GPS (1km, 5km, 15km, Todo)
              Row(
                children: [
                  const Icon(Icons.radar_rounded, size: 15, color: Color(0xFF5EEAD4)),
                  const SizedBox(width: 6),
                  const Text(
                    'Radio:',
                    style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildChipRadio(50.0, 'Toda la ciudad'),
                          _buildChipRadio(1.0, '1 km'),
                          _buildChipRadio(3.0, '3 km'),
                          _buildChipRadio(5.0, '5 km'),
                          _buildChipRadio(10.0, '10 km'),
                          _buildChipRadio(25.0, '25 km'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Lista de Reportes con Cálculo Reactivo de Distancia
        Expanded(
          child: FutureBuilder<List<Reporte>>(
            future: _futureReportes,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryLight),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.alertCoral),
                      const SizedBox(height: 12),
                      Text(
                        'Error al cargar reportes: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTheme.alertCoral),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _cargarReportes,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              // Combinar con reportes locales creados en la sesión
              final todos = [
                ..._reportesLocalesAdicionales,
                ...?snapshot.data,
              ];

              if (todos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.pets, size: 64, color: AppTheme.primaryLight),
                      const SizedBox(height: 14),
                      const Text(
                        'No hay reportes de mascotas en este momento.',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _mostrarDialogoNuevoReporte,
                        child: const Text('¡Crear el Primer Reporte!'),
                      ),
                    ],
                  ),
                );
              }

              // Aplicar Filtros (Búsqueda, Tipo de Alerta, Especie, Radio de Distancia)
              final reportesFiltrados = todos.where((r) {
                final query = _searchQuery.toLowerCase();
                final matchQuery = r.mascota.toLowerCase().contains(query) ||
                    r.ubicacion.toLowerCase().contains(query) ||
                    r.raza.toLowerCase().contains(query) ||
                    r.descripcion.toLowerCase().contains(query);

                if (!matchQuery) return false;

                // Filtro por tipo de alerta
                if (_filtroTipoAlerta != null && r.tipoAlerta != _filtroTipoAlerta) {
                  return false;
                }

                // Filtro por especie
                if (_filtroEspecie == 'Perros' && !r.especie.toLowerCase().contains('perro')) {
                  return false;
                } else if (_filtroEspecie == 'Gatos' && !r.especie.toLowerCase().contains('gato')) {
                  return false;
                }

                // Filtro por radio de distancia GPS
                if (_radioDistanciaKm < 50.0) {
                  final distancia = r.calcularDistanciaKm(_ubicacionUsuario.latitud, _ubicacionUsuario.longitud);
                  if (distancia > _radioDistanciaKm) return false;
                }

                return true;
              }).toList();

              // Ordenar por distancia (los más cercanos primero)
              reportesFiltrados.sort((a, b) {
                final distA = a.calcularDistanciaKm(_ubicacionUsuario.latitud, _ubicacionUsuario.longitud);
                final distB = b.calcularDistanciaKm(_ubicacionUsuario.latitud, _ubicacionUsuario.longitud);
                return distA.compareTo(distB);
              });

              if (reportesFiltrados.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.radar_rounded,
                          size: 56,
                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No hay alertas dentro del radio de ${_radioDistanciaKm.toInt()} km de ${_ubicacionUsuario.nombre}.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _radioDistanciaKm = 50.0;
                              _filtroTipoAlerta = null;
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                          child: const Text('Restablecer Filtros de Cobertura'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                color: AppTheme.primaryLight,
                onRefresh: () async => _cargarReportes(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 88),
                  itemCount: reportesFiltrados.length,
                  itemBuilder: (context, index) {
                    final reporte = reportesFiltrados[index];
                    return _buildTarjetaMascota(reporte);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChipTipoAlerta(TipoAlerta? tipo, String label, IconData icono) {
    final isSelected = _filtroTipoAlerta == tipo;
    return GestureDetector(
      onTap: () {
        setState(() => _filtroTipoAlerta = tipo);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icono,
              size: 14,
              color: isSelected ? AppTheme.primary : Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primary : Colors.white,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChipRadio(double radio, String label) {
    final isSelected = _radioDistanciaKm == radio;
    return GestureDetector(
      onTap: () => setState(() => _radioDistanciaKm = radio),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5EEAD4) : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF0F766E) : Colors.white,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildChipEspecie(String especie, String label) {
    final isSelected = _filtroEspecie == especie;
    return GestureDetector(
      onTap: () => setState(() => _filtroEspecie = especie),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primary : Colors.white,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 11.5,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // TARJETA DE MASCOTA CON DISTANCIA GPS & ACCIONES RÁPIDAS
  // ==========================================================
  Widget _buildTarjetaMascota(Reporte reporte) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final distanciaKm = reporte.calcularDistanciaKm(_ubicacionUsuario.latitud, _ubicacionUsuario.longitud);
    final distanciaTexto = reporte.formatearDistancia(_ubicacionUsuario.latitud, _ubicacionUsuario.longitud);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _mostrarDetalleMascota(reporte),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack con Distancia y Estado
            Stack(
              children: [
                _buildFotoMascota(
                  reporte.imagenUrl,
                  height: 210,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                // Tipo de Alerta Badge (Perdido, Encontrado, SOS, Adopción)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Color(reporte.tipoAlerta.colorHex),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.campaign_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          reporte.tipoAlerta.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Badge de Distancia GPS Flotante
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: distanciaKm <= 3.0 ? const Color(0xFF5EEAD4) : Colors.white24,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.near_me_rounded,
                          size: 13,
                          color: distanciaKm <= 3.0 ? const Color(0xFF5EEAD4) : Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          distanciaTexto,
                          style: TextStyle(
                            color: distanciaKm <= 3.0 ? const Color(0xFF5EEAD4) : Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Recompensa Badge si existe
                if (reporte.recompensa != null && reporte.recompensa!.isNotEmpty)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Text(
                        '💰 RECOMPENSA: ${reporte.recompensa!}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reporte.mascota,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                            color: isDark ? Colors.white : AppTheme.textDark,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          reporte.fecha,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${reporte.especie} • ${reporte.raza} • ${reporte.tamano}',
                    style: const TextStyle(
                      color: AppTheme.primaryLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 16, color: AppTheme.alertCoral),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${reporte.ubicacion} (${reporte.ciudad})',
                          style: TextStyle(
                            color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Description snippet
                  Text(
                    reporte.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Divider(
                    height: 1,
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                  const SizedBox(height: 10),

                  // Bottom Action Bar con Botón WhatsApp Rápido
                  Row(
                    children: [
                      // Botón WhatsApp rápido
                      IconButton(
                        onPressed: () {
                          final mensaje =
                              'Hola, vi el reporte de ${reporte.mascota} (${reporte.tipoAlerta.label}) en RescataPet EC. ¿Sigue el caso activo?';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Mensaje preparado para ${reporte.mascota}:\n"$mensaje"'),
                              backgroundColor: AppTheme.successGreen,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat_rounded, color: AppTheme.successGreen, size: 20),
                        tooltip: 'Contactar por WhatsApp',
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reporte.telefonoPrincipal,
                        style: TextStyle(
                          color: isDark ? const Color(0xFF5EEAD4) : AppTheme.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => _mostrarDetalleMascota(reporte),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        label: const Text('Ver Ficha & GPS'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryLight,
                          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // TAB 2: DIRECTORIO DE REFUGIOS & CLÍNICAS VETERINARIAS 24H
  // ==========================================================
  Widget _buildRefugiosTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final refugios = [
      {
        'nombre': 'PAE - Protección Animal Ecuador',
        'ciudad': 'Quito, Pichincha',
        'tipo': 'Fundación de Rescate & Clínica Veterinaria',
        'telefono': '022444009',
        'whatsapp': '0998877665',
        'direccion': 'Av. Eloy Alfaro y Pasaje de los Cipreses',
        'logo': '🐕',
        'urgencias24h': true,
        'lat': -0.1650,
        'lng': -78.4750,
      },
      {
        'nombre': 'Lucky Bienestar Animal EC',
        'ciudad': 'Quito / Valle de los Chillos',
        'tipo': 'Refugio & Santuario Canino',
        'telefono': '0987654321',
        'whatsapp': '0987654321',
        'direccion': 'Sangolquí, Sector El Chocó',
        'logo': '🐾',
        'urgencias24h': false,
        'lat': -0.3150,
        'lng': -78.4450,
      },
      {
        'nombre': 'Fundación Rescate Animal Guayaquil',
        'ciudad': 'Guayaquil, Guayas',
        'tipo': 'Rescate, Adopción & Urgencias',
        'telefono': '042889900',
        'whatsapp': '0991122334',
        'direccion': 'Urdesa Central y Guayacanes',
        'logo': '🐱',
        'urgencias24h': true,
        'lat': -2.1700,
        'lng': -79.9100,
      },
      {
        'nombre': 'Fundación Camino a Casa',
        'ciudad': 'Cuenca, Azuay',
        'tipo': 'Albergue y Esterilización Gratuita',
        'telefono': '072810022',
        'whatsapp': '0983344556',
        'direccion': 'Sector Monay, Cuenca',
        'logo': '🏡',
        'urgencias24h': false,
        'lat': -2.8900,
        'lng': -78.9800,
      },
      {
        'nombre': 'Urbanimal Quito (Municipio)',
        'ciudad': 'Quito (Calderón / Sur)',
        'tipo': 'Centro de Atención y Control Animal',
        'telefono': '1800510510',
        'whatsapp': '0990011223',
        'direccion': 'Panamericana Norte Km 11.5',
        'logo': '🏛️',
        'urgencias24h': true,
        'lat': -0.0950,
        'lng': -78.4350,
      },
      {
        'nombre': 'Hospital Veterinario 24/7 USFQ',
        'ciudad': 'Cumbayá, Quito',
        'tipo': 'Urgencias Médicas de Alta Complejidad 24 Horas',
        'telefono': '022971700',
        'whatsapp': '0995544332',
        'direccion': 'Diego de Robles y Vía Interoceánica',
        'logo': '🏥',
        'urgencias24h': true,
        'lat': -0.2033,
        'lng': -78.4312,
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                  : [const Color(0xFF0F766E), const Color(0xFF0D9488)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 28),
                  SizedBox(width: 10),
                  Text(
                    'Directorio de Refugios & SOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Centros de acogida, hospitales veterinarios 24/7 y fundaciones aliadas en las principales provincias de Ecuador.',
                style: TextStyle(color: Color(0xFFCCFBF1), fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Shelter Cards
        ...refugios.map((refugio) {
          final is24h = refugio['urgencias24h'] as bool;

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          refugio['logo'] as String,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              refugio['nombre'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              refugio['tipo'] as String,
                              style: const TextStyle(
                                color: AppTheme.primaryLight,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (is24h)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.alertCoral.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.alertCoral),
                          ),
                          child: const Text(
                            '24/7 SOS',
                            style: TextStyle(
                              color: AppTheme.alertCoral,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 16, color: AppTheme.alertCoral),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${refugio['ciudad']} • ${refugio['direccion']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Llamando a ${refugio['nombre']} (${refugio['telefono']})...'),
                                backgroundColor: AppTheme.primary,
                              ),
                            );
                          },
                          icon: const Icon(Icons.call_rounded, size: 16),
                          label: const Text('Llamar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryLight,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Abriendo WhatsApp con ${refugio['nombre']}...'),
                                backgroundColor: AppTheme.successGreen,
                              ),
                            );
                          },
                          icon: const Icon(Icons.chat_rounded, size: 16),
                          label: const Text('WhatsApp'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.successGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ==========================================================
  // TAB 3: PERFIL & AJUSTES
  // ==========================================================
  Widget _buildPerfilTab(SesionUsuario? usuario) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // User Profile Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppTheme.primary,
                      child: Text(
                        (usuario?.nombre.isNotEmpty == true)
                            ? usuario!.nombre.substring(0, 1).toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppTheme.successGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 14, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  usuario?.nombre ?? 'Usuario RescataPet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  usuario?.email ?? 'usuario@ejemplo.com',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🛡️ Miembro Rescatista Verificado EC',
                    style: TextStyle(
                      color: AppTheme.primaryLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Configuración
        Text(
          'Configuración & Preferencias',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 12),

        // Theme Toggle Tile
        Card(
          child: ListTile(
            leading: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: AppTheme.accent,
            ),
            title: const Text('Tema de la Aplicación', style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(isDark ? 'Modo Oscuro activado' : 'Modo Claro activado'),
            trailing: Switch(
              value: isDark,
              activeThumbColor: AppTheme.accent,
              onChanged: (val) {
                ref.read(themeModeProvider.notifier).toggleTheme();
              },
            ),
          ),
        ),
        const SizedBox(height: 10),

        // GPS Settings
        Card(
          child: ListTile(
            leading: const Icon(Icons.my_location_rounded, color: AppTheme.primaryLight),
            title: const Text('Ubicación GPS Base', style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(_ubicacionUsuario.nombre),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: _mostrarSelectorUbicacionUsuario,
          ),
        ),
        const SizedBox(height: 10),

        // API Status Tile
        Card(
          child: ListTile(
            leading: const Icon(Icons.storage_rounded, color: AppTheme.primaryLight),
            title: const Text('Estado de la Red & Backend', style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: const Text('Node.js REST API + SQLite Conectado'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'ONLINE',
                style: TextStyle(
                  color: AppTheme.successGreen,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // About RescataPet Tile
        Card(
          child: ListTile(
            leading: const Icon(Icons.info_outline_rounded, color: AppTheme.infoBlue),
            title: const Text('Acerca de RescataPet EC', style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: const Text('Versión 1.1.0 • Producción Ecuador'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'RescataPet EC',
                applicationVersion: '1.1.0',
                applicationIcon: const Icon(Icons.pets, size: 40, color: AppTheme.primary),
                children: const [
                  Text(
                    'Aplicación móvil desarrollada con Flutter & Riverpod con geolocalización GPS, radar de cercanía y alertas comunitarias de rescate animal en Ecuador.',
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // Logout Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () => _confirmarCerrarSesion(),
            icon: const Icon(Icons.logout_rounded, color: AppTheme.alertCoral),
            label: const Text(
              'Cerrar Sesión',
              style: TextStyle(
                color: AppTheme.alertCoral,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.alertCoral, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }
}
