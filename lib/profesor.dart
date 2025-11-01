class Profesor {
  final String nprofesor;
  final String nombre;
  final String carrera;

  Profesor({
    required this.nprofesor,
    required this.nombre,
    required this.carrera,
  });

  // Método para convertir el objeto Profesor a un Mapa
  Map<String, dynamic> toMap() {
    return {
      'nprofesor': nprofesor,
      'nombre': nombre,
      'carrera': carrera,
    };
  }

  // Método 'constructor factory' para crear un Profesor desde un Mapa
  factory Profesor.fromMap(Map<String, dynamic> map) {
    return Profesor(
      nprofesor: map['NPROFESOR'], // Nombres de la DB (mayúsculas)
      nombre: map['NOMBRE'],
      carrera: map['CARRERA'],
    );
  }
}