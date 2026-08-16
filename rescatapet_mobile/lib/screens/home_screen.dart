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
                      height: 250,
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Text(
                            ' Recompensa ${reporte.recompensa}',
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

    final opcionesImagenes = [
      'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1537151608828-ea2b11777ee8?auto=format&fit=crop&w=800&q=80',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              maxChildSize: 0.95,
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
                        'Cualquier usuario puede publicar un reporte libremente.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      const Text('1. Seleccionar Foto de la Mascota:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          imagenSeleccionada,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 70,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: opcionesImagenes.length,
                          itemBuilder: (context, index) {
                            final img = opcionesImagenes[index];
                            final isSel = img == imagenSeleccionada;
                            return GestureDetector(
                              onTap: () => setModalState(() => imagenSeleccionada = img),
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSel ? const Color(0xFF0D9488) : Colors.transparent,
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: Image.network(img, width: 70, height: 70, fit: BoxFit.cover),
                                ),
                              ),
                            );
                          },
                        ),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.pets_rounded, color: Colors.white, size: 26),
            SizedBox(width: 10),
            Text(
              'RescataPet EC',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: 0.5),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F766E), Color(0xFF0D9488), Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 6,
        actions: [
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: const Color(0xFF0D9488),
          unselectedItemColor: Colors.grey.shade500,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              activeIcon: Icon(Icons.grid_view_rounded, size: 28),
              label: 'Mascotas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.verified_user_rounded),
              activeIcon: Icon(Icons.verified_user_rounded, size: 28),
              label: 'Diagnóstico API',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportesTab() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Buscar mascota, raza o ciudad...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0D9488)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.cancel_rounded, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF0D9488)),
                      SizedBox(height: 16),
                      Text('Obteniendo catálogo en vivo de la API RescataPet EC...'),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off_rounded, color: Colors.redAccent, size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          'Fallo de Conexión HTTP',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _cargarReportes,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar Conexión'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D9488),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No hay reportes de mascotas registrados.'),
                );
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
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
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
                                      color: Colors.teal.shade50,
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
                                      color: Colors.black.withValues(alpha: 0.65),
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
                                          style: const TextStyle(
                                            fontSize: 21,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1F2937),
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
                                      Text(reporte.ubicacion, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    reporte.descripcion,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Color(0xFF4B5563), fontSize: 13, height: 1.4),
                                  ),
                                  const SizedBox(height: 14),
                                  const Divider(height: 1),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone_in_talk_rounded, size: 16, color: Color(0xFF0D9488)),
                                      const SizedBox(width: 6),
                                      Text(
                                        reporte.telefonoPrincipal,
                                        style: const TextStyle(
                                          color: Color(0xFF0D9488),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const Spacer(),
                                      TextButton.icon(
                                        onPressed: () => _mostrarDetalleMascota(reporte),
                                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                                        label: const Text('Ver Ficha'),
                                        style: TextButton.styleFrom(foregroundColor: const Color(0xFF0D9488)),
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
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChipFiltro(String label, IconData icono) {
    final isSelected = _filtroCategoria == label;
    return FilterChip(
      selected: isSelected,
      avatar: Icon(icono, size: 16, color: isSelected ? const Color(0xFF0F766E) : Colors.white),
      label: Text(label),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF0F766E) : Colors.white,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      selectedColor: Colors.white,
      backgroundColor: Colors.white.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide.none,
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
            elevation: 0,
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
