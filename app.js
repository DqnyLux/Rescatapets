const express = require('express');
const jwt = require('jsonwebtoken');
const { sequelize, Usuario } = require('./models');
const { authMiddleware, JWT_SECRET } = require('./authMiddleware');
const { getReportes, getReportesPublicos, crearReporte } = require('./controllers');
require('./worker');

const app = express();
app.use(express.json());

app.get('/', (req, res) => {
  res.json({
    status: 'online',
    message: 'API RescataPet EC en funcionamiento',
    endpoints: {
      reportes_publicos: 'GET /api/reportes/publicos',
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
app.post('/api/reportes', authMiddleware, crearReporte);

sequelize.sync({ force: true }).then(async () => {
  console.log('Base de datos SQLite sincronizada.');
  await Usuario.create({ nombre: 'Juan Pérez', email: 'juan@test.com' });
  
  app.listen(3000, () => console.log(`Servidor en http://localhost:3000`));
});
