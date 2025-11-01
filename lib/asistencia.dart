class Asistencia {
  final int? idasistencia;
  final int nhorario;
  final String fecha;
  final bool asistencia; // Usamos bool en Dart

  Asistencia({
    this.idasistencia,
    required this.nhorario,
    required this.fecha,
    required this.asistencia,
  });

  // Método para convertir el objeto Asistencia a un Mapa
  Map<String, dynamic> toMap() {
    return {
      'idasistencia': idasistencia,
      'nhorario': nhorario,
      'fecha': fecha,
      'asistencia': asistencia ? 1 : 0, // Convierte bool a entero (1 o 0)
    };
  }

  // Método 'constructor factory' para crear una Asistencia desde un Mapa
  factory Asistencia.fromMap(Map<String, dynamic> map) {
    return Asistencia(
      idasistencia: map['IDASISTENCIA'], // Nombres de la DB (mayúsculas)
      nhorario: map['NHORARIO'],
      fecha: map['FECHA'],
      asistencia: map['ASISTENCIA'] == 1, // Convierte entero (1) a bool (true)
    );
  }
}