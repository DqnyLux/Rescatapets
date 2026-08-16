import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/reporte.dart';

class ApiService {
  static String get baseUrl {
    return dotenv.env['API_URL'] ?? 'http://10.0.2.2:3000/api';
  }

  static Future<List<Reporte>> fetchReportesPublicos() async {
    final url = Uri.parse('$baseUrl/reportes/publicos');

    try {
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Reporte.fromJson(json)).toList();
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fallo al conectar con la API ($baseUrl): $e');
    }
  }

  static Future<void> crearReporte({
    required String mascota,
    required String ubicacion,
    required String estado,
  }) async {
    final url = Uri.parse('$baseUrl/reportes/publicos');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mascota': mascota,
          'ubicacion': ubicacion,
          'estado': estado,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Error al guardar reporte: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fallo al conectar con la API para publicar: $e');
    }
  }

  static Future<String> login(String email) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'] as String;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Error de autenticación');
      }
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }
}
