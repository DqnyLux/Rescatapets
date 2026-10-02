import re

with open('lib/screens/home_screen.dart', 'r', encoding='utf-8') as f:
    code = f.read()

patt = r"TextField\(\s*controller: razaCtrl,[\s\S]*?const SizedBox\(height: 12\),"
repl = """TextField(
                        controller: razaCtrl,
                        decoration: const InputDecoration(labelText: 'Raza', hintText: 'ej. Mestizo, Golden, Siamés', prefixIcon: Icon(Icons.style_rounded)),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: sexoSeleccionado,
                              dropdownColor: isDark ? AppTheme.cardDark : Colors.white,
                              style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark, fontSize: 13),
                              decoration: const InputDecoration(labelText: 'Sexo', prefixIcon: Icon(Icons.transgender_rounded)),
                              items: const [
                                DropdownMenuItem(value: 'Macho', child: Text('Macho')),
                                DropdownMenuItem(value: 'Hembra', child: Text('Hembra')),
                                DropdownMenuItem(value: 'Desconocido', child: Text('Desconocido')),
                              ],
                              onChanged: (val) => setModalState(() => sexoSeleccionado = val!),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: colorCtrl,
                              decoration: const InputDecoration(labelText: 'Color / Marcas', hintText: 'ej. Negro con pecho blanco', prefixIcon: Icon(Icons.color_lens_rounded)),
                            ),
                          ),
                        ]
                      ),
                      const SizedBox(height: 12),"""

code = re.sub(patt, repl, code)

with open('lib/screens/home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(code)
