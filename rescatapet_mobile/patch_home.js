const fs = require('fs');
let code = fs.readFileSync('lib/screens/home_screen.dart', 'utf8');

if (!code.includes('flutter_secure_storage')) {
    code = "import 'package:flutter_secure_storage/flutter_secure_storage.dart' as secure_storage;\n" + code;
}
if (!code.includes('package:geocoding/geocoding.dart')) {
    code = code.replace("import 'package:geolocator/geolocator.dart';", "import 'package:geolocator/geolocator.dart';\nimport 'package:geocoding/geocoding.dart' as geocoding;");
}

code = code.replace(/final _storage = const flutter_secure_storage\.FlutterSecureStorage\(\);/, 'final _storage = const secure_storage.FlutterSecureStorage();');

code = code.replace(/package_geocoding/g, 'geocoding');

code = code.replace(/ciudad: p\.locality/g, "ciudad: placemarks.first.locality");

// remove hardcoded _ciudadesEcuador usage in _mostrarSelectorUbicacionUsuario
const sheetListRegex = /\.\.\._ciudadesEcuador\.map\(\(ubi\) \{[\s\S]*?\}\),\n/;
code = code.replace(sheetListRegex, `ListTile(
  leading: const Icon(Icons.my_location, color: AppTheme.primary),
  title: const Text('Usar GPS Actual', style: TextStyle(fontWeight: FontWeight.bold)),
  onTap: () async {
    try {
      final pos = await NativeServices.initLocationService();
      final pm = await geocoding.placemarkFromCoordinates(pos.latitude, pos.longitude);
      String addr = 'GPS Actual';
      if (pm.isNotEmpty) {
        addr = "\${pm.first.locality ?? ''}, \${pm.first.subLocality ?? ''}";
      }
      setModalState(() {
        tempLat = pos.latitude;
        tempLng = pos.longitude;
        tempNombre = addr;
        tempCiudad = pm.isNotEmpty ? pm.first.locality ?? '' : '';
      });
      mapController.move(latLong.LatLng(pos.latitude, pos.longitude), 14.0);
    } catch(e) {}
  },
),`);

fs.writeFileSync('lib/screens/home_screen.dart', code);
