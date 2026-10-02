import re

with open('lib/screens/home_screen.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# Get the _mostrarDetalleMascota function approximately
start_idx = code.find('void _mostrarDetalleMascota')
end_idx = code.find('void _mostrarBuscadorGlobal', start_idx)

details_body = code[start_idx:end_idx]

# We need to insert a grid or chips showing: Especie, Raza, Sexo, Tamaño, Color
# Let's see if we can insert it just before 'Radar de Geolocalización Exacta'
insertion_point = details_body.find('// Radar de Geolocalización Exacta')

if insertion_point != -1 and 'reporte.sexo' not in details_body:
    chips_html = """// Características de la mascota
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildMiniBadge(Icons.pets, '${reporte.especie} ${reporte.raza}', isDark),
                      _buildMiniBadge(Icons.male, reporte.sexo, isDark),
                      _buildMiniBadge(Icons.straighten, reporte.tamano, isDark),
                      _buildMiniBadge(Icons.color_lens, reporte.color, isDark),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  """
    
    details_body = details_body[:insertion_point] + chips_html + details_body[insertion_point:]
    
    # We also need to add the _buildMiniBadge helper inside _HomeScreenState if it doesn't exist
    if '_buildMiniBadge' not in code:
        mini_badge = """
  Widget _buildMiniBadge(IconData icon, String text, bool isDark) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryLight),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
"""
        code = code.replace("void _mostrarDetalleMascota", mini_badge + "\  void _mostrarDetalleMascota")

code = code[:start_idx] + details_body + code[end_idx:]

with open('lib/screens/home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(code)

