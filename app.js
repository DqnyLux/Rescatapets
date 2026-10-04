require("dotenv").config();
const express = require('express');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const { sequelize, Usuario, Reporte } = require('./models');
const { Op } = require('sequelize');
const { authMiddleware, JWT_SECRET } = require('./authMiddleware');
const { getReportes, getReportesPublicos, crearReporte, crearReportePublico, actualizarReporte, eliminarReporte } = require('./controllers');
// require('./worker'); // Removido por simplificación
const { setupNotifications, enviarMensajeVerificacion, enviarOtpWhatsApp } = require('./notifications');

setupNotifications();

// Hash simple de contraseñas (SHA-256) para no guardarlas en texto plano
const hashPassword = (password) => crypto.createHash('sha256').update(password).digest('hex');

const app = express();
app.use(express.json({ limit: '10mb' }));

app.post('/api/enviar-otp', async (req, res) => {
  const { telefono, codigo, nombre } = req.body;
  if (!telefono || !codigo) return res.status(400).json({ error: 'Faltan datos' });
  const success = await enviarOtpWhatsApp(telefono, codigo, nombre || 'Usuario');
  if (success) {
    res.json({ message: 'Enviado correctamente por WhatsApp' });
  } else {
    res.status(500).json({ error: 'Fallo al enviar WhatsApp' });
  }
});

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
  const { nombre, email, password, telefono } = req.body;

  if (!nombre || !email || !password) {
    return res.status(400).json({ error: 'Nombre, correo y contraseña son obligatorios.' });
  }

  try {
    const existe = await Usuario.findOne({ 
      where: { 
        [Op.or]: [
          { email },
          telefono ? { telefono } : { email: 'fake_never_match' }
        ]
      } 
    });
    
    if (existe) {
      if (existe.email === email) return res.status(400).json({ error: 'El correo electrónico ya está registrado.' });
      if (telefono && existe.telefono === telefono) return res.status(400).json({ error: 'El número de teléfono ya está en uso por otra cuenta.' });
    }

    const usuario = await Usuario.create({ nombre, email, password: hashPassword(password), telefono });
    const token = jwt.sign({ id: usuario.id, email: usuario.email }, JWT_SECRET, { expiresIn: '1h' });

    // >>> INTEGRACIÓN DE ENVÍO DE CORREO Y WHATSAPP <<<
    if (typeof enviarMensajeVerificacion === 'function') {
      // Background no bloqueante
      enviarMensajeVerificacion(nombre, email, telefono).catch(console.error);
    }

    res.status(201).json({ token, nombre: usuario.nombre, email: usuario.email, rol: usuario.rol, isVerified: usuario.isVerified });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});


app.post('/api/firebase-sync', async (req, res) => {
  let { email, nombre, telefono } = req.body;
  if (!email) return res.status(400).json({ error: 'Falta email' });

  try {
    let usuario = await Usuario.findOne({ where: { email } });
    if (!usuario) {
      if (!telefono) { req.body.telefono = '0990000000'; telefono = '0990000000'; }
      // Crear auto
      usuario = await Usuario.create({ 
        nombre: nombre || 'Usuario Firebase', 
        email, 
        password: hashPassword(email + 'firebase'), // dummy
        telefono 
      });
      // WhatsApp
      if (typeof enviarMensajeVerificacion === 'function') {
        enviarMensajeVerificacion(usuario.nombre, email, telefono).catch(console.error);
      }
    } else {
      // Actualizar telefono si se envió uno nuevo
      if (telefono && !usuario.telefono) {
        usuario.telefono = telefono;
        await usuario.save();
      }
    }

    const token = jwt.sign({ id: usuario.id, email: usuario.email }, JWT_SECRET, { expiresIn: '7d' });
    res.json({ token, nombre: usuario.nombre, email: usuario.email, rol: usuario.rol, telefono: usuario.telefono });
  } catch (err) {
    res.status(500).json({ error: err.message });
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
  res.json({ token, nombre: usuario.nombre, email: usuario.email, rol: usuario.rol, isVerified: usuario.isVerified });
});

app.get('/api/reportes', authMiddleware, getReportes);
app.get('/api/reportes/publicos', getReportesPublicos);
app.post('/api/reportes/publicos', crearReportePublico);
app.post('/api/reportes', authMiddleware, crearReporte);
app.put('/api/reportes/:id', authMiddleware, actualizarReporte);
app.delete('/api/reportes/:id', authMiddleware, eliminarReporte);

sequelize.sync({ alter: true }).then(async () => {
  console.log('Base de datos SQLite sincronizada.');

  // Usuario de demostración (solo se crea si no existe, para no perder registros)
  const [user] = await Usuario.findOrCreate({
    where: { email: 'juan@test.com' },
    defaults: { nombre: 'Juan Pérez', password: hashPassword('123456') }
  });



  app.listen(3000, () => {
    console.log(`Servidor en http://localhost:3000`);

    // Arrancar Ngrok automáticamente de fondo (modo perezoso)
    const { exec } = require('child_process');
    exec('ngrok http --domain=onward-prayer-petal.ngrok-free.dev 3000', (err) => {
      if (err) {
        console.log('Nota: Ngrok ya está corriendo, o hubo un error al iniciar túnel:', err.message);
      }
    });
    console.log(`🌍 Túnel Ngrok configurado hacia: https://onward-prayer-petal.ngrok-free.dev/api`);
  });
});


