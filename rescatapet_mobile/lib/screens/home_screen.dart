import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/reporte.dart';
import '../services/api_service.dart';

enum EstiloDiseno {
  glassmorphism,
  bentoGrid,
  neumorfismo,
  neoBrutalism,
  modoOscuro,
  spatial3D,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  EstiloDiseno _estiloActual = EstiloDiseno.glassmorphism;
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

  void _mostrarSelectorEstilos() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🎨 Seleccionar Estilo Visual de UI',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Alterna en tiempo real entre los principales paradigmas de diseño:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildOpcionEstilo(EstiloDiseno.glassmorphism, '🔮 Glassmorphism'),
                  _buildOpcionEstilo(EstiloDiseno.bentoGrid, '🍱 Bento Grid'),
                  _buildOpcionEstilo(EstiloDiseno.neumorfismo, '🔲 Neumorfismo'),
                  _buildOpcionEstilo(EstiloDiseno.neoBrutalism, '⚡ Neo-Brutalism'),
                  _buildOpcionEstilo(EstiloDiseno.modoOscuro, '🌙 Modo Oscuro'),
                  _buildOpcionEstilo(EstiloDiseno.spatial3D, '🌌 Spatial UI 3D'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOpcionEstilo(EstiloDiseno estilo, String label) {
    final isSelected = _estiloActual == estilo;
    return ChoiceChip(
      selected: isSelected,
      label: Text(label),
      selectedColor: const Color(0xFF0D9488),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _estiloActual = estilo;
          });
          Navigator.pop(context);
        }
      },
    );
  }

  void _mostrarDetalleMascota(Reporte reporte) {
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
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
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
                        color: Colors.grey.shade300,
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
                          color: Colors.teal.shade50,
                          child: Icon(Icons.pets, size: 80, color: Colors.teal.shade300),
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
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1F2937),
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
                          color: const Color(0xFFCCFBF1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${reporte.especie} • ${reporte.raza}',
                          style: const TextStyle(
                            color: Color(0xFF0F766E),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          ' Extraviado: ${reporte.fecha}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: reporte.esVerificado ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: reporte.esVerificado ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          reporte.esVerificado ? Icons.verified_user_rounded : Icons.gpp_maybe_rounded,
                          color: reporte.esVerificado ? const Color(0xFF059669) : const Color(0xFFD97706),
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
                                  color: reporte.esVerificado ? const Color(0xFF065F46) : const Color(0xFF92400E),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                reporte.esVerificado
                                    ? 'Perfil validado con cédula y correo institucional en RescataPet EC.'
                                    : 'Publicado abiertamente sin verificación de perfil. Verificar identidad antes de concretar recompensa.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: reporte.esVerificado ? const Color(0xFF047857) : const Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Descripción de la Mascota',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      reporte.descripcion,
                      style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF4B5563)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Números de Contacto',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
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
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
                Text(titulo, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(
                  numero,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
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

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.photo_library_rounded, color: Color(0xFF0D9488)),
                  SizedBox(width: 10),
                  Text(
                    'Galería del Teléfono (Simulada)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Selecciona una foto capturada con la cámara o almacenada en el dispositivo:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
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
                          content: Text('Foto cargada correctamente desde el almacenamiento del teléfono.'),
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
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const Row(
                        children: [
                          Icon(Icons.add_a_photo_rounded, color: Color(0xFF0D9488), size: 28),
                          SizedBox(width: 10),
                          Text(
                            'Reportar Mascota',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Publicación directa desde el celular sin restricciones.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      const Text('1. Foto desde el Teléfono:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                              icon: const Icon(Icons.photo_camera_rounded, size: 18),
                              label: const Text('Abrir Galería / Cámara'),
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
                      const Text('2. Datos Generales:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: mascotaCtrl,
                        decoration: InputDecoration(
                          labelText: 'Nombre de la Mascota',
                          prefixIcon: const Icon(Icons.pets, color: Color(0xFF0D9488)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: especieSeleccionada,
                        decoration: InputDecoration(
                          labelText: 'Categoría / Especie',
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
                      TextField(
                        controller: razaCtrl,
                        decoration: InputDecoration(
                          labelText: 'Raza (ej. Mestizo, Golden, Siamés)',
                          prefixIcon: const Icon(Icons.style, color: Color(0xFF0D9488)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: ubicacionCtrl,
                        decoration: InputDecoration(
                          labelText: 'Ubicación (Ciudad / Barrio / Referencia)',
                          prefixIcon: const Icon(Icons.location_on, color: Colors.redAccent),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('3. Números de Contacto (Solo Números):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: tel1Ctrl,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Teléfono Principal (Máx 10 dígitos) *',
                          prefixIcon: const Icon(Icons.phone, color: Color(0xFF0D9488)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: tel2Ctrl,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Teléfono Secundario / WhatsApp (Opcional)',
                          prefixIcon: const Icon(Icons.chat, color: Color(0xFF059669)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('4. Recompensa & Detalles:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: recompensaCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          labelText: 'Monto de Recompensa en USD (Solo números)',
                          prefixText: '\$ ',
                          suffixText: ' USD',
                          prefixIcon: const Icon(Icons.monetization_on, color: Colors.amber),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: descCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Caja de Descripción (Color, señas, comportamiento)',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = _estiloActual == EstiloDiseno.modoOscuro;
    final bgBackgroundColor = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6);

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
                color: isDarkMode ? const Color(0xFF38BDF8) : Colors.white,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                  : [const Color(0xFF0F766E), const Color(0xFF0D9488)],
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 6,
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_rounded),
            onPressed: _mostrarSelectorEstilos,
            tooltip: 'Cambiar Estilo UI',
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
        unselectedItemColor: Colors.grey.shade500,
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
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
    final isDarkMode = _estiloActual == EstiloDiseno.modoOscuro;

    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
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
                  fillColor: isDarkMode ? const Color(0xFF334155) : Colors.white,
                  hintStyle: TextStyle(color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
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
                    return _buildTarjetaSegunEstilo(reporte, index);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTarjetaSegunEstilo(Reporte reporte, int index) {
    switch (_estiloActual) {
      case EstiloDiseno.glassmorphism:
        return _buildTarjetaGlassmorphism(reporte);
      case EstiloDiseno.bentoGrid:
        return _buildTarjetaBentoGrid(reporte);
      case EstiloDiseno.neumorfismo:
        return _buildTarjetaNeumorfismo(reporte);
      case EstiloDiseno.neoBrutalism:
        return _buildTarjetaNeoBrutalism(reporte);
      case EstiloDiseno.modoOscuro:
        return _buildTarjetaModoOscuro(reporte);
      case EstiloDiseno.spatial3D:
        return _buildTarjetaSpatial3D(reporte, index);
    }
  }

  Widget _buildTarjetaGlassmorphism(Reporte reporte) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: InkWell(
            onTap: () => _mostrarDetalleMascota(reporte),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(reporte.imagenUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reporte.mascota, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('${reporte.especie} • ${reporte.raza}', style: const TextStyle(color: Color(0xFF0D9488))),
                      const SizedBox(height: 6),
                      Text('Contacto: ${reporte.telefonoPrincipal}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTarjetaBentoGrid(Reporte reporte) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => _mostrarDetalleMascota(reporte),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(reporte.imagenUrl, height: 120, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reporte.mascota, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('${reporte.especie} • ${reporte.raza}', style: const TextStyle(fontSize: 12, color: Colors.teal)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(12)),
                        child: Text('📍 ${reporte.ubicacion}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTarjetaNeumorfismo(Reporte reporte) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 10),
          BoxShadow(color: Color(0xFFD1D5DB), offset: Offset(6, 6), blurRadius: 10),
        ],
      ),
      child: InkWell(
        onTap: () => _mostrarDetalleMascota(reporte),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(reporte.imagenUrl, width: 90, height: 90, fit: BoxFit.cover),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reporte.mascota, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Tel: ${reporte.telefonoPrincipal}', style: const TextStyle(color: Color(0xFF0D9488))),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTarjetaNeoBrutalism(Reporte reporte) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(6, 6)),
        ],
      ),
      child: InkWell(
        onTap: () => _mostrarDetalleMascota(reporte),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(reporte.imagenUrl, height: 160, width: double.infinity, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reporte.mascota.toUpperCase(),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black),
                  ),
                  Text('CONTACTO: ${reporte.telefonoPrincipal}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTarjetaModoOscuro(Reporte reporte) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: InkWell(
        onTap: () => _mostrarDetalleMascota(reporte),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(reporte.imagenUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reporte.mascota, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('${reporte.especie} • ${reporte.raza}', style: const TextStyle(color: Color(0xFF38BDF8))),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTarjetaSpatial3D(Reporte reporte, int index) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(0.04)
        ..rotateY(-0.02),
      alignment: FractionalOffset.center,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 12),
            )
          ],
        ),
        child: InkWell(
          onTap: () => _mostrarDetalleMascota(reporte),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(reporte.imagenUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(reporte.mascota, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              )
            ],
          ),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: const Color(0xFFCCFBF1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.verified_user_rounded, color: Color(0xFF0F766E), size: 26),
                      SizedBox(width: 10),
                      Text('Diagnóstico de Autenticación HTTP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F766E))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Demuestra la conectividad bidireccional realizando una solicitud POST a /api/login y obteniendo el Token JWT devuelto por el servidor Node.js.',
                    style: TextStyle(fontSize: 13, color: Colors.teal.shade900, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email de Usuario',
              prefixIcon: const Icon(Icons.email_rounded, color: Color(0xFF0D9488)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
            ),
          ),
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
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.green),
              ),
              child: SelectableText(
                _jwtToken,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              ),
            ),
          ],
          if (_authError.isNotEmpty) ...[
            const Text(' Error en Respuesta HTTP:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
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
