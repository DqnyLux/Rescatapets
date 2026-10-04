import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/api_service.dart';

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

class AuthNotifier extends Notifier<SesionUsuario?> {
  static const _storage = FlutterSecureStorage();

  @override
  SesionUsuario? build() => null;

  Future<void> restaurarSesion() async {
    final token = await _storage.read(key: 'token');
    final nombre = await _storage.read(key: 'nombre');
    final email = await _storage.read(key: 'email');

    if (token != null && nombre != null && email != null) {
      state = SesionUsuario(token: token, nombre: nombre, email: email);
    }
  }

  Future<void> iniciarSesion(String email, String password) async {
    // 1. Firebase Login
    final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // 2. Cargar token interno de nuestra API NodeJS para los Reportes
    final datos = await ApiService.firebaseSync(
      email: userCredential.user!.email!,
      nombre: userCredential.user!.displayName ?? 'Usuario',
    );

    await _guardarSesionLocal(datos);
  }

  Future<void> iniciarSesionConGoogle(String telefonoFaltante) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    
    if (googleUser == null) throw Exception('Google Sign-In cancelado por el usuario');
    
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    final datos = await ApiService.firebaseSync(
      email: userCredential.user!.email ?? googleUser.email,
      nombre: userCredential.user!.displayName ?? googleUser.displayName ?? 'Usuario Google',
      telefono: telefonoFaltante,
    );

    await _guardarSesionLocal(datos);
  }

  Future<void> iniciarSesionDemo() async {
    // Bypass total a firebase, entra directo con Node.js SQLite
    final datos = await ApiService.login('juan@test.com', '123456');
    await _guardarSesionLocal(datos);
  }

  Future<void> registrarUsuario(String nombre, String email, String password, String telefono) async {
    // 1. Registrar en Firebase Auth
    final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await userCredential.user?.updateDisplayName(nombre);

    // 2. Sincronizar inmediatamente en SQLite Node.js + Disparar correo de bienvenida
    final datos = await ApiService.firebaseSync(
      email: email,
      nombre: nombre,
      telefono: telefono,
    );

    await _guardarSesionLocal(datos);
  }

  Future<void> _guardarSesionLocal(Map<String, String> datos) async {
    await _storage.write(key: 'token', value: datos['token']);
    await _storage.write(key: 'nombre', value: datos['nombre']);
    await _storage.write(key: 'email', value: datos['email']);

    state = SesionUsuario(
      token: datos['token']!,
      nombre: datos['nombre']!,
      email: datos['email']!,
    );
  }

  Future<void> cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    await _storage.deleteAll();
    state = null;
  }
}

final authProvider = NotifierProvider<AuthNotifier, SesionUsuario?>(() {
  return AuthNotifier();
});


