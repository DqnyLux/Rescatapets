import re

with open('lib/screens/home_screen.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# Base64 import
if "import 'dart:convert';" not in code:
    code = "import 'dart:convert';\n" + code
if "import 'dart:io';" not in code:
    code = "import 'dart:io';\n" + code

# Clean up about dialog
code = re.sub(r'showAboutDialog\([\s\S]*?\);', '''showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Row(children: [Icon(Icons.pets, color: AppTheme.primary), SizedBox(width: 8), Text('Acerca de RescataPet')]),
                  content: Text('Aplicación móvil desarrollada con Flutter & Riverpod con geolocalización GPS, radar de cercanía y alertas comunitarias.\n\nDesarrollada para proyecto universitario.', style: TextStyle(height: 1.5)),
                  actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cerrar'))]
                )
              );''', code)

with open('lib/screens/home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(code)
