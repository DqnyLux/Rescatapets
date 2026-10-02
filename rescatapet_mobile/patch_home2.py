import re

with open('lib/screens/home_screen.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# Fix the GPS clipboard
patt = r"Clipboard\.setData\(ClipboardData\([\s\S]*?\)\);\s*ScaffoldMessenger\.of\(context\)\.showSnackBar\([\s\S]*?\}\);"
repl = """final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${reporte.latitud},${reporte.longitud}');
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                  }
                                }"""
code = re.sub(patt, repl, code)

# Edit the form submit to use base64
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
                                especie: especieSeleccionada,
                                raza: razaCtrl.text.isEmpty ? 'Mestizo' : razaCtrl.text,
                                ciudad: cantonSeleccionado.nombre,
                                sector: sector,
                                latitud: latitudReporte,
                                longitud: longitudReporte,
                                tipoAlerta: tipoSeleccionado.codigo,
                                telefonoPrincipal: telP,
                                tamano: tamanoSeleccionado,
                                sexo: sexoSeleccionado,
                                color: colorCtrl.text,
                                descripcion: descCtrl.text,
                                imagenBase64: b64 ?? imagenSeleccionada,
                                ubicacion: lugarCompleto,
                                estado: 'PUBLICO',
                              );
                            }"""

code = re.sub(patt_api, replacement_api, code)

with open('lib/screens/home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(code)
