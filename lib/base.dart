import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Importa los modelos
import 'materia.dart';
import 'profesor.dart';
import 'horario.dart'; // Asegúrate que este archivo tenga el método 'toMap()' y el campo 'dia'
import 'asistencia.dart'; // Asegúrate que este archivo tenga el método 'toMap()'

class DBAsistencia {
  static Future<Database> _conectarDB() async {
    return openDatabase(
      join(await getDatabasesPath(), "asistencia_escolar.db"),
      version: 1, // Si has cambiado la estructura, desinstala la app o incrementa la versión.
      onConfigure: (db) async {
        // Habilitar llaves foráneas
        await db.execute("PRAGMA foreign_keys = ON");
      },
      onCreate: (db, version) async {
        // Crear tabla MATERIA
        await db.execute('''
          CREATE TABLE MATERIA(
            NMAT TEXT PRIMARY KEY,
            DESCRIPCION TEXT NOT NULL
          )
        ''');

        // Crear tabla PROFESOR
        await db.execute('''
          CREATE TABLE PROFESOR(
            NPROFESOR TEXT PRIMARY KEY,
            NOMBRE TEXT NOT NULL,
            CARRERA TEXT NOT NULL
          )
        ''');

        // Crear tabla HORARIO (CON LA COLUMNA 'DIA')
        await db.execute('''
          CREATE TABLE HORARIO(
            NHORARIO INTEGER PRIMARY KEY AUTOINCREMENT,
            NPROFESOR TEXT NOT NULL,
            NMAT TEXT NOT NULL,
            DIA TEXT NOT NULL,        -- <-- CAMBIO APLICADO
            HORA TEXT NOT NULL,
            EDIFICIO TEXT NOT NULL,
            SALON TEXT NOT NULL,
            FOREIGN KEY (NPROFESOR) REFERENCES PROFESOR(NPROFESOR)
              ON DELETE CASCADE ON UPDATE CASCADE,
            FOREIGN KEY (NMAT) REFERENCES MATERIA(NMAT)
              ON DELETE CASCADE ON UPDATE CASCADE
          )
        ''');

        // Crear tabla ASISTENCIA
        await db.execute('''
          CREATE TABLE ASISTENCIA(
            IDASISTENCIA INTEGER PRIMARY KEY AUTOINCREMENT,
            NHORARIO INTEGER NOT NULL,
            FECHA TEXT NOT NULL,
            ASISTENCIA INTEGER NOT NULL, 
            FOREIGN KEY (NHORARIO) REFERENCES HORARIO(NHORARIO)
              ON DELETE CASCADE ON UPDATE CASCADE
          )
        ''');
      },
    );
  }

  // --- CRUD MATERIA (Corregido a .toMap) ---
  static Future<int> insertarMateria(Materia m) async {
    Database db = await _conectarDB();
    return db.insert("MATERIA", m.toMap(), // <-- CORREGIDO
        conflictAlgorithm: ConflictAlgorithm.fail);
  }

  static Future<int> actualizarMateria(Materia m) async {
    Database db = await _conectarDB();
    return db.update("MATERIA", m.toMap(), // <-- CORREGIDO
        where: "NMAT=?", whereArgs: [m.nmat]);
  }

  static Future<int> eliminarMateria(String nmat) async {
    Database db = await _conectarDB();
    return db.delete("MATERIA", where: "NMAT=?", whereArgs: [nmat]);
  }

  static Future<List<Materia>> mostrarMaterias() async {
    Database db = await _conectarDB();
    List<Map<String, dynamic>> datos = await db.query("MATERIA");
    // Asumimos que tu modelo Materia tiene 'fromMap'
    // Si usaste mi código anterior, 'fromMap' es el nombre correcto
    return datos.map((map) => Materia.fromMap(map)).toList();
  }

  // --- CRUD PROFESOR (Corregido a .toMap) ---
  static Future<int> insertarProfesor(Profesor p) async {
    Database db = await _conectarDB();
    return db.insert("PROFESOR", p.toMap(), // <-- CORREGIDO
        conflictAlgorithm: ConflictAlgorithm.fail);
  }

  static Future<int> actualizarProfesor(Profesor p) async {
    Database db = await _conectarDB();
    return db.update("PROFESOR", p.toMap(), // <-- CORREGIDO
        where: "NPROFESOR=?", whereArgs: [p.nprofesor]);
  }

  static Future<int> eliminarProfesor(String nprofesor) async {
    Database db = await _conectarDB();
    return db.delete("PROFESOR", where: "NPROFESOR=?", whereArgs: [nprofesor]);
  }

  static Future<List<Profesor>> mostrarProfesores() async {
    Database db = await _conectarDB();
    List<Map<String, dynamic>> datos = await db.query("PROFESOR");
    // Asumimos que tu modelo Profesor tiene 'fromMap'
    return datos.map((map) => Profesor.fromMap(map)).toList();
  }

  // --- CRUD HORARIO (Corregido a .toMap y con 'dia') ---
  static Future<int> insertarHorario(Horario h) async {
    Database db = await _conectarDB();
    return db.insert("HORARIO", h.toMap(), // <-- CORREGIDO
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<int> actualizarHorario(Horario h) async {
    Database db = await _conectarDB();
    return db.update("HORARIO", h.toMap(), // <-- CORREGIDO
        where: "NHORARIO=?", whereArgs: [h.nhorario]);
  }

  static Future<int> eliminarHorario(int nhorario) async {
    Database db = await _conectarDB();
    return db.delete("HORARIO", where: "NHORARIO=?", whereArgs: [nhorario]);
  }

  static Future<List<Horario>> mostrarHorarios() async {
    Database db = await _conectarDB();
    List<Map<String, dynamic>> datos = await db.query("HORARIO");
    // Usamos el 'fromMap' que ya debe incluir 'dia'
    return datos.map((map) => Horario.fromMap(map)).toList();
  }

  // --- CRUD ASISTENCIA (Corregido a .toMap) ---
  static Future<int> insertarAsistencia(Asistencia a) async {
    Database db = await _conectarDB();
    return db.insert("ASISTENCIA", a.toMap(), // <-- CORREGIDO
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<int> actualizarAsistencia(Asistencia a) async {
    Database db = await _conectarDB();
    return db.update("ASISTENCIA", a.toMap(), // <-- CORREGIDO
        where: "IDASISTENCIA=?", whereArgs: [a.idasistencia]);
  }

  static Future<int> eliminarAsistencia(int idasistencia) async {
    Database db = await _conectarDB();
    return db.delete("ASISTENCIA",
        where: "IDASISTENCIA=?", whereArgs: [idasistencia]);
  }

  static Future<List<Asistencia>> mostrarAsistencias() async {
    Database db = await _conectarDB();
    List<Map<String, dynamic>> datos = await db.query("ASISTENCIA");
    // Asumimos que tu modelo Asistencia tiene 'fromMap'
    return datos.map((map) => Asistencia.fromMap(map)).toList();
  }

  // --- CONSULTAS CON JOIN (CON LA COLUMNA 'DIA') ---

  static Future<List<Map<String, dynamic>>> mostrarAsistenciasDetalladas() async {
    Database db = await _conectarDB();
    return db.rawQuery('''
      SELECT 
        A.IDASISTENCIA, A.FECHA, A.ASISTENCIA,
        H.HORA, H.SALON, H.EDIFICIO, H.DIA, -- <-- CAMBIO APLICADO
        M.DESCRIPCION AS MATERIA,
        P.NOMBRE AS PROFESOR
      FROM ASISTENCIA AS A
      INNER JOIN HORARIO AS H ON A.NHORARIO = H.NHORARIO
      INNER JOIN MATERIA AS M ON H.NMAT = M.NMAT
      INNER JOIN PROFESOR AS P ON H.NPROFESOR = P.NPROFESOR
      ORDER BY A.FECHA DESC
    ''');
  }

  static Future<List<Map<String, dynamic>>> mostrarHorariosDetallados() async {
    Database db = await _conectarDB();
    return db.rawQuery('''
      SELECT 
        H.NHORARIO, H.HORA, H.SALON, H.EDIFICIO, H.DIA, -- <-- CAMBIO APLICADO
        M.DESCRIPCION AS MATERIA,
        P.NOMBRE AS PROFESOR
      FROM HORARIO AS H
      INNER JOIN MATERIA AS M ON H.NMAT = M.NMAT
      INNER JOIN PROFESOR AS P ON H.NPROFESOR = P.NPROFESOR
    ''');
  }

  static Future<List<Map<String, dynamic>>> mostrarHorariosDetalladosPorProfesor(
      String nprofesor) async {
    Database db = await _conectarDB();
    return db.rawQuery('''
      SELECT 
        H.NHORARIO, H.HORA, H.SALON, H.EDIFICIO, H.DIA, -- <-- CAMBIO APLICADO
        M.DESCRIPCION AS MATERIA,
        P.NOMBRE AS PROFESOR
      FROM HORARIO AS H
      INNER JOIN MATERIA AS M ON H.NMAT = M.NMAT
      INNER JOIN PROFESOR AS P ON H.NPROFESOR = P.NPROFESOR
      WHERE P.NPROFESOR = ?
    ''', [nprofesor]);
  }
}