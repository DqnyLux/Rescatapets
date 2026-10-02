import 'dart:math' as math;

enum TipoAlerta {
  perdido('PERDIDO', 'Extraviado', 0xFFEF4444),
  encontrado('ENCONTRADO', 'Encontrado', 0xFF10B981),
  adopcion('ADOPCION', 'En Adopción', 0xFF0D9488),
  sos('SOS', 'Emergencia SOS', 0xFFDC2626);

  final String codigo;
  final String label;
  final int colorHex;
  const TipoAlerta(this.codigo, this.label, this.colorHex);

  static TipoAlerta fromString(String? val) {
    if (val == null) return TipoAlerta.perdido;
    final upper = val.toUpperCase();
    if (upper.contains('ENCONT')) return TipoAlerta.encontrado;
    if (upper.contains('ADOP')) return TipoAlerta.adopcion;
    if (upper.contains('SOS') || upper.contains('URG')) return TipoAlerta.sos;
    return TipoAlerta.perdido;
  }
}

class Reporte {
  final int id;
  final String mascota;
  final String especie;
  final String raza;
  final String ubicacion;
  final String ciudad;
  final String sector;
  final double latitud;
  final double longitud;
  final TipoAlerta tipoAlerta;
  final String estado;
  final String imagenUrl;
  final List<String> imagenesAdicionales;
  final String telefonoPrincipal;
  final String? telefonoSecundario;
  final bool esVerificado;
  final String descripcion;
  final String? recompensa;
  final String fecha;
  final String tamano;
  final String sexo;
  final String color;
  final bool tieneCollar;
  final bool esterilizado;

  Reporte({
    required this.id,
    required this.mascota,
    required this.especie,
    required this.raza,
    required this.ubicacion,
    this.ciudad = 'Quito',
    this.sector = 'La Carolina',
    this.latitud = -0.1807,
    this.longitud = -78.4842,
    this.tipoAlerta = TipoAlerta.perdido,
    required this.estado,
    this.imagenUrl = '',
    this.imagenesAdicionales = const [],
    required this.telefonoPrincipal,
    this.telefonoSecundario,
    required this.esVerificado,
    required this.descripcion,
    this.recompensa,
    required this.fecha,
    this.tamano = 'Mediano',
    this.sexo = 'Macho',
    this.color = 'Dorado / Blanco',
    this.tieneCollar = true,
    this.esterilizado = true,
  });

  bool get tieneFotoReal =>
      imagenUrl.trim().isNotEmpty &&
      !imagenUrl.contains('unsplash.com') &&
      !imagenUrl.contains('placeholder');

  /// Calcula la distancia en kilómetros usando la fórmula del Semiverseno (Haversine)
  double calcularDistanciaKm(double userLat, double userLng) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        math.cos((latitud - userLat) * p) / 2 +
        math.cos(userLat * p) *
            math.cos(latitud * p) *
            (1 - math.cos((longitud - userLng) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(a));
  }

  String formatearDistancia(double userLat, double userLng) {
    final dist = calcularDistanciaKm(userLat, userLng);
    if (dist < 1.0) {
      final metros = (dist * 1000).round();
      return 'A $metros m de ti';
    } else {
      return 'A ${dist.toStringAsFixed(1)} km de ti';
    }
  }

  factory Reporte.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int? ?? DateTime.now().millisecondsSinceEpoch % 10000;

    final coordenadas = [
      {'lat': -0.1807, 'lng': -78.4842, 'ciudad': 'Quito', 'sec': 'Parque La Carolina'},
      {'lat': -0.1915, 'lng': -78.4880, 'ciudad': 'Quito', 'sec': 'González Suárez'},
      {'lat': -0.2201, 'lng': -78.5123, 'ciudad': 'Quito', 'sec': 'Centro Histórico'},
      {'lat': -0.2033, 'lng': -78.4312, 'ciudad': 'Quito', 'sec': 'Cumbayá'},
      {'lat': -2.1894, 'lng': -79.8891, 'ciudad': 'Guayaquil', 'sec': 'Malecón 2000'},
      {'lat': -2.9001, 'lng': -79.0059, 'ciudad': 'Cuenca', 'sec': 'Parque Calderón'},
      {'lat': -0.9538, 'lng': -80.7089, 'ciudad': 'Manta', 'sec': 'Playa Murciélago'},
      {'lat': -1.2491, 'lng': -78.6168, 'ciudad': 'Ambato', 'sec': 'Ficoa'},
    ];
    final coordInfo = coordenadas[(id - 1) % coordenadas.length];

    final tipos = [
      TipoAlerta.perdido,
      TipoAlerta.encontrado,
      TipoAlerta.sos,
      TipoAlerta.adopcion,
      TipoAlerta.perdido,
      TipoAlerta.encontrado,
    ];

    // No se usan imágenes falsas de internet por defecto; solo fotos reales si vienen dadas
    final fotoRaw = json['imagenUrl'] as String? ?? json['foto'] as String? ?? '';
    final imagenValida = (fotoRaw.startsWith('http') || fotoRaw.startsWith('file://') || fotoRaw.startsWith('/')) &&
            !fotoRaw.contains('unsplash.com')
        ? fotoRaw
        : '';

    return Reporte(
      id: id,
      mascota: json['mascota'] as String? ?? 'Mascota',
      especie: json['especie'] as String? ?? 'Perro',
      raza: json['raza'] as String? ?? 'Mestizo',
      ubicacion: json['ubicacion'] as String? ?? '',
      ciudad: json['ciudad'] as String? ?? '',
      sector: json['sector'] as String? ?? '',
      latitud: (json['latitud'] as num?)?.toDouble() ?? 0.0,
      longitud: (json['longitud'] as num?)?.toDouble() ?? 0.0,
      tipoAlerta: TipoAlerta.fromString(json['tipoAlerta']?.toString()),
      estado: json['estado'] as String? ?? 'PUBLICO',
      imagenUrl: json['imagenBase64'] as String? ?? '',
      telefonoPrincipal: json['telefonoPrincipal'] as String? ?? '0990000000',
      telefonoSecundario: json['telefonoSecundario'] as String?,
      esVerificado: true,
      descripcion: json['descripcion'] as String? ?? 'Sin descripción.',
      recompensa: json['recompensa'] as String?,
      fecha: json['createdAt'] as String? ?? 'Reciente',
      tamano: json['tamano'] as String? ?? 'Mediano',
      sexo: json['sexo'] as String? ?? 'Macho',
      color: json['color'] as String? ?? 'Indefinido',
      tieneCollar: true,
      esterilizado: true,
    );
  }
}
