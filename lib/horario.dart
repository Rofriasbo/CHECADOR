// En tu archivo: horario.dart

class Horario {
  final int? nhorario;
  final String nprofesor;
  final String nmat;
  final String dia;
  final String hora;
  final String edificio;
  final String salon;

  Horario({
    this.nhorario,
    required this.nprofesor,
    required this.nmat,
    required this.dia,
    required this.hora,
    required this.edificio,
    required this.salon,
  });

  Map<String, dynamic> toMap() {
    return {
      'nhorario': nhorario,
      'nprofesor': nprofesor,
      'nmat': nmat,
      'dia': dia,
      'hora': hora,
      'edificio': edificio,
      'salon': salon,
    };
  }

  // --- ESTA ES LA PARTE IMPORTANTE ---
  // Asegúrate de que 'fromMap' tenga los '??'
  factory Horario.fromMap(Map<String, dynamic> map) {
    return Horario(
      nhorario: map['NHORARIO'],
      nprofesor: map['NPROFESOR'] ?? '', // Si es nulo, usa ''
      nmat: map['NMAT'] ?? '',         // Si es nulo, usa ''
      dia: map['DIA'] ?? 'N/A',       // <-- Si DIA es nulo, usa 'N/A'
      hora: map['HORA'] ?? '',         // Si es nulo, usa ''
      edificio: map['EDIFICIO'] ?? '', // Si es nulo, usa ''
      salon: map['SALON'] ?? '',       // Si es nulo, usa ''
    );
  }
}