import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/reporte.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isDarkMode = false;
  late Future<List<Reporte>> _futureReportes;
  String _searchQuery = '';
  String _filtroCategoria = 'Todos';
  final TextEditingController _searchController = TextEditingController();

  final _emailController = TextEditingController(text: 'juan@test.com');
  String _jwtToken = '';
  String _authError = '';
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    _cargarReportes();
  }

  void _cargarReportes() {
    setState(() {
      _futureReportes = ApiService.fetchReportesPublicos();
    });
  }

  Future<void> _ejecutarLogin() async {
    setState(() {
      _isLoggingIn = true;
      _authError = '';
      _jwtToken = '';
    });

    try {
      final token = await ApiService.login(_emailController.text.trim());
      setState(() {
        _jwtToken = token;
      });
    } catch (e) {
      setState(() {
        _authError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoggingIn = false;
      });
    }
  }

  void _mostrarDetalleMascota(Reporte reporte) {
    final textColor = _isDarkMode ? Colors.white : const Color(0xFF1F2937);
    final subtextColor = _isDarkMode ? Colors.grey.shade300 : const Color(0xFF4B5563);
    final cardBgColor = _isDarkMode ? const Color(0xFF1E293B) : Colors.white;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.88,
          maxChildSize: 0.96,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      reporte.imagenUrl,
                      height: 240,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 220,
                          color: const Color(0xFF0F766E).withValues(alpha: 0.2),
                          child: const Icon(Icons.pets, size: 80, color: Color(0xFF0D9488)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reporte.mascota,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (reporte.recompensa != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            ' ${reporte.recompensa}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${reporte.especie} • ${reporte.raza}',
                          style: const TextStyle(
                            color: Color(0xFF2DD4BF),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isDarkMode ? const Color(0xFF334155) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          ' Extraviado: ${reporte.fecha}',
                          style: TextStyle(color: subtextColor, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 22),
                      const SizedBox(width: 6),
                      Text(
                        reporte.ubicacion,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: reporte.esVerificado
                          ? (_isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFECFDF5))
                          : (_isDarkMode ? const Color(0xFF78350F) : const Color(0xFFFFFBEB)),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: reporte.esVerificado ? const Color(0xFF059669) : const Color(0xFFD97706),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          reporte.esVerificado ? Icons.verified_user_rounded : Icons.gpp_maybe_rounded,
                          color: reporte.esVerificado ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
                          size: 26,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reporte.esVerificado ? 'Persona Verificada' : 'Publicación de Usuario No Verificado',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: reporte.esVerificado ? const Color(0xFF6EE7B7) : const Color(0xFFFDE68A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                reporte.esVerificado
                                    ? 'Perfil validado con cédula y correo institucional en RescataPet EC.'
                                    : 'Publicado abiertamente sin verificación de perfil. Verificar identidad antes de entregar recompensas.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _isDarkMode ? Colors.grey.shade300 : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Descripción de la Mascota',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: _isDarkMode ? const Color(0xFF334155) : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _isDarkMode ? const Color(0xFF475569) : Colors.grey.shade200),
                    ),
                    child: Text(
                      reporte.descripcion,
                      style: TextStyle(fontSize: 14, height: 1.6, color: textColor),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Números de Contacto',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 14),
                  _buildBotonContacto(
                    titulo: 'Teléfono Principal (Llamada Directa)',
                    numero: reporte.telefonoPrincipal,
                    icono: Icons.phone_in_talk_rounded,
                    color: const Color(0xFF0D9488),
                  ),
                  if (reporte.telefonoSecundario != null && reporte.telefonoSecundario!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildBotonContacto(
                      titulo: 'Teléfono Secundario / WhatsApp',
                      numero: reporte.telefonoSecundario!,
                      icono: Icons.chat_rounded,
                      color: const Color(0xFF059669),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBotonContacto({
    required String titulo,
    required String numero,
    required IconData icono,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 22,
            child: Icon(icono, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: TextStyle(fontSize: 11, color: _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700)),
                Text(
                  numero,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _isDarkMode ? Colors.white : color),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Iniciando contacto con $numero...'),
                  backgroundColor: color,
                ),
              );
            },
            icon: const Icon(Icons.call, size: 16),
            label: const Text('Contactar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarGaleriaTelefono(Function(String) onImagenSeleccionada) {
    final fotosLocalesTel = [
      'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1537151608828-ea2b11777ee8?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1561037404-61cd46aa615b?auto=format&fit=crop&w=800&q=80',
    ];

    final sheetBg = _isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = _isDarkMode ? Colors.white : const Color(0xFF1F2937);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      backgroundColor: sheetBg,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.photo_library_rounded, color: Color(0xFF0D9488)),
                  const SizedBox(width: 10),
                  Text(
                    'Galería de Fotos del Teléfono',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Selecciona la imagen de la mascota guardada en la galería de tu dispositivo:',
                style: TextStyle(fontSize: 12, color: _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: fotosLocalesTel.length,
                itemBuilder: (context, index) {
                  final img = fotosLocalesTel[index];
                  return GestureDetector(
                    onTap: () {
                      onImagenSeleccionada(img);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Foto seleccionada exitosamente desde la Galería.'),
                          backgroundColor: Color(0xFF0D9488),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(img, fit: BoxFit.cover),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarDialogoNuevoReporte() {
    final mascotaCtrl = TextEditingController();
    String especieSeleccionada = 'Perro';
    final razaCtrl = TextEditingController();
    final ubicacionCtrl = TextEditingController();
    final tel1Ctrl = TextEditingController();
    final tel2Ctrl = TextEditingController();
    final descCtrl = TextEditingController();
    final recompensaCtrl = TextEditingController();
    String imagenSeleccionada = 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=800&q=80';

    final modalBg = _isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = _isDarkMode ? Colors.white : const Color(0xFF1F2937);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.92,
              maxChildSize: 0.96,
              minChildSize: 0.6,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: modalBg,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    children: [
                      Center(
                        child: Container(
                          width: 48,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.add_a_photo_rounded, color: Color(0xFF0D9488), size: 28),
                          const SizedBox(width: 10),
                          Text(
                            'Reportar Mascota',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Publicación abierta para la comunidad de RescataPet EC.',
                        style: TextStyle(fontSize: 12, color: _isDarkMode ? Colors.grey.shade400 : Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      Text('1. Foto desde la Galería:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                      const SizedBox(height: 10),
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              imagenSeleccionada,
                              height: 170,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _mostrarGaleriaTelefono((nuevaImg) {
                                  setModalState(() => imagenSeleccionada = nuevaImg);
                                });
                              },
                              icon: const Icon(Icons.photo_library_rounded, size: 18),
                              label: const Text('Abrir Galería de Fotos'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D9488),
                                foregroundColor: Colors.white,
                                elevation: 4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text('2. Datos Generales:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                      const SizedBox(height: 10),
                      _buildTextField(mascotaCtrl, 'Nombre de la Mascota', Icons.pets),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: especieSeleccionada,
                        dropdownColor: modalBg,
                        style: TextStyle(color: textColor, fontSize: 15),
                        decoration: InputDecoration(
                          labelText: 'Categoría / Especie',
                          labelStyle: TextStyle(color: _isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700),
                          prefixIcon: const Icon(Icons.category, color: Color(0xFF0D9488)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Perro', child: Text('🐶 Perro')),
                          DropdownMenuItem(value: 'Gato', child: Text('🐱 Gato')),
                          DropdownMenuItem(value: 'Ave', child: Text('🦜 Ave')),
                          DropdownMenuItem(value: 'Conejo', child: Text('🐰 Conejo')),
                          DropdownMenuItem(value: 'Otro', child: Text('🐾 Otro')),
                        ],
                        onChanged: (val) => setModalState(() => especieSeleccionada = val!),
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(razaCtrl, 'Raza (ej. Mestizo, Golden, Siamés)', Icons.style),
                      const SizedBox(height: 14),
                      _buildTextField(ubicacionCtrl, 'Ubicación (Ciudad / Barrio / Sector)', Icons.location_on, iconColor: Colors.redAccent),
                      const SizedBox(height: 20),
                      Text('3. Números de Contacto (Solo Números):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                      const SizedBox(height: 10),
                      _buildTextField(
                        tel1Ctrl,
                        'Teléfono Principal (Máx 10 dígitos) *',
                        Icons.phone,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        tel2Ctrl,
                        'Teléfono Secundario / WhatsApp (Opcional)',
                        Icons.chat,
                        iconColor: const Color(0xFF059669),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                      ),
                      const SizedBox(height: 20),
                      Text('4. Recompensa & Detalles:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                      const SizedBox(height: 10),
                      _buildTextField(
                        recompensaCtrl,
                        'Monto de Recompensa en USD (Solo números)',
                        Icons.monetization_on,
                        iconColor: Colors.amber,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        prefixText: '\$ ',
                        suffixText: ' USD',
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(descCtrl, 'Caja de Descripción (Color, señas, rasgos)', Icons.description, maxLines: 3),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(' Reporte de mascota publicado exitosamente en RescataPet EC.'),
                                backgroundColor: Color(0xFF0D9488),
                              ),
                            );
                          },
                          icon: const Icon(Icons.cloud_upload_rounded),
                          label: const Text('Publicar Reporte de Mascota', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D9488),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    Color iconColor = const Color(0xFF0D9488),
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? prefixText,
    String? suffixText,
  }) {
    final textColor = _isDarkMode ? Colors.white : const Color(0xFF1F2937);
    final labelColor = _isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: labelColor),
        prefixIcon: Icon(icon, color: iconColor),
        prefixText: prefixText,
        suffixText: suffixText,
        prefixStyle: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        suffixStyle: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _isDarkMode ? const Color(0xFF475569) : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgBackgroundColor = _isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6);

    return Scaffold(
      backgroundColor: bgBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.pets_rounded, color: Colors.white, size: 26),
            const SizedBox(width: 10),
            Text(
              'RescataPet EC',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: _isDarkMode ? const Color(0xFF38BDF8) : Colors.white,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isDarkMode
                  ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                  : [const Color(0xFF0F766E), const Color(0xFF0D9488)],
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 6,
        actions: [
          Row(
            children: [
              Icon(_isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded, size: 20, color: Colors.amber),
              Switch(
                value: _isDarkMode,
                activeThumbColor: Colors.amber,
                onChanged: (val) => setState(() => _isDarkMode = val),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _cargarReportes,
            tooltip: 'Actualizar API',
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildReportesTab(),
          _buildAuthTab(),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: _mostrarDialogoNuevoReporte,
                backgroundColor: const Color(0xFF0D9488),
                foregroundColor: Colors.white,
                elevation: 0,
                icon: const Icon(Icons.add_a_photo_rounded),
                label: const Text(
                  'Reportar Mascota',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF0D9488),
        unselectedItemColor: _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
        backgroundColor: _isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        elevation: 10,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Mascotas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user_rounded),
            label: 'Diagnóstico API',
          ),
        ],
      ),
    );
  }

  Widget _buildReportesTab() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isDarkMode
                  ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                  : [const Color(0xFF0F766E), const Color(0xFF0D9488)],
            ),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Buscar mascota, raza o ciudad...',
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0D9488)),
                  filled: true,
                  fillColor: _isDarkMode ? const Color(0xFF334155) : Colors.white,
                  hintStyle: TextStyle(color: _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildChipFiltro('Todos', Icons.pets),
                    const SizedBox(width: 8),
                    _buildChipFiltro('Perros', Icons.pets),
                    const SizedBox(width: 8),
                    _buildChipFiltro('Gatos', Icons.cruelty_free),
                    const SizedBox(width: 8),
                    _buildChipFiltro('Verificados', Icons.verified_user_rounded),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Reporte>>(
            future: _futureReportes,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0D9488)),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No hay reportes de mascotas.'));
              }

              final reportes = snapshot.data!.where((r) {
                final query = _searchQuery.toLowerCase();
                final matchQuery = r.mascota.toLowerCase().contains(query) ||
                    r.ubicacion.toLowerCase().contains(query) ||
                    r.raza.toLowerCase().contains(query);

                if (_filtroCategoria == 'Perros') {
                  return matchQuery && r.especie.toLowerCase() == 'perro';
                } else if (_filtroCategoria == 'Gatos') {
                  return matchQuery && r.especie.toLowerCase() == 'gato';
                } else if (_filtroCategoria == 'Verificados') {
                  return matchQuery && r.esVerificado;
                }
                return matchQuery;
              }).toList();

              return RefreshIndicator(
                onRefresh: () async => _cargarReportes(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: reportes.length,
                  itemBuilder: (context, index) {
                    final reporte = reportes[index];
                    return _buildTarjetaMascota(reporte);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTarjetaMascota(Reporte reporte) {
    final cardBg = _isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final titleColor = _isDarkMode ? Colors.white : const Color(0xFF1F2937);
    final descColor = _isDarkMode ? Colors.grey.shade300 : const Color(0xFF4B5563);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _isDarkMode ? const Color(0xFF334155) : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isDarkMode ? 0.3 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _mostrarDetalleMascota(reporte),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  reporte.imagenUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: const Color(0xFF0F766E).withValues(alpha: 0.15),
                      child: const Center(
                        child: Icon(Icons.pets, size: 60, color: Color(0xFF0D9488)),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      reporte.estado,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: reporte.esVerificado ? const Color(0xFF059669) : const Color(0xFFD97706),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          reporte.esVerificado ? Icons.verified_user_rounded : Icons.gpp_maybe_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          reporte.esVerificado ? 'Verificado' : 'No Verificado',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reporte.mascota,
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                        ),
                      ),
                      if (reporte.recompensa != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFF59E0B)),
                          ),
                          child: Text(
                            ' ${reporte.recompensa!}',
                            style: const TextStyle(
                              color: Color(0xFFB45309),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${reporte.especie} • ${reporte.raza}',
                    style: const TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 16, color: Colors.redAccent),
                      const SizedBox(width: 4),
                      Text(reporte.ubicacion, style: TextStyle(color: _isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    reporte.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: descColor, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  Divider(height: 1, color: _isDarkMode ? const Color(0xFF334155) : Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.phone_in_talk_rounded, size: 16, color: Color(0xFF0D9488)),
                      const SizedBox(width: 6),
                      Text(
                        reporte.telefonoPrincipal,
                        style: TextStyle(
                          color: _isDarkMode ? const Color(0xFF38BDF8) : const Color(0xFF0D9488),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => _mostrarDetalleMascota(reporte),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        label: const Text('Ver Ficha'),
                        style: TextButton.styleFrom(
                          foregroundColor: _isDarkMode ? const Color(0xFF38BDF8) : const Color(0xFF0D9488),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChipFiltro(String label, IconData icono) {
    final isSelected = _filtroCategoria == label;
    return FilterChip(
      selected: isSelected,
      avatar: Icon(icono, size: 16, color: isSelected ? const Color(0xFF0F766E) : Colors.white),
      label: Text(label),
      selectedColor: Colors.white,
      backgroundColor: Colors.white.withValues(alpha: 0.2),
      onSelected: (selected) {
        setState(() {
          _filtroCategoria = label;
        });
      },
    );
  }

  Widget _buildAuthTab() {
    final cardBg = _isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFCCFBF1);
    final titleColor = _isDarkMode ? const Color(0xFF38BDF8) : const Color(0xFF0F766E);
    final textColor = _isDarkMode ? Colors.white : Colors.teal.shade900;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: cardBg,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_user_rounded, color: titleColor, size: 26),
                      const SizedBox(width: 10),
                      Text('Diagnóstico de Autenticación HTTP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: titleColor)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Demuestra la conectividad bidireccional realizando una solicitud POST a /api/login y obteniendo el Token JWT devuelto por el servidor Node.js.',
                    style: TextStyle(fontSize: 13, color: textColor, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField(_emailController, 'Email de Usuario', Icons.email_rounded),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isLoggingIn ? null : _ejecutarLogin,
              icon: _isLoggingIn
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.login_rounded),
              label: Text(_isLoggingIn ? 'Conectando...' : 'Ejecutar Petición POST (Login API)', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_jwtToken.isNotEmpty) ...[
            const Text(' Respuesta Exitosa (Token JWT Recibido):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isDarkMode ? const Color(0xFF064E3B) : Colors.green.shade50,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.green),
              ),
              child: SelectableText(
                _jwtToken,
                style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: _isDarkMode ? Colors.green.shade200 : Colors.green.shade900),
              ),
            ),
          ],
          if (_authError.isNotEmpty) ...[
            const Text(' Error en Respuesta HTTP:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isDarkMode ? const Color(0xFF78350F) : Colors.red.shade50,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.red),
              ),
              child: Text(_authError, style: const TextStyle(color: Colors.red, fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }
}
