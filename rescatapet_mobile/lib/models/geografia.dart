library;

import 'dart:math' as math;

/// Modelo de datos geográficos estructurados para selección en cascada:
/// País -> Provincia / Departamento -> Cantón / Ciudad / Pueblo con coordenadas centroides
/// y prefijos telefónicos internacionales para contacto WhatsApp/Llamadas.

class CantonInfo {
  final String nombre;
  final double latitud;
  final double longitud;

  const CantonInfo({
    required this.nombre,
    required this.latitud,
    required this.longitud,
  });
}

class ProvinciaInfo {
  final String nombre;
  final List<CantonInfo> cantones;

  const ProvinciaInfo({
    required this.nombre,
    required this.cantones,
  });
}

class PaisInfo {
  final String id;
  final String nombre;
  final String bandera;
  final String codigoTelefonico;
  final List<ProvinciaInfo> provincias;

  const PaisInfo({
    required this.id,
    required this.nombre,
    required this.bandera,
    required this.codigoTelefonico,
    required this.provincias,
  });

  String get nombreConBandera => '$bandera $nombre ($codigoTelefonico)';
}

/// Catálogo internacional de países soportados en RescataPet EC
class CatalogoGeografico {
  static const List<PaisInfo> paises = [
    PaisInfo(
      id: 'EC',
      nombre: 'Ecuador',
      bandera: '🇪🇨',
      codigoTelefonico: '+593',
      provincias: [
        ProvinciaInfo(
          nombre: 'Pichincha',
          cantones: [
            CantonInfo(nombre: 'Quito (Centro Histórico)', latitud: -0.2201, longitud: -78.5123),
            CantonInfo(nombre: 'Quito (Norte - La Carolina)', latitud: -0.1807, longitud: -78.4842),
            CantonInfo(nombre: 'Quito (Cumbayá / Tumbaco)', latitud: -0.2033, longitud: -78.4312),
            CantonInfo(nombre: 'Quito (Sur - Villaflora / El Recreo)', latitud: -0.2483, longitud: -78.5218),
            CantonInfo(nombre: 'Quito (Valle de los Chillos)', latitud: -0.3012, longitud: -78.4521),
            CantonInfo(nombre: 'Quito (Calderón / Carapungo)', latitud: -0.0987, longitud: -78.4231),
            CantonInfo(nombre: 'Rumiñahui (Sangolquí)', latitud: -0.3328, longitud: -78.4489),
            CantonInfo(nombre: 'Mejía (Machachi)', latitud: -0.5103, longitud: -78.5672),
            CantonInfo(nombre: 'Cayambe', latitud: 0.0417, longitud: -78.1450),
            CantonInfo(nombre: 'Pedro Moncayo (Tabacundo)', latitud: 0.0461, longitud: -78.2217),
            CantonInfo(nombre: 'San Miguel de los Bancos', latitud: 0.0211, longitud: -79.0208),
            CantonInfo(nombre: 'Pedro Vicente Maldonado', latitud: 0.0833, longitud: -79.0500),
            CantonInfo(nombre: 'Puerto Quito', latitud: 0.1264, longitud: -79.2561),
          ],
        ),
        ProvinciaInfo(
          nombre: 'Guayas',
          cantones: [
            CantonInfo(nombre: 'Guayaquil (Centro / Malecón)', latitud: -2.1894, longitud: -79.8891),
            CantonInfo(nombre: 'Guayaquil (Norte / Urdesa / Kennedy)', latitud: -2.1645, longitud: -79.9122),
            CantonInfo(nombre: 'Guayaquil (Sur / Centenario)', latitud: -2.2210, longitud: -79.8950),
            CantonInfo(nombre: 'Guayaquil (Vía a la Costa)', latitud: -2.1850, longitud: -80.0230),
            CantonInfo(nombre: 'Samborondón (La Puntilla)', latitud: -2.1386, longitud: -79.8661),
            CantonInfo(nombre: 'Samborondón (Cabecera)', latitud: -1.9628, longitud: -79.7239),
            CantonInfo(nombre: 'Daule (La Aurora)', latitud: -2.0317, longitud: -79.9808),
            CantonInfo(nombre: 'Daule (Cabecera)', latitud: -1.8667, longitud: -79.9833),
            CantonInfo(nombre: 'Durán', latitud: -2.1706, longitud: -79.8242),
            CantonInfo(nombre: 'Milagro', latitud: -2.1344, longitud: -79.5947),
            CantonInfo(nombre: 'Playas (General Villamil)', latitud: -2.6319, longitud: -80.3881),
            CantonInfo(nombre: 'Salitre', latitud: -1.8217, longitud: -79.8167),
            CantonInfo(nombre: 'El Empalme', latitud: -1.0439, longitud: -79.6358),
            CantonInfo(nombre: 'Balzar', latitud: -1.3639, longitud: -79.9056),
            CantonInfo(nombre: 'Naranjal', latitud: -2.6733, longitud: -79.6178),
            CantonInfo(nombre: 'Yaguachi', latitud: -2.0944, longitud: -79.6944),
          ],
        ),
        ProvinciaInfo(
          nombre: 'Azuay',
          cantones: [
            CantonInfo(nombre: 'Cuenca (Centro Histórico)', latitud: -2.9001, longitud: -79.0059),
            CantonInfo(nombre: 'Cuenca (El Vergel / Totoracocha)', latitud: -2.8912, longitud: -78.9890),
            CantonInfo(nombre: 'Cuenca (Baños)', latitud: -2.9231, longitud: -79.0562),
            CantonInfo(nombre: 'Gualaceo', latitud: -2.8894, longitud: -78.7811),
            CantonInfo(nombre: 'Paute', latitud: -2.7778, longitud: -78.7611),
            CantonInfo(nombre: 'Chordeleg', latitud: -2.9236, longitud: -78.7753),
            CantonInfo(nombre: 'Santa Isabel', latitud: -3.2750, longitud: -79.3167),
            CantonInfo(nombre: 'Girón', latitud: -3.1611, longitud: -79.1458),
            CantonInfo(nombre: 'Sigsig', latitud: -3.0500, longitud: -78.7833),
          ],
        ),
        ProvinciaInfo(
          nombre: 'Manabí',
          cantones: [
            CantonInfo(nombre: 'Manta (Tarqui / Murciélago)', latitud: -0.9538, longitud: -80.7089),
            CantonInfo(nombre: 'Portoviejo', latitud: -1.0544, longitud: -80.4544),
            CantonInfo(nombre: 'Montecristi', latitud: -1.0478, longitud: -80.6583),
            CantonInfo(nombre: 'Chone', latitud: -0.6981, longitud: -80.0936),
            CantonInfo(nombre: 'Bahía de Caráquez (Sucre)', latitud: -0.6000, longitud: -80.4242),
            CantonInfo(nombre: 'Jipijapa', latitud: -1.3494, longitud: -80.5786),
            CantonInfo(nombre: 'Pedernales', latitud: 0.0717, longitud: -80.0525),
            CantonInfo(nombre: 'Puerto López', latitud: -1.5647, longitud: -80.8122),
            CantonInfo(nombre: 'El Carmen', latitud: -0.2714, longitud: -79.4625),
            CantonInfo(nombre: 'Santa Ana', latitud: -1.2064, longitud: -80.3719),
          ],
        ),
        ProvinciaInfo(
          nombre: 'Tungurahua',
          cantones: [
            CantonInfo(nombre: 'Ambato (Ficoa / Centro)', latitud: -1.2491, longitud: -78.6168),
            CantonInfo(nombre: 'Baños de Agua Santa', latitud: -1.3964, longitud: -78.4239),
            CantonInfo(nombre: 'Pelileo', latitud: -1.3303, longitud: -78.5447),
            CantonInfo(nombre: 'Píllaro', latitud: -1.1739, longitud: -78.5367),
            CantonInfo(nombre: 'Cevallos', latitud: -1.3556, longitud: -78.6167),
            CantonInfo(nombre: 'Patate', latitud: -1.3117, longitud: -78.5117),
          ],
        ),
        ProvinciaInfo(
          nombre: 'Imbabura',
          cantones: [
            CantonInfo(nombre: 'Ibarra (Centro / Yahuarcocha)', latitud: 0.3517, longitud: -78.1222),
            CantonInfo(nombre: 'Otavalo (Plaza de Ponchos)', latitud: 0.2344, longitud: -78.2622),
            CantonInfo(nombre: 'Cotacachi', latitud: 0.3014, longitud: -78.2636),
            CantonInfo(nombre: 'Antonio Ante (Atuntaqui)', latitud: 0.3314, longitud: -78.2144),
            CantonInfo(nombre: 'Pimampiro', latitud: 0.3958, longitud: -77.9403),
            CantonInfo(nombre: 'Urcuquí', latitud: 0.4189, longitud: -78.1889),
          ],
        ),
        ProvinciaInfo(
          nombre: 'Loja',
          cantones: [
            CantonInfo(nombre: 'Loja (Centro / San Sebastián)', latitud: -3.9931, longitud: -79.2042),
            CantonInfo(nombre: 'Catamayo', latitud: -3.9875, longitud: -79.3564),
            CantonInfo(nombre: 'Vilcabamba', latitud: -4.2600, longitud: -79.2225),
            CantonInfo(nombre: 'Saraguro', latitud: -3.6219, longitud: -79.2372),
            CantonInfo(nombre: 'Cariamanga (Calvas)', latitud: -4.3319, longitud: -79.5550),
            CantonInfo(nombre: 'Catacocha (Paltas)', latitud: -4.0531, longitud: -79.6483),
          ],
        ),
        ProvinciaInfo(
          nombre: 'El Oro',
          cantones: [
            CantonInfo(nombre: 'Machala (Puerto Bolívar / Centro)', latitud: -3.2586, longitud: -79.9556),
            CantonInfo(nombre: 'Pasaje', latitud: -3.3267, longitud: -79.8067),
            CantonInfo(nombre: 'Santa Rosa', latitud: -3.4486, longitud: -79.9597),
            CantonInfo(nombre: 'Huaquillas (Frontera)', latitud: -3.4753, longitud: -80.2311),
            CantonInfo(nombre: 'Zaruma', latitud: -3.6917, longitud: -79.6125),
            CantonInfo(nombre: 'Piñas', latitud: -3.6806, longitud: -79.6833),
          ],
        ),
        ProvinciaInfo(
          nombre: 'Santo Domingo de los Tsáchilas',
          cantones: [
            CantonInfo(nombre: 'Santo Domingo (Centro / Chiguilpe)', latitud: -0.2530, longitud: -79.1754),
            CantonInfo(nombre: 'La Concordia', latitud: 0.0050, longitud: -79.3950),
          ],
        ),
        ProvinciaInfo(
          nombre: 'Santa Elena',
          cantones: [
            CantonInfo(nombre: 'Salinas (Chipipe / San Lorenzo)', latitud: -2.2239, longitud: -80.9583),
            CantonInfo(nombre: 'Santa Elena (Cabecera)', latitud: -2.2267, longitud: -80.8583),
            CantonInfo(nombre: 'La Libertad', latitud: -2.2333, longitud: -80.9000),
            CantonInfo(nombre: 'Montañita / Olón', latitud: -1.8286, longitud: -80.7533),
          ],
        ),
        ProvinciaInfo(
          nombre: 'Cotopaxi',
          cantones: [
            CantonInfo(nombre: 'Latacunga (Centro)', latitud: -0.9333, longitud: -78.6167),
            CantonInfo(nombre: 'Salcedo', latitud: -1.0456, longitud: -78.5908),
            CantonInfo(nombre: 'Pujilí', latitud: -0.9575, longitud: -78.6967),
            CantonInfo(nombre: 'La Maná', latitud: -0.9408, longitud: -79.2247),
            CantonInfo(nombre: 'Saquisilí', latitud: -0.8358, longitud: -78.6669),
          ],
        ),
        ProvinciaInfo(
          nombre: 'Chimborazo',
          cantones: [
            CantonInfo(nombre: 'Riobamba (Centro / Bellavista)', latitud: -1.6709, longitud: -78.6472),
            CantonInfo(nombre: 'Guano', latitud: -1.6067, longitud: -78.6342),
            CantonInfo(nombre: 'Alausi', latitud: -2.2039, longitud: -78.8475),
            CantonInfo(nombre: 'Chambo', latitud: -1.7333, longitud: -78.5833),
            CantonInfo(nombre: 'Colta', latitud: -1.7167, longitud: -78.7500),
          ],
        ),
        ProvinciaInfo(
          nombre: 'Esmeraldas',
          cantones: [
            CantonInfo(nombre: 'Esmeraldas (Las Palmas)', latitud: 0.9592, longitud: -79.6539),
            CantonInfo(nombre: 'Atacames / Tonsupa', latitud: 0.8683, longitud: -79.8450),
            CantonInfo(nombre: 'Muisne', latitud: 0.6125, longitud: -80.0194),
            CantonInfo(nombre: 'Quinindé (Rosa Zárate)', latitud: 0.3283, longitud: -79.4678),
            CantonInfo(nombre: 'San Lorenzo', latitud: 1.2861, longitud: -78.8356),
          ],
        ),
        ProvinciaInfo(
          nombre: 'Los Ríos',
          cantones: [
            CantonInfo(nombre: 'Babahoyo', latitud: -1.8022, longitud: -79.5344),
            CantonInfo(nombre: 'Quevedo', latitud: -1.0286, longitud: -79.4636),
            CantonInfo(nombre: 'Vinces', latitud: -1.5564, longitud: -79.7517),
            CantonInfo(nombre: 'Ventanas', latitud: -1.4422, longitud: -79.4597),
            CantonInfo(nombre: 'Buena Fe', latitud: -0.8931, longitud: -79.4900),
          ],
        ),
        ProvinciaInfo(
          nombre: 'Carchi',
          cantones: [
            CantonInfo(nombre: 'Tulcán (Frontera Rumichaca)', latitud: 0.8117, longitud: -77.7178),
            CantonInfo(nombre: 'San Gabriel (Montúfar)', latitud: 0.5922, longitud: -77.8306),
            CantonInfo(nombre: 'Mira', latitud: 0.5500, longitud: -78.0400),
            CantonInfo(nombre: 'Bolívar', latitud: 0.5014, longitud: -77.9042),
          ],
        ),
        ProvinciaInfo(
          nombre: 'Bolívar',
          cantones: [
            CantonInfo(nombre: 'Guaranda', latitud: -1.5928, longitud: -79.0044),
            CantonInfo(nombre: 'San Miguel', latitud: -1.7083, longitud: -79.0433),
            CantonInfo(nombre: 'Caluma', latitud: -1.6256, longitud: -79.2553),
            CantonInfo(nombre: 'Chimbo', latitud: -1.6500, longitud: -79.0333),
          ],
        ),
        ProvinciaInfo(
          nombre: 'Cañar',
          cantones: [
            CantonInfo(nombre: 'Azogues', latitud: -2.7397, longitud: -78.8472),
            CantonInfo(nombre: 'Cañar (Ingapirca)', latitud: -2.5583, longitud: -78.9333),
            CantonInfo(nombre: 'La Troncal', latitud: -2.4239, longitud: -79.3364),
            CantonInfo(nombre: 'Biblián', latitud: -2.7117, longitud: -78.8917),
          ],
        ),
        ProvinciaInfo(
          nombre: 'Pastaza',
          cantones: [
            CantonInfo(nombre: 'Puyo (Pastaza)', latitud: -1.4883, longitud: -77.9983),
            CantonInfo(nombre: 'Mera', latitud: -1.4600, longitud: -78.1100),
            CantonInfo(nombre: 'Santa Clara', latitud: -1.2667, longitud: -77.8833),
          ],
        ),
        ProvinciaInfo(
          nombre: 'Morona Santiago',
          cantones: [
            CantonInfo(nombre: 'Macas (Morona)', latitud: -2.3083, longitud: -78.1167),
            CantonInfo(nombre: 'Sucúa', latitud: -2.4556, longitud: -78.1722),
            CantonInfo(nombre: 'Gualaquiza', latitud: -3.4039, longitud: -78.5800),
          ],
        ),
        ProvinciaInfo(
          nombre: 'Napo',
          cantones: [
            CantonInfo(nombre: 'Tena', latitud: -0.9939, longitud: -77.8128),
            CantonInfo(nombre: 'Archidona', latitud: -0.9100, longitud: -77.8083),
            CantonInfo(nombre: 'El Chaco', latitud: -0.3347, longitud: -77.8081),
            CantonInfo(nombre: 'Baeza (Quijos)', latitud: -0.4617, longitud: -77.8903),
          ],
        ),
        ProvinciaInfo(
          nombre: 'Orellana',
          cantones: [
            CantonInfo(nombre: 'Puerto Francisco de Orellana (Coca)', latitud: -0.4664, longitud: -76.9875),
            CantonInfo(nombre: 'La Joya de los Sachas', latitud: -0.2986, longitud: -76.8572),
            CantonInfo(nombre: 'Loreto', latitud: -0.6869, longitud: -77.3092),
          ],
        ),
        ProvinciaInfo(
          nombre: 'Sucumbíos',
          cantones: [
            CantonInfo(nombre: 'Nueva Loja (Lago Agrio)', latitud: 0.0847, longitud: -76.8828),
            CantonInfo(nombre: 'Shushufindi', latitud: -0.1833, longitud: -76.6500),
            CantonInfo(nombre: 'Cascales', latitud: 0.1667, longitud: -77.1667),
          ],
        ),
        ProvinciaInfo(
          nombre: 'Zamora Chinchipe',
          cantones: [
            CantonInfo(nombre: 'Zamora', latitud: -4.0667, longitud: -78.9500),
            CantonInfo(nombre: 'Yantzaza', latitud: -3.8317, longitud: -78.7611),
            CantonInfo(nombre: 'El Pangui', latitud: -3.6267, longitud: -78.5850),
          ],
        ),
        ProvinciaInfo(
          nombre: 'Galápagos',
          cantones: [
            CantonInfo(nombre: 'Santa Cruz (Puerto Ayora)', latitud: -0.7432, longitud: -90.3138),
            CantonInfo(nombre: 'San Cristóbal (Puerto Baquerizo Moreno)', latitud: -0.9025, longitud: -89.6106),
            CantonInfo(nombre: 'Isabela (Puerto Villamil)', latitud: -0.9556, longitud: -90.9667),
          ],
        ),
      ],
    ),
    PaisInfo(
      id: 'CO',
      nombre: 'Colombia',
      bandera: '🇨🇴',
      codigoTelefonico: '+57',
      provincias: [
        ProvinciaInfo(
          nombre: 'Bogotá D.C.',
          cantones: [
            CantonInfo(nombre: 'Bogotá (Centro)', latitud: 4.6097, longitud: -74.0817),
            CantonInfo(nombre: 'Bogotá (Chapinero)', latitud: 4.6483, longitud: -74.0628),
            CantonInfo(nombre: 'Bogotá (Usaquén)', latitud: 4.7016, longitud: -74.0305),
            CantonInfo(nombre: 'Bogotá (Suba)', latitud: 4.7439, longitud: -74.0844),
          ],
        ),
        ProvinciaInfo(
          nombre: 'Antioquia',
          cantones: [
            CantonInfo(nombre: 'Medellín (El Poblado)', latitud: 6.2088, longitud: -75.5684),
            CantonInfo(nombre: 'Medellín (Laureles)', latitud: 6.2443, longitud: -75.5906),
            CantonInfo(nombre: 'Envigado', latitud: 6.1689, longitud: -75.5806),
            CantonInfo(nombre: 'Bello', latitud: 6.3373, longitud: -75.5579),
            CantonInfo(nombre: 'Rionegro', latitud: 6.1539, longitud: -75.3742),
          ],
        ),
        ProvinciaInfo(
          nombre: 'Valle del Cauca',
          cantones: [
            CantonInfo(nombre: 'Cali (Granada / San Antonio)', latitud: 3.4516, longitud: -76.5320),
            CantonInfo(nombre: 'Palmira', latitud: 3.5394, longitud: -76.3036),
            CantonInfo(nombre: 'Yumbo', latitud: 3.5822, longitud: -76.4958),
            CantonInfo(nombre: 'Buenaventura', latitud: 3.8833, longitud: -77.0333),
          ],
        ),
        ProvinciaInfo(
          nombre: 'Nariño',
          cantones: [
            CantonInfo(nombre: 'Pasto (Centro)', latitud: 1.2136, longitud: -77.2811),
            CantonInfo(nombre: 'Ipiales (Frontera)', latitud: 0.8297, longitud: -77.6439),
            CantonInfo(nombre: 'Tumaco', latitud: 1.7986, longitud: -78.8156),
          ],
        ),
      ],
    ),
    PaisInfo(
      id: 'PE',
      nombre: 'Perú',
      bandera: '🇵🇪',
      codigoTelefonico: '+51',
      provincias: [
        ProvinciaInfo(
          nombre: 'Lima',
          cantones: [
            CantonInfo(nombre: 'Lima (Miraflores)', latitud: -12.1217, longitud: -77.0297),
            CantonInfo(nombre: 'Lima (San Isidro)', latitud: -12.0978, longitud: -77.0353),
            CantonInfo(nombre: 'Lima (Santiago de Surco)', latitud: -12.1389, longitud: -76.9944),
            CantonInfo(nombre: 'Lima (Barranco)', latitud: -12.1492, longitud: -77.0211),
            CantonInfo(nombre: 'Lima (Centro Histórico)', latitud: -12.0464, longitud: -77.0428),
          ],
        ),
        ProvinciaInfo(
          nombre: 'Arequipa',
          cantones: [
            CantonInfo(nombre: 'Arequipa (Centro)', latitud: -16.4090, longitud: -71.5375),
            CantonInfo(nombre: 'Yanahuara', latitud: -16.3889, longitud: -71.5417),
            CantonInfo(nombre: 'Cayma', latitud: -16.3750, longitud: -71.5472),
          ],
        ),
        ProvinciaInfo(
          nombre: 'Cusco',
          cantones: [
            CantonInfo(nombre: 'Cusco (Centro Histórico)', latitud: -13.5319, longitud: -71.9675),
            CantonInfo(nombre: 'Wanchaq', latitud: -13.5256, longitud: -71.9567),
            CantonInfo(nombre: 'San Sebastián', latitud: -13.5289, longitud: -71.9286),
          ],
        ),
        ProvinciaInfo(
          nombre: 'Piura',
          cantones: [
            CantonInfo(nombre: 'Piura (Centro)', latitud: -5.1945, longitud: -80.6328),
            CantonInfo(nombre: 'Máncora', latitud: -4.1067, longitud: -81.0475),
            CantonInfo(nombre: 'Sullana', latitud: -4.9039, longitud: -80.6853),
            CantonInfo(nombre: 'Tumbes (Frontera)', latitud: -3.5669, longitud: -80.4515),
          ],
        ),
      ],
    ),
  ];

  static PaisInfo get ecuador => paises.firstWhere((p) => p.id == 'EC');

  /// Encuentra el cantón o ciudad más cercano en el catálogo para unas coordenadas dadas
  static CantonMatch encontrarCantonMasCercano(double lat, double lng) {
    CantonInfo? mejorCanton;
    ProvinciaInfo? mejorProvincia;
    PaisInfo? mejorPais;
    double menorDistancia = double.infinity;

    for (final pais in paises) {
      for (final prov in pais.provincias) {
        for (final canton in prov.cantones) {
          final dist = _calcularDistanciaHaversine(lat, lng, canton.latitud, canton.longitud);
          if (dist < menorDistancia) {
            menorDistancia = dist;
            mejorCanton = canton;
            mejorProvincia = prov;
            mejorPais = pais;
          }
        }
      }
    }

    return CantonMatch(
      pais: mejorPais ?? ecuador,
      provincia: mejorProvincia ?? ecuador.provincias.first,
      canton: mejorCanton ?? ecuador.provincias.first.cantones.first,
      distanciaKm: menorDistancia,
    );
  }

  static double _calcularDistanciaHaversine(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) * math.cos(lat2 * p) * (1 - math.cos((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a));
  }
}

class CantonMatch {
  final PaisInfo pais;
  final ProvinciaInfo provincia;
  final CantonInfo canton;
  final double distanciaKm;

  const CantonMatch({
    required this.pais,
    required this.provincia,
    required this.canton,
    required this.distanciaKm,
  });
}

class UbicacionReferencia {
  final String nombre;
  final String ciudad;
  final double latitud;
  final double longitud;

  const UbicacionReferencia({
    required this.nombre,
    required this.ciudad,
    required this.latitud,
    required this.longitud,
  });
}
