import re

with open('app.js', 'r', encoding='utf-8') as f:
    code = f.read()

patt = r"await Reporte\.bulkCreate\(\[[\s\S]*?\]\);"
repl = """await Reporte.bulkCreate([
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
    ]);"""
code = re.sub(patt, repl, code)

with open('app.js', 'w', encoding='utf-8') as f:
    f.write(code)
