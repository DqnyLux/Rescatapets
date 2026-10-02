import re
with open('lib/screens/home_screen.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# Replace About Dialog
patt = r"showAboutDialog\([\s\S]*?\);"
replacement = """showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Row(children: [
                    Icon(Icons.pets, color: AppTheme.primary),
                    SizedBox(width: 8),
                    Text('Acerca de RescataPet EC')
                  ]),
                  content: Text('Aplicación móvil desarrollada con Flutter & Riverpod con geolocalización GPS, radar de cercanía y alertas comunitarias de rescate animal en Ecuador.\n\nVersión: 1.1.0\nHecho para proyecto universitario.', style: TextStyle(height: 1.5)),
                  actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cerrar'))]
                )
              );"""
code = re.sub(patt, replacement, code)

with open('lib/screens/home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(code)
