import re

with open('lib/models/reporte.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# Delete the mock data block
patt = r"    final coordenadas = \[[\s\S]*?final tipos = \[[\s\S]*?\];"
code = re.sub(patt, "", code)

with open('lib/models/reporte.dart', 'w', encoding='utf-8') as f:
    f.write(code)
