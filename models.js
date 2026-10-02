const { DataTypes } = require('sequelize');
const sequelize = require('./db');

const Usuario = sequelize.define('Usuario', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  nombre: { type: DataTypes.STRING, allowNull: false },
  email: { type: DataTypes.STRING, allowNull: false, unique: true },
  password: { type: DataTypes.STRING, allowNull: false }
}, {
  timestamps: false
});

const Reporte = sequelize.define('Reporte', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  mascota: { type: DataTypes.STRING, allowNull: false },
  especie: { type: DataTypes.STRING, defaultValue: 'Perro' },
  raza: { type: DataTypes.STRING, defaultValue: 'Mestizo' },
  ubicacion: { type: DataTypes.STRING, allowNull: false },
  ciudad: { type: DataTypes.STRING, defaultValue: 'Quito' },
  sector: { type: DataTypes.STRING, defaultValue: '' },
  latitud: { type: DataTypes.DOUBLE, defaultValue: -0.1807 },
  longitud: { type: DataTypes.DOUBLE, defaultValue: -78.4842 },
  estado: { type: DataTypes.STRING, defaultValue: 'PUBLICO' },
  tipoAlerta: { type: DataTypes.STRING, defaultValue: 'PERDIDO' },
  telefonoPrincipal: { type: DataTypes.STRING, defaultValue: '0990000000' },
  descripcion: { type: DataTypes.TEXT, defaultValue: '' },
  tamano: { type: DataTypes.STRING, defaultValue: 'Mediano' },
  sexo: { type: DataTypes.STRING, defaultValue: 'Macho' },
  color: { type: DataTypes.STRING, defaultValue: 'Blanco' },
  imagenBase64: { type: DataTypes.TEXT('long') } // Save Base64 images directly
}, {
  timestamps: true
});

// Relación 1 a N: Un Usuario tiene muchos Reportes
Usuario.hasMany(Reporte, { foreignKey: 'usuarioId', as: 'reportes' });
Reporte.belongsTo(Usuario, { foreignKey: 'usuarioId', as: 'usuario' });

module.exports = { Usuario, Reporte, sequelize };
