import re
with open('lib/screens/home_screen.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# Add a missing import if needed for base64
if "import 'dart:convert';" not in code:
    code = "import 'dart:convert';\n" + code

replace_old = """                            try {
                              await ApiService.crearReporte(
                                mascota: '$nombreMascota ($especieSeleccionada)',
                                ubicacion: lugarCompleto,
                                estado: 'PUBLICO',
                              );"""

replace_new = """                            try {
                              String? b64;
                              if (fotoSeleccionada != null) {
                                final bytes = await fotoSeleccionada!.readAsBytes();
                                b64 = 'data:image/jpeg;base64,' + base64Encode(bytes);
                              }
                              await ApiService.crearReporte(
                                mascota: nombreMascota,
                                especie: especieSeleccionada,
                                raza: razaCtrl.text.isEmpty ? 'Mestizo' : razaCtrl.text,
                                ciudad: cantonSeleccionado.nombre,
                                sector: sectorCtrl.text,
                                latitud: latitudReporte,
                                longitud: longitudReporte,
                                tipoAlerta: _tipoAlertaCreacion.codigo,
                                telefonoPrincipal: telCtrl.text,
                                tamano: tamanoSeleccionado,
                                sexo: sexoSeleccionado,
                                color: colorCtrl.text,
                                descripcion: descCtrl.text,
                                imagenBase64: b64 ?? (fotoSeleccionada?.path ?? ''),
                                ubicacion: lugarCompleto,
                                estado: 'PUBLICO',
                              );"""

code = code.replace(replace_old, replace_new)

with open('lib/screens/home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(code)
