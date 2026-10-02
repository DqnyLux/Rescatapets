import re
with open('lib/screens/home_screen.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# Add import
import_stmt = "import '../route_transitions.dart';\nimport '../widgets/reporte_image.dart';"
code = code.replace("import '../route_transitions.dart';", import_stmt)

# Replace _buildImageFromPath
replacement = """  Widget _buildImageFromPath(String pathOrUrl, {double? width, double? height, BoxFit fit = BoxFit.cover, bool ignorePlaceholder = false}) {
    if (pathOrUrl.trim().isEmpty || pathOrUrl.contains('unsplash.com') || pathOrUrl.contains('placeholder')) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Container(
        width: width, height: height,
        decoration: BoxDecoration(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
        child: Center(
          child: Icon(Icons.pets_rounded, size: 42, color: AppTheme.primaryLight.withValues(alpha: 0.7)),
        ),
      );
    }
    return ReporteImage(
      imagenData: pathOrUrl, 
      width: width ?? double.infinity, 
      height: height ?? double.infinity, 
      fit: fit
    );
  }"""
  
patt = r"  Widget _buildImageFromPath.*?\}\n    \}"
code = re.sub(patt, replacement, code, flags=re.DOTALL)

with open('lib/screens/home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(code)
