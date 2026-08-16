import 'package:flutter/material.dart';
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
  String _filtroEspecie = 'Todos';
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
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      reporte.imagenUrl,
                      height: 240,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.teal.shade50,
                          child: Icon(Icons.pets, size: 80, color: Colors.teal.shade300),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reporte.mascota,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (reporte.recompensa != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.amber, Colors.orange],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              )
                            ],
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Chip(
                        avatar: const Icon(Icons.category, size: 14, color: Colors.teal),
                        label: Text('${reporte.especie} • ${reporte.raza}'),
                        backgroundColor: Colors.teal.shade50,
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        avatar: const Icon(Icons.access_time, size: 14, color: Colors.grey),
                        label: Text(reporte.fecha),
                        backgroundColor: Colors.grey.shade100,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        reporte.ubicacion,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: reporte.esVerificado ? Colors.green.shade50 : Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: reporte.esVerificado ? Colors.green.shade300 : Colors.amber.shade400,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          reporte.esVerificado ? Icons.verified : Icons.gpp_maybe,
                          color: reporte.esVerificado ? Colors.green.shade700 : Colors.amber.shade800,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reporte.esVerificado ? 'Dueño/Publicador Verificado' : 'Publicación de Usuario No Verificado',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: reporte.esVerificado ? Colors.green.shade800 : Colors.amber.shade900,
                                ),
                              ),
                              Text(
                                reporte.esVerificado
                                    ? 'Identidad validada con cédula/correo en RescataPet EC.'
                                    : 'Cualquier persona puede publicar un reporte libremente.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: reporte.esVerificado ? Colors.green.shade900 : Colors.amber.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Descripción de la Mascota:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      reporte.descripcion,
                      style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Números de Contacto:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  _buildBotonContacto(
                    titulo: 'Teléfono Principal',
                    numero: reporte.telefonoPrincipal,
                    icono: Icons.phone_forwarded,
                    color: Colors.teal.shade700,
                  ),
                  if (reporte.telefonoSecundario != null && reporte.telefonoSecundario!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildBotonContacto(
                      titulo: 'WhatsApp / Teléfono Secundario',
                      numero: reporte.telefonoSecundario!,
                      icono: Icons.chat_bubble_outline,
                      color: Colors.green.shade700,
                    ),
                  ],
                  const SizedBox(height: 20),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 20,
            child: Icon(icono, color: Colors.white, size: 20),
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
                  content: Text('Llamando a $numero...'),
                  backgroundColor: color,
                ),
              );
            },
            icon: const Icon(Icons.call, size: 16),
            label: const Text('Llamar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoNuevoReporte() {
    final mascotaCtrl = TextEditingController();
    final especieCtrl = TextEditingController(text: 'Perro');
    final razaCtrl = TextEditingController();
    final ubicacionCtrl = TextEditingController();
    final tel1Ctrl = TextEditingController();
    final tel2Ctrl = TextEditingController();
    final descCtrl = TextEditingController();
    final recompensaCtrl = TextEditingController();
    final imagenUrlCtrl = TextEditingController(
      text: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=800&q=80',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.add_a_photo, color: Colors.teal),
              SizedBox(width: 10),
              Text('Reportar Mascota'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cualquier persona puede publicar un reporte. Adjunta foto y múltiples contactos.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: mascotaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la Mascota',
                    prefixIcon: Icon(Icons.pets),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: especieCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Especie (Perro/Gato)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: razaCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Raza (ej. Mestizo)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ubicacionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Ubicación de Extravío / Avistamiento',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tel1Ctrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono Principal *',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tel2Ctrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono Secundario / WhatsApp (Opcional)',
                    prefixIcon: Icon(Icons.chat),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: recompensaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Recompensa (ej. \$50 USD - Opcional)',
                    prefixIcon: Icon(Icons.monetization_on),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: imagenUrlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'URL de Foto de la Mascota',
                    prefixIcon: Icon(Icons.image),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descripción detallada (Color, señas, rasgos)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(' Reporte de mascota publicado exitosamente en RescataPet EC.'),
                    backgroundColor: Colors.teal,
                  ),
                );
              },
              icon: const Icon(Icons.publish),
              label: const Text('Publicar Reporte'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.pets, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'RescataPet EC',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
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
          ? FloatingActionButton.extended(
              onPressed: _mostrarDialogoNuevoReporte,
              backgroundColor: Colors.teal.shade700,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Reportar Mascota'),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal.shade700,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Mascotas Reportadas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user),
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
              colors: [Colors.teal.shade800, Colors.teal.shade600],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre, raza o ciudad...',
                        prefixIcon: const Icon(Icons.search, color: Colors.teal),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildChipFiltro('Todos'),
                    const SizedBox(width: 8),
                    _buildChipFiltro('Perros'),
                    const SizedBox(width: 8),
                    _buildChipFiltro('Gatos'),
                    const SizedBox(width: 8),
                    _buildChipFiltro('Verificados'),
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
                      CircularProgressIndicator(color: Colors.teal),
                      SizedBox(height: 16),
                      Text('Obteniendo catálogo de la API de RescataPet EC...'),
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
                        const Icon(Icons.cloud_off, color: Colors.redAccent, size: 64),
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
                            backgroundColor: Colors.teal,
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

                if (_filtroEspecie == 'Perros') {
                  return matchQuery && r.especie.toLowerCase() == 'perro';
                } else if (_filtroEspecie == 'Gatos') {
                  return matchQuery && r.especie.toLowerCase() == 'gato';
                } else if (_filtroEspecie == 'Verificados') {
                  return matchQuery && r.esVerificado;
                }
                return matchQuery;
              }).toList();

              return RefreshIndicator(
                onRefresh: () async => _cargarReportes(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reportes.length,
                  itemBuilder: (context, index) {
                    final reporte = reportes[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 180,
                                      color: Colors.teal.shade50,
                                      child: const Center(
                                        child: Icon(Icons.pets, size: 60, color: Colors.teal),
                                      ),
                                    );
                                  },
                                ),
                                Positioned(
                                  top: 12,
                                  right: 12,
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
                                  top: 12,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: reporte.esVerificado ? Colors.green.shade700 : Colors.amber.shade800,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          reporte.esVerificado ? Icons.verified : Icons.gpp_maybe,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          reporte.esVerificado ? 'Verificado' : 'No Verificado',
                                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          reporte.mascota,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      if (reporte.recompensa != null)
                                        Chip(
                                          label: Text(
                                            reporte.recompensa!,
                                            style: TextStyle(
                                              color: Colors.amber.shade900,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                          backgroundColor: Colors.amber.shade100,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${reporte.especie} • ${reporte.raza}',
                                    style: TextStyle(color: Colors.teal.shade800, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                                      const SizedBox(width: 4),
                                      Text(reporte.ubicacion, style: const TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    reporte.descripcion,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.3),
                                  ),
                                  const SizedBox(height: 12),
                                  const Divider(),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone, size: 14, color: Colors.teal),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Contacto: ${reporte.telefonoPrincipal}',
                                        style: const TextStyle(
                                          color: Colors.teal,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const Spacer(),
                                      TextButton.icon(
                                        onPressed: () => _mostrarDetalleMascota(reporte),
                                        icon: const Icon(Icons.visibility, size: 16),
                                        label: const Text('Ver Detalles'),
                                        style: TextButton.styleFrom(foregroundColor: Colors.teal.shade700),
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

  Widget _buildChipFiltro(String label) {
    final isSelected = _filtroEspecie == label;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        color: isSelected ? Colors.teal.shade900 : Colors.white,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      selectedColor: Colors.white,
      backgroundColor: Colors.teal.shade900.withValues(alpha: 0.4),
      onSelected: (selected) {
        setState(() {
          _filtroEspecie = label;
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
            color: Colors.teal.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_user_rounded, color: Colors.teal, size: 24),
                      SizedBox(width: 10),
                      Text('Diagnóstico de Autenticación HTTP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Demuestra la conectividad bidireccional realizando una solicitud POST a /api/login y obteniendo el Token JWT devuelto por el servidor Node.js.',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email de Usuario',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isLoggingIn ? null : _ejecutarLogin,
              icon: _isLoggingIn
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.login),
              label: Text(_isLoggingIn ? 'Conectando...' : 'Ejecutar Petición POST (Login API)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_jwtToken.isNotEmpty) ...[
            const Text(' Respuesta Exitosa (Token JWT Recibido):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
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
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
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
