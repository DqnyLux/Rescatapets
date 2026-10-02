import re

with open('lib/screens/home_screen.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# Replace clipboard interaction with Google Maps
patt = r"Clipboard\.setData\(ClipboardData\([\s\S]*?'Coordenadas GPS copiadas al portapapeles\.'\),[\s\S]*?\}\);"
repl = """final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${reporte.latitud},${reporte.longitud}');
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('No se pudo abrir Maps'))
                                    );
                                  }
                                }"""

code = re.sub(patt, repl, code)

# Look for another place if needed
patt_icon = r"const Icon\(Icons.copy_rounded, size: 14"
repl_icon = "const Icon(Icons.map_rounded, size: 14"

code = re.sub(patt_icon, repl_icon, code)
code = code.replace("'Copiar GPS'", "'Abrir Maps'")

with open('lib/screens/home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(code)

