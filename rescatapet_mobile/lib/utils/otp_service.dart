import 'dart:math';

/// Servicio simulado de verificación OTP por SMS.
///
/// Para un proyecto universitario, genera el código localmente y lo muestra
/// en un diálogo en vez de enviar un SMS real (no hay proveedor Twilio/SNS
/// configurado). En producción se reemplazaría por una llamada al backend
/// que dispare el SMS vía pasarela.
class OtpService {
  static String? _codigoActual;
  static DateTime? _expiracion;

  /// Genera un código OTP de 6 dígitos con expiración de 3 minutos.
  /// Retorna el código generado (para mostrarlo en el diálogo demo).
  static String generarCodigo() {
    final random = Random.secure();
    _codigoActual = (100000 + random.nextInt(900000)).toString();
    _expiracion = DateTime.now().add(const Duration(minutes: 3));
    return _codigoActual!;
  }

  /// Valida el código ingresado por el usuario.
  /// Retorna `null` si es correcto, o un mensaje de error.
  static String? verificar(String codigoIngresado) {
    if (_codigoActual == null || _expiracion == null) {
      return 'No se ha generado un código. Solicita uno nuevo.';
    }
    if (DateTime.now().isAfter(_expiracion!)) {
      _codigoActual = null;
      _expiracion = null;
      return 'El código ha expirado. Solicita uno nuevo.';
    }
    if (codigoIngresado.trim() != _codigoActual) {
      return 'Código incorrecto. Intenta de nuevo.';
    }

    // Código válido — limpiar
    _codigoActual = null;
    _expiracion = null;
    return null;
  }
}
