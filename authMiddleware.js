const jwt = require('jsonwebtoken');
const JWT_SECRET = 'secreto_taller_backend';

const authMiddleware = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  
  if (!token) return res.status(401).json({ error: 'Token no proporcionado.' });

  try {
    // Optimización: Validación de JWT en memoria mediante la firma, sin consultas a la BD.
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded; 
    next();
  } catch (error) {
    res.status(401).json({ error: 'Token inválido o expirado.' });
  }
};

module.exports = { authMiddleware, JWT_SECRET };
