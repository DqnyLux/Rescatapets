const express = require('express');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const { sequelize, Usuario, Reporte } = require('./models');
const { authMiddleware, JWT_SECRET } = require('./authMiddleware');
const { getReportes, getReportesPublicos, crearReporte, crearReportePublico } = require('./controllers');
require('./worker');

// Hash simple de contraseñas (SHA-256) para no guardarlas en texto plano
const hashPassword = (password) => crypto.createHash('sha256').update(password).digest('hex');

const app = express();
app.use(express.json({ limit: '10mb' }));

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

app.post('/api/registro', async (req, res) => {
  const { nombre, email, password } = req.body;

  if (!nombre || !email || !password) {
    return res.status(400).json({ error: 'Nombre, correo y contraseña son obligatorios.' });
  }

  try {
    const existe = await Usuario.findOne({ where: { email } });
    if (existe) return res.status(400).json({ error: 'El correo ya está registrado.' });

    const usuario = await Usuario.create({ nombre, email, password: hashPassword(password) });
    const token = jwt.sign({ id: usuario.id, email: usuario.email }, JWT_SECRET, { expiresIn: '1h' });

    res.status(201).json({ token, nombre: usuario.nombre, email: usuario.email });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Ingresa tu correo y contraseña.' });
  }

  const usuario = await Usuario.findOne({ where: { email } });

  // Mismo mensaje para usuario inexistente o contraseña incorrecta
  if (!usuario || usuario.password !== hashPassword(password)) {
    return res.status(401).json({ error: 'Credenciales incorrectas.' });
  }

  const token = jwt.sign({ id: usuario.id, email: usuario.email }, JWT_SECRET, { expiresIn: '1h' });
  res.json({ token, nombre: usuario.nombre, email: usuario.email });
});

app.get('/api/reportes', authMiddleware, getReportes);
app.get('/api/reportes/publicos', getReportesPublicos);
app.post('/api/reportes/publicos', crearReportePublico);
app.post('/api/reportes', authMiddleware, crearReporte);

sequelize.sync({ alter: true }).then(async () => {
  console.log('Base de datos SQLite sincronizada.');

  // Usuario de demostración (solo se crea si no existe, para no perder registros)
  const [user] = await Usuario.findOrCreate({
    where: { email: 'juan@test.com' },
    defaults: { nombre: 'Juan Pérez', password: hashPassword('123456') }
  });

  const totalReportes = await Reporte.count();
  if (totalReportes === 0) {
    await Reporte.bulkCreate([
      {
        mascota: 'Max',
        especie: 'Perro',
        raza: 'Golden Retriever',
        ubicacion: 'Quito, Parque La Carolina',
        ciudad: 'Quito',
        sector: 'La Carolina',
        latitud: -0.1807,
        longitud: -78.4842,
        estado: 'PUBLICO',
        tipoAlerta: 'PERDIDO',
        telefonoPrincipal: '0991234567',
        descripcion: 'Visto cerca del jardín botánico.',
        tamano: 'Grande',
        sexo: 'Macho',
        color: 'Dorado',
        usuarioId: user.id
      },
      {
        mascota: 'Luna',
        especie: 'Gato',
        raza: 'Siamés',
        ubicacion: 'Guayaquil, Samborondón',
        ciudad: 'Guayaquil',
        sector: 'Samborondón',
        latitud: -2.1350,
        longitud: -79.8687,
        estado: 'PUBLICO',
        tipoAlerta: 'ENCONTRADO',
        telefonoPrincipal: '0987654321',
        descripcion: 'Encontrada con collar rosado sin placa.',
        tamano: 'Pequeño',
        sexo: 'Hembra',
        color: 'Blanco y Crema',
        usuarioId: user.id
      }
    ]);
    console.log('Reportes iniciales creados en la base de datos.');
  }

  app.listen(3000, () => console.log(`Servidor en http://localhost:3000`));
});
