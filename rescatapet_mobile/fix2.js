const fs = require('fs');
let code = fs.readFileSync('lib/screens/home_screen.dart', 'utf8');

// Replace the buggy ElevatedButton inside Onboarding with clean NativeLocationService
const btnRegex1 = /ElevatedButton\.icon\([\s\S]*?minimumSize: const Size\.fromHeight\(50\),\n                \),\n              \),/;
const newBtn1 = `ElevatedButton.icon(
                onPressed: () async {
                  final result = await NativeLocationService.obtenerPosicionActual(context, mostrarDialogoPrevio: false);
                  if (result.estado == EstadoPermisoNativo.concedido && result.posicion != null) {
                    final addr = result.direccion?.direccionCompleta ?? 'GPS Location';
                    await _storage.write(key: 'userLat', value: result.posicion!.latitude.toString());
                    await _storage.write(key: 'userLng', value: result.posicion!.longitude.toString());
                    await _storage.write(key: 'userAddr', value: addr);
                    
                    if (mounted) {
                      setState(() {
                        _ubicacionUsuario = UbicacionReferencia(
                          nombre: addr, ciudad: result.direccion?.cantonOCiudad ?? '', latitud: result.posicion!.latitude, longitud: result.posicion!.longitude
                        );
                      });
                      Navigator.pop(ctx);
                      _cargarReportes();
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(result.mensaje)));
                    }
                  }
                },
                icon: const Icon(Icons.gps_fixed),
                label: const Text('Usar GPS Actual', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),`;

code = code.replace(btnRegex1, newBtn1);

// Replace the buggy ListTile inside BottomSheet
const listTileRegex = /ListTile\([\s\S]*?mapController\.move\(LatLng\(pos\.latitude, pos\.longitude\), 14\.0\);\n    \} catch\(e\) \{\}\n  \},\n\),/;

const newListTile = `ListTile(
  leading: const Icon(Icons.my_location, color: AppTheme.primary),
  title: const Text('Usar GPS Actual', style: TextStyle(fontWeight: FontWeight.bold)),
  onTap: () async {
    final result = await NativeLocationService.obtenerPosicionActual(context, mostrarDialogoPrevio: false);
    if (result.estado == EstadoPermisoNativo.concedido && result.posicion != null) {
      final addr = result.direccion?.direccionCompleta ?? 'GPS Actual';
      setModalState(() {
        tempLat = result.posicion!.latitude;
        tempLng = result.posicion!.longitude;
        tempNombre = addr;
        tempCiudad = result.direccion?.cantonOCiudad ?? '';
      });
      mapController.move(LatLng(result.posicion!.latitude, result.posicion!.longitude), 14.0);
    }
  },
),`;

code = code.replace(listTileRegex, newListTile);

fs.writeFileSync('lib/screens/home_screen.dart', code);
