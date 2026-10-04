// Funciones de mensajería (Correo y WhatsApp)

let transporter = null;
let client = null;

async function setupNotifications() {
  try {
    const nodemailer = require('nodemailer');
    
    // Configuración para usar Gmail (requiere "Contraseña de la aplicación" en las opciones de seguridad de tu cuenta)
    transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.GMAIL_USER,
        pass: process.env.GMAIL_PASS,
      }
    });
  } catch (e) {
    console.log("Nodemailer no disponible. Usa: npm install nodemailer");
  }

  try {
    const { Client, LocalAuth } = require('whatsapp-web.js');
    const qrcode = require('qrcode-terminal');

    client = new Client({
      authStrategy: new LocalAuth(),
      puppeteer: { headless: true, args: ['--no-sandbox'] }
    });

    client.on('qr', (qr) => {
      console.log('\n=== ESCANEA ESTE QR PARA ACTIVAR WHATSAPP BOT ===');
      qrcode.generate(qr, { small: true });
    });

    client.on('ready', () => {
      console.log('Bot de WhatsApp conectado y listo para enviar códigos!');
    });

    client.initialize();
  } catch(e) {
    console.log("whatsapp-web.js no disponible. Usa: npm install whatsapp-web.js qrcode-terminal");
  }
}

async function enviarMensajeVerificacion(nombre, email, telefono) {
  const pin = Math.floor(100000 + Math.random() * 900000).toString(); // PIN de 6 dígitos

  // Enviar Email
  if (transporter) {
    try {
      await transporter.sendMail({
        from: '"RescataPet EC" <noreply@rescatapet.com>',
        to: email,
        subject: '¡Bienvenido a RescataPet EC!',
        html: `<h2>Hola ${nombre}!</h2><p>Tu cuenta ha sido creada exitosamente. Tu código PIN de verificación es: <b>${pin}</b></p>`
      });
      console.log(`Correo enviado a ${email}`);
    } catch(err) {
      console.error("Fallo al enviar email:", err);
    }
  }

  // Enviar WhatsApp (El teléfono debe incluir código de país, ej: 593991234567)
  if (client && telefono) {
    try {
      // Limpiar el número y asegurar que tenga el código correcto
      let numeroLimpio = telefono.replace(/\D/g, '');
      if (numeroLimpio.length === 10 && numeroLimpio.startsWith('0')) {
        numeroLimpio = '593' + numeroLimpio.substring(1);
      }
      
      const isRegistered = await client.isRegisteredUser(`${numeroLimpio}@c.us`);
      if (isRegistered) {
        await client.sendMessage(`${numeroLimpio}@c.us`, `🐾 *RescataPet EC*

Hola ${nombre},
Tu código de verificación seguro es: *${pin}*

No compartas este código con nadie.`);
      } else {
        throw new Error('Ese número no tiene WhatsApp.');
      }
      console.log(`WhatsApp enviado a ${numeroLimpio}`);
    } catch (e) {
      console.error("Fallo al enviar WhatsApp:", e);
    }
  }
}

async function enviarOtpWhatsApp(telefono, codigo, nombre) {
  if (client && telefono) {
    try {
      let numeroLimpio = telefono.replace(/\D/g, '');
      if (numeroLimpio.length === 10 && numeroLimpio.startsWith('0')) {
        numeroLimpio = '593' + numeroLimpio.substring(1);
      }
      const isReg = await client.isRegisteredUser(`${numeroLimpio}@c.us`);
      if (isReg) {
        await client.sendMessage(`${numeroLimpio}@c.us`, `🐾 *RescataPet EC*

Hola ${nombre},
Tu código de verificación seguro es: *${codigo}*

No compartas este código con nadie.`);
      } else {
        throw new Error('Ese número no tiene WhatsApp.');
      }
      console.log(`[WA OTP] Código ${codigo} enviado a ${numeroLimpio}`);
      return true;
    } catch(e) {
      console.error(e);
      return false;
    }
  }
  return false;
}

module.exports = { setupNotifications, enviarMensajeVerificacion, enviarOtpWhatsApp };
