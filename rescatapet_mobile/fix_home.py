import re

with open('lib/screens/home_screen.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# 1. Base64 encode import
if "import 'dart:convert';" not in code:
    code = "import 'dart:convert';\n" + code
if "import 'dart:io';" not in code:
    code = "import 'dart:io';\n" + code
if "import '../widgets/reporte_image.dart';" not in code:
    code = "import '../widgets/reporte_image.dart';\n" + code

# 2. Fix the Image method
patt_image = r"  Widget _buildImageFromPath.*?\}\n    \}"
replacement_image = """  Widget _buildImageFromPath(String pathOrUrl, {double? width, double? height, BoxFit fit = BoxFit.cover, bool ignorePlaceholder = false}) {
    return ReporteImage(
      imagenData: pathOrUrl, 
      width: width ?? double.infinity, 
      height: height ?? double.infinity, 
      fit: fit
    );
  }"""
code = re.sub(patt_image, replacement_image, code, flags=re.DOTALL)

# 3. Add base64 logic to form submit
patt_api = r"""                            try \{\s*await ApiService\.crearReporte\(\s*mascota: '\$nombreMascota \(\$especieSeleccionada\)',\s*ubicacion: lugarCompleto,\s*estado: 'PUBLICO',\s*\);\s*\}"""

replacement_api = """                            try {
                              String? b64;
                              if (imagenSeleccionada.isNotEmpty && !imagenSeleccionada.startsWith('http')) {
                                try {
                                  final bytes = await File(imagenSeleccionada).readAsBytes();
                                  b64 = 'data:image/jpeg;base64,' + base64Encode(bytes);
                                } catch(_) {}
                              }
                              await ApiService.crearReporte(
                                mascota: nombreMascota,
                                ubicacion: lugarCompleto,
                                estado: 'PUBLICO',
                                especie: especieSeleccionada,
                                raza: razaCtrl.text.trim().isEmpty ? 'Mestizo' : razaCtrl.text.trim(),
                                ciudad: cantonSeleccionado.nombre,
                                sector: sector,
                                latitud: latitudReporte,
                                longitud: longitudReporte,
                                tipoAlerta: tipoSeleccionado.codigo,
                                telefonoPrincipal: telP,
                                descripcion: descCtrl.text.trim(),
                                tamano: tamanoSeleccionado,
                                sexo: sexoSeleccionado,
                                color: colorCtrl.text.trim(),
                                imagenBase64: b64 ?? imagenSeleccionada,
                              );
                            }"""

code = re.sub(patt_api, replacement_api, code)

# 4. Remove large AboutDialog licenses
patt_about = r"showAboutDialog\([\s\S]*?\);"
replacement_about = """showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Row(children: [
                    Icon(Icons.pets, color: AppTheme.primary),
                    SizedBox(width: 8),
                    Text('Acerca de RescataPet')
                  ]),
                  content: const Text(
                    'Aplicación móvil desarrollada con Flutter & Riverpod con geolocalización GPS, radar de cercanía y alertas comunitarias de rescate animal en Ecuador.\n\nVersión: 1.1.0\nDesarrollada para proyecto universitario.',
                    style: TextStyle(height: 1.5)
                  ),
                  actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar'))]
                )
              );"""
code = re.sub(patt_about, replacement_about, code)

with open('lib/screens/home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(code)

