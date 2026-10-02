import re

with open('lib/screens/home_screen.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# Make sure flutter_map and latlong2 are imported
if "import 'package:flutter_map/flutter_map.dart';" not in code:
    code = "import 'package:flutter_map/flutter_map.dart';\n" + code
if "import 'package:latlong2/latlong2.dart';" not in code:
    code = "import 'package:latlong2/latlong2.dart';\n" + code

patt = r"GestureDetector\(\s*onTap:\s*\(\)\s*\{\s*final url = Uri\.parse\('https://www\.google\.com/maps/search[^}]+\}\s*\),"

mini_map = """// Minimapa insertado en detalles
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            height: 150,
                            width: double.infinity,
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(reporte.latitud, reporte.longitud),
                                initialZoom: 15.0,
                                interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.rescatapet_mobile',
                                ),
                                CircleLayer(
                                  circles: [
                                    CircleMarker(
                                      point: LatLng(reporte.latitud, reporte.longitud),
                                      radius: 200,
                                      useRadiusInMeter: true,
                                      color: AppTheme.primary.withValues(alpha: 0.2),
                                      borderColor: AppTheme.primary,
                                      borderStrokeWidth: 2,
                                    ),
                                  ],
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(reporte.latitud, reporte.longitud),
                                      width: 40, height: 40,
                                      child: const Icon(Icons.location_on, color: AppTheme.alertCoral, size: 40),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () async {
                            final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${reporte.latitud},${reporte.longitud}');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo abrir Maps')));
                            }
                          },
"""

code = re.sub(patt, mini_map, code)

with open('lib/screens/home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(code)

