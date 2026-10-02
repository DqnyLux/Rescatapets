import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/cedula_validator.dart';
import '../utils/otp_service.dart';

class RegistroScreen extends ConsumerStatefulWidget {
  const RegistroScreen({super.key});

  @override
  ConsumerState<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends ConsumerState<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _cedulaCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  bool _cargando = false;
  bool _ocultarPassword = true;
  bool _ocultarConfirm = true;
  String? _errorMensaje;

  // Estado de verificaciones
  bool _cedulaVerificada = false;
  bool _telefonoVerificado = false;
  bool _otpEnviado = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _telefonoCtrl.dispose();
    _cedulaCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  /// Valida la cédula en tiempo real con Módulo 10.
  void _verificarCedula() {
    final error = CedulaValidator.validar(_cedulaCtrl.text);
    setState(() {
      _cedulaVerificada = (error == null);
      if (error != null) _errorMensaje = error;
      if (error == null) _errorMensaje = null;
    });
  }

  /// Genera y muestra el código OTP (simulado para demo universitario).
  void _enviarCodigoSMS() {
    final tel = _telefonoCtrl.text.trim();
    if (tel.length < 9) {
      setState(() => _errorMensaje = 'Ingresa un número de teléfono válido');
      return;
    }
    final codigo = OtpService.generarCodigo();
    setState(() {
      _otpEnviado = true;
      _errorMensaje = null;
    });

    // En una app real, aquí se llamaría al backend para enviar SMS vía Twilio/SNS.
    // Para el demo universitario, mostramos el código en un diálogo.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.sms_rounded, color: AppTheme.primary),
            SizedBox(width: 10),
            Text('Código SMS', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'En un entorno de producción, este código se enviaría por SMS al número registrado.\n\nPara demo académico, tu código es:',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
              ),
              child: Text(
                codigo,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 8,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Expira en 3 minutos',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  /// Verifica el código OTP ingresado.
  void _verificarOTP() {
    final error = OtpService.verificar(_otpCtrl.text);
    setState(() {
      if (error != null) {
        _errorMensaje = error;
      } else {
        _telefonoVerificado = true;
        _errorMensaje = null;
      }
    });
  }

  Future<void> _enviarFormulario() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_cedulaVerificada) {
      setState(() => _errorMensaje = 'Verifica tu cédula antes de continuar');
      return;
    }
    if (!_telefonoVerificado) {
      setState(() => _errorMensaje = 'Verifica tu número de teléfono con el código SMS');
      return;
    }

    setState(() {
      _cargando = true;
      _errorMensaje = null;
    });

    try {
      await ref.read(authProvider.notifier).registrarUsuario(
            _nombreCtrl.text.trim(),
            _emailCtrl.text.trim(),
            _passwordCtrl.text,
          );
    } catch (e) {
      setState(() {
        _errorMensaje = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _iniciarConGoogle() async {
    setState(() {
      _cargando = true;
      _errorMensaje = null;
    });

    try {
      await ref.read(authProvider.notifier).iniciarSesionConGoogle();
    } catch (e) {
      setState(() {
        _errorMensaje = 'Error al conectar con Google: $e';
      });
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFFFFF7ED), const Color(0xFFF8FAFC)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Brand Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.primaryGradientEnd],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_add_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Titles
                    Text(
                      'Crear Cuenta',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Únete a la red comunitaria de RescataPet EC',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Form Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Datos Personales',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Nombre
                              TextFormField(
                                controller: _nombreCtrl,
                                textInputAction: TextInputAction.next,
                                textCapitalization: TextCapitalization.words,
                                decoration: const InputDecoration(
                                  labelText: 'Nombre Completo',
                                  hintText: 'ej. María Pérez',
                                  prefixIcon: Icon(Icons.person_outline_rounded),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'El nombre es obligatorio';
                                  if (v.trim().length < 3) return 'Ingresa al menos 3 caracteres';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              // Cédula con verificación
                              TextFormField(
                                controller: _cedulaCtrl,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                maxLength: 10,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: InputDecoration(
                                  labelText: 'Cédula de Identidad',
                                  hintText: '1712345678',
                                  prefixIcon: const Icon(Icons.badge_outlined),
                                  counterText: '',
                                  suffixIcon: _cedulaVerificada
                                      ? const Icon(Icons.verified_rounded, color: AppTheme.successGreen)
                                      : IconButton(
                                          icon: const Icon(Icons.check_circle_outline, color: AppTheme.primary),
                                          onPressed: _verificarCedula,
                                          tooltip: 'Verificar cédula',
                                        ),
                                ),
                                onChanged: (_) {
                                  if (_cedulaVerificada) setState(() => _cedulaVerificada = false);
                                },
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'La cédula es obligatoria';
                                  return CedulaValidator.validar(v);
                                },
                              ),
                              if (_cedulaVerificada)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4, left: 4),
                                  child: Text(
                                    '✓ Cédula verificada correctamente',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.successGreen,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 14),

                              // Email
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Correo Electrónico',
                                  hintText: 'ej. maria@ejemplo.com',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'El correo es obligatorio';
                                  if (!RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(v.trim())) {
                                    return 'Ingresa un correo electrónico válido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              // Teléfono con envío de código
                              TextFormField(
                                controller: _telefonoCtrl,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                maxLength: 10,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: InputDecoration(
                                  labelText: 'Teléfono Celular',
                                  hintText: '0991234567',
                                  prefixIcon: const Icon(Icons.phone_android_rounded),
                                  prefixText: '+593 ',
                                  counterText: '',
                                  suffixIcon: _telefonoVerificado
                                      ? const Icon(Icons.verified_rounded, color: AppTheme.successGreen)
                                      : TextButton(
                                          onPressed: _enviarCodigoSMS,
                                          child: Text(
                                            _otpEnviado ? 'Reenviar' : 'Enviar código',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                ),
                                onChanged: (_) {
                                  if (_telefonoVerificado) {
                                    setState(() {
                                      _telefonoVerificado = false;
                                      _otpEnviado = false;
                                    });
                                  }
                                },
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'El teléfono es obligatorio';
                                  if (v.trim().length < 9) return 'Número de teléfono inválido';
                                  return null;
                                },
                              ),

                              // Campo OTP — visible solo tras enviar código y antes de verificar
                              if (_otpEnviado && !_telefonoVerificado) ...[
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _otpCtrl,
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.done,
                                        maxLength: 6,
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 6,
                                        ),
                                        decoration: const InputDecoration(
                                          labelText: 'Código de verificación',
                                          hintText: '000000',
                                          counterText: '',
                                          prefixIcon: Icon(Icons.pin_rounded),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: _verificarOTP,
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                        ),
                                        child: const Text('Verificar'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (_telefonoVerificado)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4, left: 4),
                                  child: Text(
                                    '✓ Teléfono verificado correctamente',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.successGreen,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 14),

                              // Password
                              TextFormField(
                                controller: _passwordCtrl,
                                obscureText: _ocultarPassword,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  labelText: 'Contraseña',
                                  hintText: 'Mínimo 6 caracteres',
                                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _ocultarPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                    ),
                                    onPressed: () => setState(() => _ocultarPassword = !_ocultarPassword),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'La contraseña es obligatoria';
                                  if (v.length < 6) return 'Mínimo 6 caracteres';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              // Confirm Password
                              TextFormField(
                                controller: _confirmCtrl,
                                obscureText: _ocultarConfirm,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _enviarFormulario(),
                                decoration: InputDecoration(
                                  labelText: 'Confirmar Contraseña',
                                  hintText: 'Repite tu contraseña',
                                  prefixIcon: const Icon(Icons.lock_rounded),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _ocultarConfirm
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                    ),
                                    onPressed: () => setState(() => _ocultarConfirm = !_ocultarConfirm),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Confirma tu contraseña';
                                  if (v != _passwordCtrl.text) return 'Las contraseñas no coinciden';
                                  return null;
                                },
                              ),

                              // Error Banner
                              if (_errorMensaje != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.alertCoral.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppTheme.alertCoral.withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline_rounded, color: AppTheme.alertCoral, size: 20),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _errorMensaje!,
                                          style: const TextStyle(
                                            color: AppTheme.alertCoral,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              // Verification status summary
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    _statusRow('Cédula verificada', _cedulaVerificada),
                                    const SizedBox(height: 6),
                                    _statusRow('Teléfono verificado', _telefonoVerificado),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Submit Button
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _cargando ? null : _enviarFormulario,
                                  child: _cargando
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                        )
                                      : const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.check_circle_outline_rounded, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              'Completar Registro',
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                                            ),
                                          ],
                                        ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Social Divider
                              Row(
                                children: [
                                  Expanded(child: Divider(color: isDark ? Colors.white12 : Colors.black12)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      'o regístrate con',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(child: Divider(color: isDark ? Colors.white12 : Colors.black12)),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Google Sign-In Button
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: OutlinedButton(
                                  onPressed: _cargando ? null : _iniciarConGoogle,
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                                    side: BorderSide(
                                      color: isDark ? Colors.white24 : const Color(0xFFE2E8F0),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                        alignment: Alignment.center,
                                        child: const Text(
                                          'G',
                                          style: TextStyle(
                                            color: Color(0xFF4285F4),
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Registrarse con Google',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? Colors.white : AppTheme.textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Back to Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿Ya tienes una cuenta? ',
                          style: TextStyle(
                            color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: const Text(
                            'Inicia sesión',
                            style: TextStyle(
                              color: AppTheme.primaryLight,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusRow(String label, bool ok) {
    return Row(
      children: [
        Icon(
          ok ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          size: 18,
          color: ok ? AppTheme.successGreen : AppTheme.textMutedLight,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: ok ? AppTheme.successGreen : AppTheme.textMutedLight,
          ),
        ),
      ],
    );
  }
}
