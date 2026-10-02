const fs = require('fs');
let code = fs.readFileSync('lib/screens/home_screen.dart', 'utf8');

// Add imports
code = code.replace(
  "import '../models/geografia.dart';",
  "import '../models/geografia.dart';\nimport 'package:flutter_secure_storage/flutter_secure_storage.dart';\nimport 'package:geocoding/geocoding.dart' as geocoder;"
);

// Delete _ciudadesEcuador
const ciudadesRegex = /final List<UbicacionReferencia> _ciudadesEcuador = const \[[\s\S]*?\];/;
code = code.replace(ciudadesRegex, '');

// Update state to use storage
const initStateRegex = /late UbicacionReferencia _ubicacionUsuario;\n\n  @override\n  void initState\(\) \{\n    super\.initState\(\);\n    _ubicacionUsuario = _ciudadesEcuador\[0\]; \/\/ Quito La Carolina por defecto\n    _cargarReportes\(\);\n  \}/;

const newInitState = `late UbicacionReferencia _ubicacionUsuario;
  final _storage = const FlutterSecureStorage();
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _ubicacionUsuario = const UbicacionReferencia(nombre: 'GPS', ciudad: '', latitud: -0.1807, longitud: -78.4842);
    _initLocation();
  }

  Future<void> _initLocation() async {
    final latStr = await _storage.read(key: 'userLat');
    final lngStr = await _storage.read(key: 'userLng');
    final addrStr = await _storage.read(key: 'userAddr');

    if (latStr != null && lngStr != null && addrStr != null) {
      if (mounted) {
        setState(() {
          _ubicacionUsuario = UbicacionReferencia(
            nombre: addrStr,
            ciudad: addrStr.split(',').first,
            latitud: double.parse(latStr),
            longitud: double.parse(lngStr)
          );
          _isLoadingLocation = false;
        });
        _cargarReportes();
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mostrarOnboardingUbicacion();
        });
      }
    }
  }

  void _mostrarOnboardingUbicacion() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on_rounded, size: 48, color: AppTheme.primary),
              const SizedBox(height: 16),
              const Text(
                'Ubicación Inicial',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Por favor, establece tu ubicación de cobertura para ver las mascotas perdidas y en adopción cerca de ti.',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final pos = await NativeServices.initLocationService();
                    final placemarks = await geocoder.placemarkFromCoordinates(pos.latitude, pos.longitude);
                    String addr = 'GPS Location';
                    if (placemarks.isNotEmpty) {
                      final p = placemarks.first;
                      addr = "\${p.locality ?? ''}, \${p.subLocality ?? ''}";
                    }
                    await _storage.write(key: 'userLat', value: pos.latitude.toString());
                    await _storage.write(key: 'userLng', value: pos.longitude.toString());
                    await _storage.write(key: 'userAddr', value: addr);
                    
                    if (mounted) {
                      setState(() {
                        _ubicacionUsuario = UbicacionReferencia(
                          nombre: addr, ciudad: placemarks.isNotEmpty ? placemarks.first.locality ?? '' : '', latitud: pos.latitude, longitud: pos.longitude
                        );
                      });
                      Navigator.pop(ctx);
                      _cargarReportes();
                    }
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: \$e')));
                  }
                },
                icon: const Icon(Icons.gps_fixed),
                label: const Text('Usar GPS Actual'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          )
        );
      }
    );
  }`;

code = code.replace(initStateRegex, newInitState);

// Replace the _ciudadesEcuador mapping inside bottom sheet with a simple GPS tile
const sheetListRegex = /\.\.\._ciudadesEcuador\.map\(\(ubi\) \{[\s\S]*?\}\),\n/;
code = code.replace(sheetListRegex, `ListTile(
  leading: const Icon(Icons.my_location, color: AppTheme.primary),
  title: const Text('Usar GPS Actual', style: TextStyle(fontWeight: FontWeight.bold)),
  onTap: () async {
    try {
      final pos = await NativeServices.initLocationService();
      final pm = await geocoder.placemarkFromCoordinates(pos.latitude, pos.longitude);
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
      mapController.move(LatLng(pos.latitude, pos.longitude), 14.0);
    } catch(e) {}
  },
),`);

fs.writeFileSync('lib/screens/home_screen.dart', code);
