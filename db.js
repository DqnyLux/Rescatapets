const { Sequelize } = require('sequelize');

// Configuración de SQLite (Base de datos local y rápida)
const sequelize = new Sequelize({
  dialect: 'sqlite',
  storage: './rescatapet.sqlite',
  logging: false
});

module.exports = sequelize;
