import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("No se pudo cargar el archivo .env: $e");
  }
  runApp(const ProviderScope(child: RescataPetApp()));
}

class RescataPetApp extends ConsumerStatefulWidget {
  const RescataPetApp({super.key});

  @override
  ConsumerState<RescataPetApp> createState() => _RescataPetAppState();
}

class _RescataPetAppState extends ConsumerState<RescataPetApp> {
  @override
  void initState() {
    super.initState();
    // Restaurar sesión guardada en storage al iniciar la app
    Future.microtask(() {
      ref.read(authProvider.notifier).restaurarSesion();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'RescataPet EC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
