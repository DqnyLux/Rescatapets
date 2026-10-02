/// Validación de cédula ecuatoriana usando el algoritmo Módulo 10.
///
/// Referencia: Registro Civil del Ecuador — estructura de 10 dígitos:
///   - Dígitos 1-2: código de provincia (01–24, o 30 para extranjeros)
///   - Dígito 3: tipo de documento (< 6 para persona natural)
///   - Dígitos 4-9: secuencia
///   - Dígito 10: verificador (mod 10)
class CedulaValidator {
  /// Retorna `null` si la cédula es válida, o un mensaje de error en español.
  static String? validar(String cedula) {
    final limpia = cedula.replaceAll(RegExp(r'\s'), '');

    if (limpia.isEmpty) return 'La cédula es obligatoria';
    if (!RegExp(r'^\d{10}$').hasMatch(limpia)) {
      return 'La cédula debe tener exactamente 10 dígitos numéricos';
    }

    final provincia = int.parse(limpia.substring(0, 2));
    if (provincia < 1 || (provincia > 24 && provincia != 30)) {
      return 'Código de provincia inválido ($provincia)';
    }

    final tercerDigito = int.parse(limpia[2]);
    if (tercerDigito >= 6) {
      return 'Tercer dígito inválido para persona natural';
    }

    // Algoritmo Módulo 10
    final coeficientes = [2, 1, 2, 1, 2, 1, 2, 1, 2];
    int suma = 0;
    for (int i = 0; i < 9; i++) {
      int valor = int.parse(limpia[i]) * coeficientes[i];
      if (valor > 9) valor -= 9;
      suma += valor;
    }

    final residuo = suma % 10;
    final digitoVerificador = residuo == 0 ? 0 : 10 - residuo;

    if (digitoVerificador != int.parse(limpia[9])) {
      return 'Cédula inválida (dígito verificador no coincide)';
    }

    return null; // válida
  }
}
