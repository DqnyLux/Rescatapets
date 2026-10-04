const { Reporte, Usuario } = require('./models');

const getReportes = async (req, res) => {
  try {
    const reportes = await Reporte.findAll({
      include: [{
        model: Usuario,
        as: 'usuario',
        attributes: ['id', 'nombre', 'email']
      }]
    });
    res.json(reportes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const getReportesPublicos = async (req, res) => {
  try {
    const reportes = await Reporte.findAll({ where: { estado: 'PUBLICO' } });
    res.json(reportes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const crearReporte = async (req, res) => {
  const { mascota, ubicacion, estado } = req.body;

  try {
    const nuevoReporte = await Reporte.create({ mascota, ubicacion, estado, usuarioId: req.user.id });
    res.status(201).json({ mensaje: 'Reporte creado asÃ­ncrono', reporte: nuevoReporte });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const crearReportePublico = async (req, res) => {
  const {
    mascota, ubicacion, estado, especie, raza, ciudad, sector,
    latitud, longitud, tipoAlerta, telefonoPrincipal, descripcion,
    tamano, sexo, color, imagenBase64
  } = req.body;

  try {
    const nuevoReporte = await Reporte.create({
      mascota: mascota || 'Mascota',
      ubicacion: ubicacion || 'Ecuador',
      estado: estado || 'PUBLICO',
      especie, raza, ciudad, sector, latitud, longitud, tipoAlerta,
      telefonoPrincipal, descripcion, tamano, sexo, color, imagenBase64,
      usuarioId: 1
    });

    res.status(201).json({ mensaje: 'Reporte creado exitosamente', reporte: nuevoReporte });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const actualizarReporte = async (req, res) => {
  try {
    const { id } = req.params;
    const reporte = await Reporte.findByPk(id);
    if (!reporte) return res.status(404).json({ error: 'Reporte no encontrado' });
    
    // Seguridad: verificar que el usuario sea el dueño
    if (reporte.usuarioId !== req.user.id) {
      return res.status(403).json({ error: 'No tienes permiso para editar este reporte' });
    }

    await reporte.update(req.body);
    res.json({ mensaje: 'Reporte actualizado', reporte });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const eliminarReporte = async (req, res) => {
  try {
    const { id } = req.params;
    const reporte = await Reporte.findByPk(id);
    if (!reporte) return res.status(404).json({ error: 'Reporte no encontrado' });

    // Seguridad: verificar dueño o rol autoridad
    if (reporte.usuarioId !== req.user.id && req.user.rol !== 'AUTORIDAD') {
      return res.status(403).json({ error: 'No tienes permiso para eliminar este reporte' });
    }

    await reporte.destroy();
    res.json({ mensaje: 'Reporte eliminado correctamente' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

module.exports = { getReportes, getReportesPublicos, crearReporte, crearReportePublico, actualizarReporte, eliminarReporte };

