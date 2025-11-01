class Materia {
  final String nmat;
  final String descripcion;

  Materia({
    required this.nmat,
    required this.descripcion,
  });

  // Método para convertir el objeto Materia a un Mapa
  Map<String, dynamic> toMap() {
    return {
      'nmat': nmat,
      'descripcion': descripcion,
    };
  }

  // Método 'constructor factory' para crear una Materia desde un Mapa
  factory Materia.fromMap(Map<String, dynamic> map) {
    return Materia(
      nmat: map['NMAT'], // Nombres de la DB (mayúsculas)
      descripcion: map['DESCRIPCION'],
    );
  }
}