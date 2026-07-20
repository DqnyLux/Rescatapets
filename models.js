const { DataTypes } = require('sequelize');
const sequelize = require('./db');

const Usuario = sequelize.define('Usuario', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  nombre: { type: DataTypes.STRING, allowNull: false },
  email: { type: DataTypes.STRING, allowNull: false, unique: true }
}, {
  timestamps: false
});

const Reporte = sequelize.define('Reporte', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  mascota: { type: DataTypes.STRING, allowNull: false },
  ubicacion: { type: DataTypes.STRING, allowNull: false },
  estado: { type: DataTypes.STRING, defaultValue: 'PUBLICO' }
}, {
  timestamps: true
});

// Relación 1 a N: Un Usuario tiene muchos Reportes
Usuario.hasMany(Reporte, { foreignKey: 'usuarioId', as: 'reportes' });
Reporte.belongsTo(Usuario, { foreignKey: 'usuarioId', as: 'usuario' });

module.exports = { Usuario, Reporte, sequelize };
