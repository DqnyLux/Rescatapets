const express = require('express');
const jwt = require('jsonwebtoken');
const { sequelize, Usuario } = require('./models');
const { authMiddleware, JWT_SECRET } = require('./authMiddleware');
const { getReportes, getReportesPublicos, crearReporte, crearReportePublico } = require('./controllers');
require('./worker');

const app = express();
app.use(express.json());

app.get('/', (req, res) => {
  res.json({
    status: 'online',
    message: 'API RescataPet EC en funcionamiento',
    endpoints: {
      reportes_publicos: 'GET /api/reportes/publicos',
      crear_reporte: 'POST /api/reportes/publicos',
      login: 'POST /api/login'
    }
  });
});

app.post('/api/login', async (req, res) => {
  const { email } = req.body;
  const usuario = await Usuario.findOne({ where: { email } });

  if (!usuario) return res.status(404).json({ error: 'Usuario no encontrado' });

  const token = jwt.sign({ id: usuario.id, email: usuario.email }, JWT_SECRET, { expiresIn: '1h' });
  res.json({ token });
});

app.get('/api/reportes', authMiddleware, getReportes);
app.get('/api/reportes/publicos', getReportesPublicos);
app.post('/api/reportes/publicos', crearReportePublico);
app.post('/api/reportes', authMiddleware, crearReporte);

sequelize.sync({ force: true }).then(async () => {
  console.log('Base de datos SQLite sincronizada.');
  const user = await Usuario.create({ nombre: 'Juan Pérez', email: 'juan@test.com' });

  const { Reporte } = require('./models');
  await Reporte.bulkCreate([
    {
      mascota: 'Max - Golden Retriever',
      ubicacion: 'Quito Norte - Parque La Carolina',
      estado: 'PUBLICO',
      usuarioId: user.id
    },
    {
      mascota: 'Luna - Gata Siamesa',
      ubicacion: 'Guayaquil - Samborondón',
      estado: 'PUBLICO',
      usuarioId: user.id
    },
    {
      mascota: 'Rocky - Beagle',
      ubicacion: 'Cuenca - Centro Histórico',
      estado: 'PUBLICO',
      usuarioId: user.id
    }
  ]);

  console.log('Reportes iniciales creados en la base de datos.');
  app.listen(3000, () => console.log(`Servidor en http://localhost:3000`));
});
