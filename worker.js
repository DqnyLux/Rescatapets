const { Worker } = require('bullmq');

const connection = { host: '127.0.0.1', port: 6379 };

const notificacionesWorker = new Worker('alertas', async (job) => {
  console.log(`[Worker BullMQ] Procesando tarea asíncrona: ${job.name}`);
  console.log(`[Worker BullMQ] Buscando usuarios cercanos a: ${job.data.ubicacion}...`);
  
  await new Promise(resolve => setTimeout(resolve, 3000));
  
  console.log(`[Worker BullMQ] Alertas enviadas para la mascota: ${job.data.mascota}`);
}, { connection });

notificacionesWorker.on('completed', job => console.log(`[Worker] Tarea ${job.id} completada.`));

module.exports = notificacionesWorker;
