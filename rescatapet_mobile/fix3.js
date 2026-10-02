const fs = require('fs');
let code = fs.readFileSync('lib/screens/home_screen.dart', 'utf8');

const ciudadesRegex = /List<UbicacionReferencia> _ciudadesEcuador = \[[\s\S]*?    \),\n  \];\n/;
code = code.replace(ciudadesRegex, '');
code = code.replace("bool _isLoadingLocation = true;", "");
code = code.replace("_isLoadingLocation = false;", "");
code = code.replace("_isLoadingLocation = false;", "");
code = code.replace("import 'package:geocoding/geocoding.dart' as geocoder;\n", "");
code = code.replace("import 'package:flutter_secure_storage/flutter_secure_storage.dart' as secure_storage;\n", "");
fs.writeFileSync('lib/screens/home_screen.dart', code);
