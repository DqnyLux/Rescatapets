import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

/// Datos del usuario autenticado en la sesión actual.
class SesionUsuario {
  final String token;
  final String nombre;
  final String email;

  const SesionUsuario({
    required this.token,
    required this.nombre,
    required this.email,
  });
}

/// Notifier que administra la sesión: login, registro, restauración y logout.
/// Persiste el token y datos básicos en flutter_secure_storage.
class AuthNotifier extends Notifier<SesionUsuario?> {
  static const _storage = FlutterSecureStorage();

  @override
  SesionUsuario? build() => null;

  /// Intenta restaurar la sesión guardada al abrir la app.
  Future<void> restaurarSesion() async {
    final token = await _storage.read(key: 'token');
    final nombre = await _storage.read(key: 'nombre');
    final email = await _storage.read(key: 'email');

    if (token != null && nombre != null && email != null) {
      state = SesionUsuario(token: token, nombre: nombre, email: email);
    }
  }

  /// Inicia sesión contra el backend y persiste los datos localmente.
  Future<void> iniciarSesion(String email, String password) async {
    final datos = await ApiService.login(email, password);

    await _storage.write(key: 'token', value: datos['token']);
    await _storage.write(key: 'nombre', value: datos['nombre']);
    await _storage.write(key: 'email', value: datos['email']);

    state = SesionUsuario(
      token: datos['token']!,
      nombre: datos['nombre']!,
      email: datos['email']!,
    );
  }

  /// Inicia sesión con Google (Social Auth) y persiste la sesión.
  Future<void> iniciarSesionConGoogle() async {
    // Simulamos autenticación OAuth 2.0 segura con Google
    await Future.delayed(const Duration(milliseconds: 600));
    const token = 'google_oauth_token_simulated_secure';
    const nombre = 'Usuario Google';
    const email = 'usuario.google@gmail.com';

    await _storage.write(key: 'token', value: token);
    await _storage.write(key: 'nombre', value: nombre);
    await _storage.write(key: 'email', value: email);

    state = const SesionUsuario(
      token: token,
      nombre: nombre,
      email: email,
    );
  }

  /// Registra un nuevo usuario, inicia sesión automáticamente y persiste.
  Future<void> registrarUsuario(String nombre, String email, String password) async {
    final datos = await ApiService.registro(nombre, email, password);

    await _storage.write(key: 'token', value: datos['token']);
    await _storage.write(key: 'nombre', value: datos['nombre']);
    await _storage.write(key: 'email', value: datos['email']);

    state = SesionUsuario(
      token: datos['token']!,
      nombre: datos['nombre']!,
      email: datos['email']!,
    );
  }

  /// Cierra la sesión por completo: borra storage y resetea estado.
  Future<void> cerrarSesion() async {
    await _storage.deleteAll();
    state = null;
  }
}

/// Provider global de la sesión del usuario.
final authProvider = NotifierProvider<AuthNotifier, SesionUsuario?>(() {
  return AuthNotifier();
});
