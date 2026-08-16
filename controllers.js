const { Reporte, Usuario } = require('./models');
const { Queue } = require('bullmq');
const Redis = require('ioredis');

const redisClient = new Redis({
  host: '127.0.0.1',
  port: 6379,
  maxRetriesPerRequest: null,
  enableOfflineQueue: false,
  retryStrategy(times) {
    if (times > 1) return null;
    return 2000;
  }
});

redisClient.on('error', (err) => {
  // Ignorar errores repetitivos si Redis no está ejecutándose en local
});

const alertasQueue = new Queue('alertas', {
  connection: { host: '127.0.0.1', port: 6379, maxRetriesPerRequest: null, enableOfflineQueue: false }
});

alertasQueue.on('error', () => {});

const getReportes = async (req, res) => {
  try {
    // Prevención de N+1: Eager Loading incluye los datos del usuario en un solo JOIN a nivel de BD.
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
  const CACHE_KEY = 'reportes_publicos';

  try {
    if (redisClient.status === 'ready') {
      const cacheData = await redisClient.get(CACHE_KEY);
      if (cacheData) {
        console.log('Respondiendo desde Redis (Caché Hit)');
        return res.json(JSON.parse(cacheData));
      }
    }
  } catch (err) {
    // Redis no disponible, continuar con BD
  }

  try {
    console.log('Respondiendo desde BD (Cache Miss)');
    const reportes = await Reporte.findAll({ where: { estado: 'PUBLICO' } });

    if (redisClient.status === 'ready') {
      await redisClient.setex(CACHE_KEY, 60, JSON.stringify(reportes)).catch(() => {});
    }

    res.json(reportes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const crearReporte = async (req, res) => {
  const { mascota, ubicacion, estado } = req.body;
  
  try {
    const nuevoReporte = await Reporte.create({ mascota, ubicacion, estado, usuarioId: req.user.id });

    // Invalidación explícita del caché
    await redisClient.del('reportes_publicos');
    console.log('Caché invalidado exitosamente.');

    // Procesamiento asíncrono: Encolar tarea sin bloquear la respuesta al cliente
    await alertasQueue.add('enviarAlertaGeolocalizada', { reporteId: nuevoReporte.id, mascota, ubicacion });

    res.status(201).json({ mensaje: 'Reporte creado y alerta asíncrona iniciada', reporte: nuevoReporte });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

module.exports = { getReportes, getReportesPublicos, crearReporte };
