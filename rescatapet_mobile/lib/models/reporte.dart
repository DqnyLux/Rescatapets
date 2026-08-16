class Reporte {
  final int id;
  final String mascota;
  final String especie;
  final String raza;
  final String ubicacion;
  final String estado;
  final String imagenUrl;
  final String telefonoPrincipal;
  final String? telefonoSecundario;
  final bool esVerificado;
  final String descripcion;
  final String? recompensa;
  final String fecha;

  Reporte({
    required this.id,
    required this.mascota,
    required this.especie,
    required this.raza,
    required this.ubicacion,
    required this.estado,
    required this.imagenUrl,
    required this.telefonoPrincipal,
    this.telefonoSecundario,
    required this.esVerificado,
    required this.descripcion,
    this.recompensa,
    required this.fecha,
  });

  factory Reporte.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int? ?? 1;
    
    // Lista de imágenes reales de Unsplash para demostración visual de mascotas
    final imagenesMascotas = [
      'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1537151608828-ea2b11777ee8?auto=format&fit=crop&w=800&q=80',
    ];

    return Reporte(
      id: id,
      mascota: json['mascota'] as String? ?? 'Mascota Perdidita',
      especie: json['especie'] as String? ?? (id % 2 == 0 ? 'Gato' : 'Perro'),
      raza: json['raza'] as String? ?? (id % 2 == 0 ? 'Mestizo' : 'Golden Retriever'),
      ubicacion: json['ubicacion'] as String? ?? 'Quito, Ecuador',
      estado: json['estado'] as String? ?? 'PUBLICO',
      imagenUrl: json['imagenUrl'] as String? ?? imagenesMascotas[(id - 1) % imagenesMascotas.length],
      telefonoPrincipal: json['telefonoPrincipal'] as String? ?? '0998765432',
      telefonoSecundario: json['telefonoSecundario'] as String? ?? '0981234567',
      esVerificado: json['esVerificado'] as bool? ?? (id % 2 != 0),
      descripcion: json['descripcion'] as String? ??
          'Mascota extraviada recientemente. Llevaba collar rojo. Es muy amigable y responde a su nombre. Si la ves, por favor comunícate a cualquiera de los números de contacto.',
      recompensa: json['recompensa'] as String? ?? (id == 1 ? '\$100 USD' : null),
      fecha: json['fecha'] as String? ?? 'Hace 2 horas',
    );
  }
}
