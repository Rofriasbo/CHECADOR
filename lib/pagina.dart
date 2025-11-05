import 'package:flutter/material.dart';
import 'asistencia.dart';
import 'horario.dart';
import 'profesor.dart';
import 'materia.dart';
import 'base.dart';

// +++ CAMBIOS RODOLFO +++
class APP03 extends StatefulWidget {
  const APP03({super.key});

  @override
  State<APP03> createState() => _APP03State();
}

// +++ CAMBIOS RODOLFO +++
class _APP03State extends State<APP03> with SingleTickerProviderStateMixin {
  int _index = 0;
  bool colorsw = false;
  late TabController _tabController;

  // +++ CAMBIOS RODOLFO +++
  // Listas de datos
  List<Profesor> _profesores = [];
  List<Materia> _materias = [];
  List<Horario> _horarios = [];
  List<Asistencia> _asistencias = [];
  List<Map<String, dynamic>> _horariosDetallados = [];
  List<Map<String, dynamic>> _asistenciasDetalladas = [];

  // +++ CAMBIOS RODOLFO +++
  // Controladores de texto
  final nprofesorCtrl = TextEditingController();
  final nombreCtrl = TextEditingController();
  final carreraCtrl = TextEditingController();
  final nmatCtrl = TextEditingController();
  final descripcionCtrl = TextEditingController();
  final horaCtrl = TextEditingController();
  final nhorarioAsistenciaCtrl = TextEditingController();
  final fechaCtrl = TextEditingController();

  // +++ CAMBIOS RODOLFO +++
  // Variables de estado para formularios
  String? _selectedNProfesor;
  String? _selectedNMat;
  String? _selectedDia;
  String? _selectedEdificio;
  String? _selectedSalon;
  List<String> _salonesDisponibles = [];
  TimeOfDay? _selectedHoraInicio;
  TimeOfDay? _selectedHoraFin;
  bool _asistenciaValor = false;

  // +++ CAMBIOS RODOLFO +++
  // Variables de estado para Asistencias
  String? _selectedProfesorAsistencia;
  Map<int, bool> _asistenciasMarcadas = {};

  // +++ CAMBIOS RODOLFO +++
  // VARIABLES PARA CONSULTAS (Por Edificio)
  String? _selectedEdificioConsulta;
  final List<String> _edificiosConsulta = ['UD', 'LABC', 'CB'];

  // +++ CAMBIOS MURGO +++
  // VARIABLES PARA CONSULTAS (Por Profesor)
  String? _selectedProfesorConsulta; // Nro de Profesor (ID)
  // +++ FIN CAMBIOS MURGO +++

  // +++ CAMBIOS RODOLFO +++
  // Regex para parsear "HH:MM a HH:MM"
  final RegExp _horaRegExp =
  RegExp(r'^([0-9]+):([0-9]+) a ([0-9]+):([0-9]+)$');

  // +++ CAMBIOS RODOLFO +++
  // Listas de salones
  final List<String> _diasSemana = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'
  ];
  final List<String> _salonesUD = List.generate(11, (i) => 'UD${i + 1}');
  final List<String> _salonesLABC = [
    'LABCSA', 'LABCSB', 'LABCSC', 'CSC1', 'CSC2', 'TDM', 'TBD'
  ];
  final List<String> _salonesCB = List.generate(10, (i) => 'CB${i + 1}');

  @override
  void initState() {
    super.initState();
    // +++ CAMBIOS MURGO +++
    // Se ajusta el TabController a 4 pestañas (eliminando la de fecha)
    _tabController = TabController(length: 4, vsync: this);
    // +++ FIN CAMBIOS MURGO +++
    _cargarDatos();
  }

  // +++ CAMBIOS RODOLFO +++
  @override
  void dispose() {
    _tabController.dispose();
    nprofesorCtrl.dispose();
    nombreCtrl.dispose();
    carreraCtrl.dispose();
    nmatCtrl.dispose();
    descripcionCtrl.dispose();
    horaCtrl.dispose();
    nhorarioAsistenciaCtrl.dispose();
    fechaCtrl.dispose();
    super.dispose();
  }

  // +++ CAMBIOS RODOLFO +++
  void _cargarDatos() async {
    _cargarProfesores();
    _cargarMaterias();
    await _cargarHorarios();
    await _cargarAsistencias();
    _cargarDatosConsulta();
  }

  // +++ CAMBIOS RODOLFO +++
  void _limpiarControladores() {
    nprofesorCtrl.clear();
    nombreCtrl.clear();
    carreraCtrl.clear();
    nmatCtrl.clear();
    descripcionCtrl.clear();
    horaCtrl.clear();
    nhorarioAsistenciaCtrl.clear();
    fechaCtrl.clear();

    setState(() {
      _asistenciaValor = false;
      _selectedNProfesor = null;
      _selectedNMat = null;
      _selectedDia = null;
      _selectedEdificio = null;
      _selectedSalon = null;
      _salonesDisponibles = [];
      _selectedHoraInicio = null;
      _selectedHoraFin = null;
      _selectedProfesorAsistencia = null;
      _asistenciasMarcadas.clear();

      _selectedEdificioConsulta = null;

      // +++ CAMBIOS MURGO +++
      _selectedProfesorConsulta = null;
      // Se elimina la variable de fecha
      // +++ FIN CAMBIOS MURGO +++
    });
  }

  // --- MÉTODOS CRUD PROFESOR (RODOLFO) ---
  // +++ CAMBIOS RODOLFO +++
  void _cargarProfesores() async {
    final profesores = await DBAsistencia.mostrarProfesores();
    if (mounted) {
      setState(() {
        _profesores = profesores;
      });
    }
  }

  // +++ CAMBIOS RODOLFO +++
  void _agregarProfesor() async {
    if (nombreCtrl.text.isEmpty || carreraCtrl.text.isEmpty) {
      _mostrarSnackBar("Nombre y Carrera son obligatorios");
      return;
    }
    final String nProfesorGenerado =
    DateTime.now().millisecondsSinceEpoch.toString();

    final profesor = Profesor(
      nprofesor: nProfesorGenerado,
      nombre: nombreCtrl.text,
      carrera: carreraCtrl.text,
    );
    try {
      await DBAsistencia.insertarProfesor(profesor);
      _limpiarControladores();
      _cargarProfesores();
      _mostrarSnackBar("Profesor agregado correctamente");
    } catch (e) {
      _mostrarSnackBar("Error al agregar profesor: $e");
    }
  }

  // +++ CAMBIOS RODOLFO +++
  void _eliminarProfesor(String nprofesor) async {
    await DBAsistencia.eliminarProfesor(nprofesor);
    _cargarProfesores();
    _cargarDatosConsulta();
    _mostrarSnackBar("Profesor eliminado");
  }

  // +++ CAMBIOS RODOLFO +++
  void _mostrarDialogoActualizarProfesor(Profesor profesor) {
    nprofesorCtrl.text = profesor.nprofesor;
    nombreCtrl.text = profesor.nombre;
    carreraCtrl.text = profesor.carrera;
    _mostrarDialogo(
      "Actualizar Profesor",
      _buildFormularioProfesor(actualizando: true),
      onGuardar: () => _actualizarProfesor(),
    );
  }

  // +++ CAMBIOS RODOLFO +++
  void _actualizarProfesor() async {
    final p = Profesor(
      nprofesor: nprofesorCtrl.text,
      nombre: nombreCtrl.text,
      carrera: carreraCtrl.text,
    );
    await DBAsistencia.actualizarProfesor(p);
    _limpiarControladores();
    _cargarProfesores();
    _cargarDatosConsulta();
    Navigator.pop(context);
    _mostrarSnackBar("Profesor actualizado");
  }

  // --- MÉTODOS CRUD MATERIA (RODOLFO) ---
  // +++ CAMBIOS RODOLFO +++
  void _cargarMaterias() async {
    final materias = await DBAsistencia.mostrarMaterias();
    if (mounted) {
      setState(() {
        _materias = materias;
      });
    }
  }

  // +++ CAMBIOS RODOLFO +++
  void _agregarMateria() async {
    if (descripcionCtrl.text.isEmpty) {
      _mostrarSnackBar("La descripción de la Materia es obligatoria");
      return;
    }
    final String nMatGenerado = DateTime.now().millisecondsSinceEpoch.toString();

    final materia = Materia(
      nmat: nMatGenerado,
      descripcion: descripcionCtrl.text,
    );
    try {
      await DBAsistencia.insertarMateria(materia);
      _limpiarControladores();
      _cargarMaterias();
      _mostrarSnackBar("Materia agregada correctamente");
    } catch (e) {
      _mostrarSnackBar("Error al agregar materia: $e");
    }
  }

  // +++ CAMBIOS RODOLFO +++
  void _eliminarMateria(String nmat) async {
    await DBAsistencia.eliminarMateria(nmat);
    _cargarMaterias();
    _cargarDatosConsulta();
    _mostrarSnackBar("Materia eliminada");
  }

  // +++ CAMBIOS RODOLFO +++
  void _mostrarDialogoActualizarMateria(Materia materia) {
    nmatCtrl.text = materia.nmat;
    descripcionCtrl.text = materia.descripcion;
    _mostrarDialogo(
      "Actualizar Materia",
      _buildFormularioMateria(actualizando: true),
      onGuardar: () => _actualizarMateria(),
    );
  }

  // +++ CAMBIOS RODOLFO +++
  void _actualizarMateria() async {
    final m = Materia(
      nmat: nmatCtrl.text,
      descripcion: descripcionCtrl.text,
    );
    await DBAsistencia.actualizarMateria(m);
    _limpiarControladores();
    _cargarMaterias();
    _cargarDatosConsulta();
    Navigator.pop(context);
    _mostrarSnackBar("Materia actualizada");
  }

  // --- MÉTODOS CRUD HORARIO (RODOLFO) ---
  // +++ CAMBIOS RODOLFO +++
  Future<void> _seleccionarRangoHora(
      BuildContext context, Function(VoidCallback) updateState) async {
    final TimeOfDay? inicio = await showTimePicker(
      context: context,
      initialTime: _selectedHoraInicio ?? TimeOfDay(hour: 7, minute: 0),
      helpText: "SELECCIONAR HORA DE INICIO",
    );

    if (inicio == null) return;

    final TimeOfDay? fin = await showTimePicker(
      context: context,
      initialTime: _selectedHoraFin ?? inicio.replacing(hour: inicio.hour + 2),
      helpText: "SELECCIONAR HORA DE FIN",
    );

    if (fin == null) return;

    double _timeToDouble(TimeOfDay time) => time.hour + time.minute / 60.0;
    if (_timeToDouble(fin) <= _timeToDouble(inicio)) {
      _mostrarSnackBar("La hora de fin debe ser posterior a la hora de inicio");
      return;
    }

    updateState(() {
      _selectedHoraInicio = inicio;
      _selectedHoraFin = fin;
      String pad(int n) => n.toString().padLeft(2, '0');
      horaCtrl.text =
      "${pad(inicio.hour)}:${pad(inicio.minute)} a ${pad(fin.hour)}:${pad(fin.minute)}";
    });
  }

  // +++ CAMBIOS RODOLFO +++
  Future<bool> _validarHorario({
    required String? dia,
    required String? horaRango,
    required String? salon,
    int? nhorarioExcluir,
  }) async {
    if (_selectedNProfesor == null ||
        _selectedNMat == null ||
        dia == null ||
        horaRango == null ||
        horaRango.isEmpty ||
        _selectedEdificio == null ||
        salon == null) {
      _mostrarSnackBar("Todos los campos de Horario son obligatorios");
      return false;
    }

    final matches = _horaRegExp.firstMatch(horaRango);
    if (matches == null) {
      _mostrarSnackBar("Formato de hora inválido.");
      return false;
    }

    final horaInicio = int.parse(matches.group(1)!);
    final minInicio = int.parse(matches.group(2)!);
    final horaFin = int.parse(matches.group(3)!);
    final minFin = int.parse(matches.group(4)!);

    final nuevaInicio = TimeOfDay(hour: horaInicio, minute: minInicio);
    final nuevaFin = TimeOfDay(hour: horaFin, minute: minFin);

    double _timeToDouble(TimeOfDay time) => time.hour + time.minute / 60.0;
    final nuevaIniVal = _timeToDouble(nuevaInicio);
    final nuevaFinVal = _timeToDouble(nuevaFin);

    if (nuevaIniVal >= nuevaFinVal) {
      _mostrarSnackBar("La hora de inicio debe ser anterior a la hora de fin");
      return false;
    }

    await _cargarHorarios();

    for (var hExistente in _horarios) {
      if (hExistente.nhorario == nhorarioExcluir) continue;

      if (hExistente.dia == dia && hExistente.salon == salon) {
        final matchesExistente = _horaRegExp.firstMatch(hExistente.hora);
        if (matchesExistente == null) continue;

        final existHoraInicio = int.parse(matchesExistente.group(1)!);
        final existMinInicio = int.parse(matchesExistente.group(2)!);
        final existHoraFin = int.parse(matchesExistente.group(3)!);
        final existMinFin = int.parse(matchesExistente.group(4)!);

        final existenteInicio =
        TimeOfDay(hour: existHoraInicio, minute: existMinInicio);
        final existenteFin =
        TimeOfDay(hour: existHoraFin, minute: existMinFin);

        final existIniVal = _timeToDouble(existenteInicio);
        final existFinVal = _timeToDouble(existenteFin);

        if (nuevaIniVal < existFinVal && nuevaFinVal > existIniVal) {
          _mostrarSnackBar(
              "Conflicto: El salón '$salon' ya está ocupado el '$dia' en ese rango.");
          return false;
        }
      }
    }
    return true;
  }

  // +++ CAMBIOS RODOLFO +++
  Future<void> _cargarHorarios() async {
    try {
      final horarios = await DBAsistencia.mostrarHorarios();
      if (mounted) {
        setState(() {
          _horarios = horarios;
        });
      }
    } catch (e) {
      _mostrarSnackBar("Error al leer horarios de la DB: $e");
    }
  }

  // +++ CAMBIOS RODOLFO +++
  void _agregarHorario() async {
    bool esValido = false;
    try {
      esValido = await _validarHorario(
        dia: _selectedDia,
        horaRango: horaCtrl.text,
        salon: _selectedSalon,
        nhorarioExcluir: null,
      );
    } catch (e) {
      _mostrarSnackBar("Error al validar: $e. Revisa 'horario.dart'.");
      return;
    }

    if (!esValido) {
      return;
    }

    final horario = Horario(
      nprofesor: _selectedNProfesor!,
      nmat: _selectedNMat!,
      dia: _selectedDia!,
      hora: horaCtrl.text,
      edificio: _selectedEdificio!,
      salon: _selectedSalon!,
    );

    try {
      await DBAsistencia.insertarHorario(horario);
      _limpiarControladores();
      _cargarHorarios();
      _cargarDatosConsulta();
      _mostrarSnackBar("Horario agregado correctamente");
    } catch (e) {
      _mostrarSnackBar("Error al guardar en la base de datos: $e");
    }
  }

  // +++ CAMBIOS RODOLFO +++
  void _eliminarHorario(int nhorario) async {
    await DBAsistencia.eliminarHorario(nhorario);
    _cargarHorarios();
    _cargarDatosConsulta();
    _mostrarSnackBar("Horario eliminado");
  }

  // +++ CAMBIOS RODOLFO +++
  void _mostrarDialogoActualizarHorario(Horario horario) {
    _selectedNProfesor = horario.nprofesor;
    _selectedNMat = horario.nmat;
    _selectedDia = horario.dia;
    _selectedEdificio = horario.edificio;
    _selectedSalon = horario.salon;

    if (horario.edificio == 'UD') {
      _salonesDisponibles = _salonesUD;
    } else if (horario.edificio == 'LABC') {
      _salonesDisponibles = _salonesLABC;
    } else if (horario.edificio == 'CB') {
      _salonesDisponibles = _salonesCB;
    } else {
      _salonesDisponibles = [];
    }

    _selectedHoraInicio = null;
    _selectedHoraFin = null;
    final matches = _horaRegExp.firstMatch(horario.hora);
    if (matches != null) {
      _selectedHoraInicio = TimeOfDay(
          hour: int.parse(matches.group(1)!),
          minute: int.parse(matches.group(2)!));
      _selectedHoraFin = TimeOfDay(
          hour: int.parse(matches.group(3)!),
          minute: int.parse(matches.group(4)!));
    }

    horaCtrl.text = horario.hora;
    nprofesorCtrl.clear();
    nmatCtrl.clear();

    _mostrarDialogo(
      "Actualizar Horario",
      _buildFormularioHorario(actualizando: true),
      onGuardar: () => _actualizarHorario(horario.nhorario!),
    );
  }

  // +++ CAMBIOS RODOLFO +++
  void _actualizarHorario(int nhorario) async {
    bool esValido = false;
    try {
      esValido = await _validarHorario(
        dia: _selectedDia,
        horaRango: horaCtrl.text,
        salon: _selectedSalon,
        nhorarioExcluir: nhorario,
      );
    } catch (e) {
      _mostrarSnackBar("Error al validar: $e. Revisa 'horario.dart'.");
      return;
    }

    if (!esValido) {
      return;
    }

    final h = Horario(
      nhorario: nhorario,
      nprofesor: _selectedNProfesor!,
      nmat: _selectedNMat!,
      dia: _selectedDia!,
      hora: horaCtrl.text,
      edificio: _selectedEdificio!,
      salon: _selectedSalon!,
    );

    try {
      await DBAsistencia.actualizarHorario(h);
      _limpiarControladores();
      _cargarHorarios();
      _cargarDatosConsulta();
      Navigator.pop(context);
      _mostrarSnackBar("Horario actualizado");
    } catch (e) {
      _mostrarSnackBar("Error al actualizar en la base de datos: $e");
    }
  }

  // --- MÉTODOS CRUD ASISTENCIA (RODOLFO) ---
  // +++ CAMBIOS RODOLFO +++
  Future<void> _cargarAsistencias() async {
    final asistencias = await DBAsistencia.mostrarAsistencias();
    if (mounted) {
      setState(() {
        _asistencias = asistencias;
      });
    }
  }

  // +++ CAMBIOS RODOLFO +++
  void _guardarAsistenciasMarcadas() async {
    if (_selectedProfesorAsistencia == null) {
      _mostrarSnackBar("Seleccione un profesor.");
      return;
    }

    final String diaActual = _getDiaActualString();
    final String fechaActual = DateTime.now()
        .toIso8601String()
        .replaceAll('T', ' ')
        .substring(0, 23);

    final Set<int> nHorariosDeHoy = _horarios
        .where((h) =>
    h.nprofesor == _selectedProfesorAsistencia && h.dia == diaActual)
        .map((h) => h.nhorario!)
        .toSet();

    final Map<int, bool> asistenciasParaGuardar = Map.from(_asistenciasMarcadas)
      ..removeWhere((key, value) => !nHorariosDeHoy.contains(key));

    if (asistenciasParaGuardar.isEmpty) {
      _mostrarSnackBar("No hay asistencias marcadas válidas para guardar hoy.");
      return;
    }

    int contador = 0;
    try {
      for (var entry in asistenciasParaGuardar.entries) {
        final asistencia = Asistencia(
          nhorario: entry.key,
          fecha: fechaActual,
          asistencia: entry.value,
        );
        await DBAsistencia.insertarAsistencia(asistencia);
        contador++;
      }

      _limpiarControladores();
      await _cargarAsistencias();
      _cargarDatosConsulta();
      setState(() {});
      _mostrarSnackBar("$contador asistencias guardadas correctamente.");
    } catch (e) {
      _mostrarSnackBar("Error al guardar asistencias: $e");
    }
  }

  // +++ CAMBIOS RODOLFO +++
  void _eliminarAsistencia(int idasistencia) async {
    await DBAsistencia.eliminarAsistencia(idasistencia);
    _cargarAsistencias();
    _cargarDatosConsulta();
    _mostrarSnackBar("Asistencia eliminada");
  }

  // +++ CAMBIOS RODOLFO +++
  void _mostrarDialogoActualizarAsistencia(Asistencia asistencia) {
    nhorarioAsistenciaCtrl.text = asistencia.nhorario.toString();
    fechaCtrl.text = asistencia.fecha;
    setState(() {
      _asistenciaValor = asistencia.asistencia;
    });

    _mostrarDialogo(
      "Actualizar Asistencia",
      StatefulBuilder(builder: (context, setDialogState) {
        return _buildFormularioAsistencia(
          setDialogState: setDialogState,
        );
      }),
      onGuardar: () => _actualizarAsistencia(asistencia.idasistencia!),
    );
  }

  // +++ CAMBIOS RODOLFO +++
  void _actualizarAsistencia(int idasistencia) async {
    final a = Asistencia(
      idasistencia: idasistencia,
      nhorario: int.tryParse(nhorarioAsistenciaCtrl.text) ?? 0,
      fecha: fechaCtrl.text,
      asistencia: _asistenciaValor,
    );
    await DBAsistencia.actualizarAsistencia(a);
    _limpiarControladores();
    _cargarAsistencias();
    _cargarDatosConsulta();
    Navigator.pop(context);
    _mostrarSnackBar("Asistencia actualizada");
  }

  // --- MÉTODOS DE CONSULTA (RODOLFO) ---
  // +++ CAMBIOS RODOLFO +++
  void _cargarDatosConsulta() async {
    final hDetallados = await DBAsistencia.mostrarHorariosDetallados();
    final aDetalladas = await DBAsistencia.mostrarAsistenciasDetalladas();
    if (mounted) {
      setState(() {
        _horariosDetallados = hDetallados;
        _asistenciasDetalladas = aDetalladas;
      });
    }
  }

  // --- MÉTODOS DE UI (RODOLFO) ---
  // +++ CAMBIOS RODOLFO +++
  void _mostrarSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // +++ CAMBIOS RODOLFO +++
  void _mostrarDialogo(String title, Widget content,
      {required VoidCallback onGuardar}) {
    showDialog(
      context: context,
      builder: (context) {
        // +++ CAMBIOS MURGO +++
        // (Modo Oscuro: Fondo gris oscuro, Título blanco)
        return AlertDialog(
          backgroundColor:
          colorsw ? Colors.grey[800] : Colors.orange.shade50,
          title: Text(title,
              style: TextStyle(
                  color: colorsw ? Colors.white : Colors.brown)),
          // (Wrapper de Theme para contraste de texto en el contenido)
          content: Theme(
            data: Theme.of(context).copyWith(
              brightness: colorsw ? Brightness.dark : Brightness.light,
              // Estilo para el texto DENTRO del Dropdown
              textTheme: Theme.of(context).textTheme.copyWith(
                titleMedium: TextStyle(color: colorsw ? Colors.white : Colors.black),
              ),
              inputDecorationTheme: InputDecorationTheme(
                labelStyle: TextStyle(
                    color: colorsw ? Colors.white70 : Colors.brown[700]),
                hintStyle: TextStyle(color: colorsw ? Colors.white54 : Colors.black54),
              ),
              listTileTheme: ListTileThemeData(
                textColor: colorsw ? Colors.white : Colors.black,
                iconColor: colorsw ? Colors.white70 : Colors.brown.shade700,
              ),
            ),
            child: SingleChildScrollView(child: content),
          ),
          actions: [
            TextButton(
              child:
              Text("Cancelar", style: TextStyle(color: Colors.deepOrange)),
              onPressed: () {
                _limpiarControladores();
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent),
              child: Text("Guardar"),
              onPressed: onGuardar,
            ),
          ],
        );
        // +++ FIN CAMBIOS MURGO +++
      },
    );
  }

  // --- BUILDERS DE FORMULARIOS (RODOLFO) ---
  // +++ CAMBIOS RODOLFO +++
  Widget _buildFormularioProfesor({bool actualizando = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (actualizando)
          TextField(
              controller: nprofesorCtrl,
              readOnly: true,
              decoration: InputDecoration(labelText: "N° Profesor (PK)")),
        TextField(
            controller: nombreCtrl,
            decoration: InputDecoration(labelText: "Nombre")),
        TextField(
            controller: carreraCtrl,
            decoration: InputDecoration(labelText: "Carrera")),
      ],
    );
  }

  // +++ CAMBIOS RODOLFO +++
  Widget _buildFormularioMateria({bool actualizando = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (actualizando)
          TextField(
              controller: nmatCtrl,
              readOnly: true,
              decoration: InputDecoration(labelText: "N° Materia (PK)")),
        TextField(
            controller: descripcionCtrl,
            decoration: InputDecoration(labelText: "Descripción")),
      ],
    );
  }

  // +++ CAMBIOS RODOLFO +++
  // (Corrección de layout)
  Widget _buildFormularioHorarioContenido(
      void Function(VoidCallback) updateState) {
    void _onEdificioChanged(String? newValue) {
      updateState(() {
        _selectedEdificio = newValue;
        _selectedSalon = null;
        if (newValue == 'UD') {
          _salonesDisponibles = _salonesUD;
        } else if (newValue == 'LABC') {
          _salonesDisponibles = _salonesLABC;
        } else if (newValue == 'CB') {
          _salonesDisponibles = _salonesCB;
        } else {
          _salonesDisponibles = [];
        }
      });
    }

    String _getHoraRangoTexto() {
      if (_selectedHoraInicio == null || _selectedHoraFin == null) {
        return "Seleccione un rango de hora";
      }
      final String inicioFormato = _selectedHoraInicio!.format(context);
      final String finFormato = _selectedHoraFin!.format(context);
      return "$inicioFormato a $finFormato";
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedNProfesor,
          hint: Text("Seleccione un Profesor"),
          isExpanded: true,
          // +++ CAMBIOS MURGO (Contraste) +++
          style: TextStyle(color: colorsw ? Colors.white : Colors.black),
          // +++ FIN CAMBIOS MURGO +++
          items: _profesores.map((profesor) {
            return DropdownMenuItem(
              value: profesor.nprofesor,
              child: Text(profesor.nombre, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (value) {
            updateState(() {
              _selectedNProfesor = value;
            });
          },
          decoration: InputDecoration(labelText: "Profesor"),
          validator: (value) => value == null ? 'Campo requerido' : null,
        ),
        DropdownButtonFormField<String>(
          value: _selectedNMat,
          hint: Text("Seleccione una Materia"),
          isExpanded: true,
          // +++ CAMBIOS MURGO (Contraste) +++
          style: TextStyle(color: colorsw ? Colors.white : Colors.black),
          // +++ FIN CAMBIOS MURGO +++
          items: _materias.map((materia) {
            return DropdownMenuItem(
              value: materia.nmat,
              child: Text(materia.descripcion, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (value) {
            updateState(() {
              _selectedNMat = value;
            });
          },
          decoration: InputDecoration(labelText: "Materia"),
          validator: (value) => value == null ? 'Campo requerido' : null,
        ),
        DropdownButtonFormField<String>(
          value: _selectedDia,
          hint: Text("Seleccione un Día"),
          // +++ CAMBIOS MURGO (Contraste) +++
          style: TextStyle(color: colorsw ? Colors.white : Colors.black),
          // +++ FIN CAMBIOS MURGO +++
          items: _diasSemana.map((dia) {
            return DropdownMenuItem(
              value: dia,
              child: Text(dia),
            );
          }).toList(),
          onChanged: (value) {
            updateState(() {
              _selectedDia = value;
            });
          },
          decoration: InputDecoration(labelText: "Día de la semana"),
          validator: (value) => value == null ? 'Campo requerido' : null,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          // +++ CAMBIOS MURGO (Contraste) +++
          leading: Icon(Icons.access_time,
              color: colorsw ? Colors.white70 : Colors.brown.shade700),
          title: Text("Rango de Hora"),
          subtitle: Text(
            _getHoraRangoTexto(),
            style: TextStyle(
                color: _selectedHoraInicio == null
                    ? Colors.grey.shade600
                    : (colorsw ? Colors.white : Colors.black), // Corregido
                fontSize: 16),
          ),
          // +++ FIN CAMBIOS MURGO +++
          onTap: () {
            _seleccionarRangoHora(context, updateState);
          },
        ),
        Divider(color: Colors.grey.shade700, height: 1),
        DropdownButtonFormField<String>(
          value: _selectedEdificio,
          hint: Text("Seleccione un Edificio"),
          // +++ CAMBIOS MURGO (Contraste) +++
          style: TextStyle(color: colorsw ? Colors.white : Colors.black),
          // +++ FIN CAMBIOS MURGO +++
          items: ['UD', 'LABC', 'CB'].map((edificio) {
            return DropdownMenuItem(
              value: edificio,
              child: Text(edificio),
            );
          }).toList(),
          onChanged: _onEdificioChanged,
          decoration: InputDecoration(labelText: "Edificio"),
          validator: (value) => value == null ? 'Campo requerido' : null,
        ),
        DropdownButtonFormField<String>(
          value: _selectedSalon,
          hint: Text(_selectedEdificio == null
              ? "Seleccione Edificio"
              : "Seleccione un Salón"),
          isExpanded: true,
          // +++ CAMBIOS MURGO (Contraste) +++
          style: TextStyle(color: colorsw ? Colors.white : Colors.black),
          // +++ FIN CAMBIOS MURGO +++
          items: _salonesDisponibles.map((salon) {
            return DropdownMenuItem(
              value: salon,
              child: Text(salon),
            );
          }).toList(),
          onChanged: _salonesDisponibles.isEmpty
              ? null
              : (value) {
            updateState(() {
              _selectedSalon = value;
            });
          },
          decoration: InputDecoration(labelText: "Salón"),
          validator: (value) => value == null ? 'Campo requerido' : null,
        ),
      ],
    );
  }

  // +++ CAMBIOS RODOLFO +++
  // (Corrección de layout)
  Widget _buildFormularioHorario({bool actualizando = false}) {
    if (actualizando) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          return _buildFormularioHorarioContenido((fn) => setDialogState(fn));
        },
      );
    } else {
      return _buildFormularioHorarioContenido((fn) => setState(fn));
    }
  }

  // +++ CAMBIOS RODOLFO +++
  Widget _buildFormularioAsistencia({
    required Function(Function()) setDialogState,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
            controller: nhorarioAsistenciaCtrl,
            readOnly: true,
            decoration: InputDecoration(labelText: "N° Horario (FK)")),
        TextField(
            controller: fechaCtrl,
            readOnly: true,
            decoration: InputDecoration(labelText: "Fecha de Registro")),
        SwitchListTile(
          title: Text("Asistió"),
          value: _asistenciaValor,
          onChanged: (val) {
            setDialogState(() {
              _asistenciaValor = val;
            });
          },
        ),
      ],
    );
  }

  // --- BUILDER PRINCIPAL (RODOLFO) ---
  // +++ CAMBIOS RODOLFO +++
  Widget? contenido() {
    switch (_index) {
      case 0:
        return _buildProfesoresCRUD();
      case 1:
        return _buildMateriasCRUD();
      case 2:
        return _buildHorariosCRUD();
      case 3:
        return _buildAsistenciasCRUD();
      case 4:
        return _buildConsultasView();
      default:
        return _buildProfesoresCRUD();
    }
  }

  // +++ CAMBIOS MURGO +++
  // Define un tema oscuro reutilizable para aplicar a todas las pestañas
  ThemeData _getAppDarkTheme() {
    final baseTheme = ThemeData.dark(); // El tema oscuro base
    return baseTheme.copyWith(
      // Fondo de la pestaña
      scaffoldBackgroundColor: Colors.grey[900],
      // Color de las tarjetas
      cardColor: Colors.grey[800],
      // Forzar que el texto principal sea blanco
      textTheme: baseTheme.textTheme.apply(
        bodyColor: Colors.white, // Para Text()
        displayColor: Colors.white, // Para cabeceras
      ),
      // Estilos para TextFields y Dropdowns
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: Colors.white70),
        hintStyle: TextStyle(color: Colors.white54),
        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orangeAccent)),
      ),
      // Forzar el color de texto de ListTile
      listTileTheme: ListTileThemeData(
        textColor: Colors.white,
        subtitleTextStyle: TextStyle(color: Colors.white70), // Subtítulos de listas
      ),
      // Color de los Dropdowns
      canvasColor: Colors.grey[850], // Fondo del menú dropdown
    );
  }
  // +++ FIN CAMBIOS MURGO +++

  // --- BUILDERS DE PESTAÑAS (RODOLFO) ---
  // +++ CAMBIOS RODOLFO +++
  Widget _buildProfesoresCRUD() {
    // +++ CAMBIOS MURGO +++
    return Container(
      color: colorsw ? Colors.grey[900] : Colors.orange.shade50,
      padding: EdgeInsets.all(16.0),
      // Wrapper de Theme para contraste de texto
      child: Theme(
        data: colorsw ? _getAppDarkTheme() : Theme.of(context).copyWith(
          brightness: Brightness.light,
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: Colors.brown[700]),
            hintStyle: TextStyle(color: Colors.black54),
          ),
        ),
        child: SingleChildScrollView(
          // +++ FIN CAMBIOS MURGO +++
          child: Column(
            children: [
              // +++ CAMBIOS MURGO (Contraste) +++
              Text("Gestión de Profesores",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorsw ? Colors.white : Colors.brown)),
              // +++ FIN CAMBIOS MURGO +++
              _buildFormularioProfesor(actualizando: false),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent),
                onPressed: _agregarProfesor,
                child: Text("Guardar Profesor"),
              ),
              Divider(height: 30),
              // +++ CAMBIOS MURGO (Contraste) +++
              Text("Profesores Registrados",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorsw ? Colors.white : Colors.black87)),
              // +++ FIN CAMBIOS MURGO +++
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _profesores.length,
                itemBuilder: (context, index) {
                  final profesor = _profesores[index];
                  return Card(
                    color: colorsw ? Colors.grey[800] : Colors.orange.shade100,
                    child: ListTile(
                      title: Text(profesor.nombre),
                      subtitle: Text(
                          "N°: ${profesor.nprofesor} | Carrera: ${profesor.carrera}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                _mostrarDialogoActualizarProfesor(profesor),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _eliminarProfesor(profesor.nprofesor),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // +++ CAMBIOS RODOLFO +++
  Widget _buildMateriasCRUD() {
    // +++ CAMBIOS MURGO +++
    return Container(
      color: colorsw ? Colors.grey[900] : Colors.orange.shade50,
      padding: EdgeInsets.all(16.0),
      // Wrapper de Theme para contraste de texto
      child: Theme(
        data: colorsw ? _getAppDarkTheme() : Theme.of(context).copyWith(
          brightness: Brightness.light,
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: Colors.brown[700]),
            hintStyle: TextStyle(color: Colors.black54),
          ),
        ),
        child: SingleChildScrollView(
          // +++ FIN CAMBIOS MURGO +++
          child: Column(
            children: [
              // +++ CAMBIOS MURGO (Contraste) +++
              Text("Gestión de Materias",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorsw ? Colors.white : Colors.brown)),
              // +++ FIN CAMBIOS MURGO +++
              _buildFormularioMateria(actualizando: false),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent),
                onPressed: _agregarMateria,
                child: Text("Guardar Materia"),
              ),
              Divider(height: 30),
              // +++ CAMBIOS MURGO (Contraste) +++
              Text("Materias Registradas",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorsw ? Colors.white : Colors.black87)),
              // +++ FIN CAMBIOS MURGO +++
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _materias.length,
                itemBuilder: (context, index) {
                  final materia = _materias[index];
                  return Card(
                    color: colorsw ? Colors.grey[800] : Colors.orange.shade100,
                    child: ListTile(
                      title: Text(materia.descripcion),
                      subtitle: Text("NMAT: ${materia.nmat}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                _mostrarDialogoActualizarMateria(materia),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _eliminarMateria(materia.nmat),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // +++ CAMBIOS RODOLFO +++
  Widget _buildHorariosCRUD() {
    // +++ CAMBIOS MURGO +++
    return Container(
      color: colorsw ? Colors.grey[900] : Colors.orange.shade50,
      padding: EdgeInsets.all(16.0),
      // Wrapper de Theme para contraste de texto
      child: Theme(
        data: colorsw ? _getAppDarkTheme() : Theme.of(context).copyWith(
          brightness: Brightness.light,
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: Colors.brown[700]),
            hintStyle: TextStyle(color: Colors.black54),
          ),
          listTileTheme: ListTileThemeData(
            textColor: Colors.black,
            iconColor: Colors.brown.shade700,
          ),
        ),
        child: SingleChildScrollView(
          // +++ FIN CAMBIOS MURGO +++
          child: Column(
            children: [
              // +++ CAMBIOS MURGO (Contraste) +++
              Text("Gestión de Horarios",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorsw ? Colors.white : Colors.brown)),
              // +++ FIN CAMBIOS MURGO +++
              _buildFormularioHorario(actualizando: false),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent),
                onPressed: _agregarHorario,
                child: Text("Guardar Horario"),
              ),
              Divider(height: 30),
              // +++ CAMBIOS MURGO (Contraste) +++
              Text("Horarios Registrados",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorsw ? Colors.white : Colors.black87)),
              // +++ FIN CAMBIOS MURGO +++
              SizedBox(height: 10),
              _buildHorarioListaWidget(),
            ],
          ),
        ),
      ),
    );
  }

  // +++ CAMBIOS RODOLFO +++
  Widget _buildHorarioListaWidget() {
    final List<Horario> horariosOrdenados = List.from(_horarios);
    horariosOrdenados.sort((a, b) {
      int diaCompare =
      _getDiaSemanaValor(a.dia).compareTo(_getDiaSemanaValor(b.dia));
      if (diaCompare != 0) {
        return diaCompare;
      }
      return _getHoraInicioValor(a.hora).compareTo(_getHoraInicioValor(b.hora));
    });

    if (horariosOrdenados.isEmpty) {
      return Center(child: Text("No hay horarios registrados."));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: horariosOrdenados.length,
      itemBuilder: (context, index) {
        final horario = horariosOrdenados[index];
        final profNombre = _profesores
            .firstWhere((p) => p.nprofesor == horario.nprofesor,
            orElse: () => Profesor(nprofesor: '', nombre: 'N/A', carrera: ''))
            .nombre;
        final matDesc = _materias
            .firstWhere((m) => m.nmat == horario.nmat,
            orElse: () => Materia(nmat: '', descripcion: 'N/A'))
            .descripcion;

        return Card(
          color: colorsw ? Colors.grey[800] : Colors.orange.shade100,
          child: ListTile(
            title: Text("$matDesc (${horario.hora})"),
            subtitle: Text(
                "$profNombre | ${horario.dia} | ${horario.edificio} - ${horario.salon}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _mostrarDialogoActualizarHorario(horario),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _eliminarHorario(horario.nhorario!),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // +++ CAMBIOS RODOLFO +++
  Widget _buildAsistenciasCRUD() {
    final horariosDelProfesor = _horarios
        .where((h) => h.nprofesor == _selectedProfesorAsistencia)
        .toList();

    final String diaActual = _getDiaActualString();
    final String fechaDeHoy = _getFechaActualString();

    final List<Asistencia> asistenciasOrdenadas = List.from(_asistencias);
    asistenciasOrdenadas.sort((a, b) => b.fecha.compareTo(a.fecha));

    // +++ CAMBIOS MURGO +++
    return Container(
      color: colorsw ? Colors.grey[900] : Colors.orange.shade50,
      padding: EdgeInsets.all(16.0),
      // Wrapper de Theme para contraste de texto
      child: Theme(
        data: colorsw ? _getAppDarkTheme() : Theme.of(context).copyWith(
          brightness: Brightness.light,
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: Colors.brown[700]),
            hintStyle: TextStyle(color: Colors.black54),
          ),
        ),
        child: SingleChildScrollView(
          // +++ FIN CAMBIOS MURGO +++
          child: Column(
            children: [
              // +++ CAMBIOS MURGO (Contraste) +++
              Text("Firmar Asistencias",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorsw ? Colors.white : Colors.brown)),
              // +++ FIN CAMBIOS MURGO +++
              DropdownButtonFormField<String>(
                initialValue: _selectedProfesorAsistencia,
                hint: Text("Seleccione un Profesor para firmar"),
                isExpanded: true,
                // +++ CAMBIOS MURGO (Contraste) +++
                style: TextStyle(color: colorsw ? Colors.white : Colors.black),
                // +++ FIN CAMBIOS MURGO +++
                items: _profesores.map((profesor) {
                  return DropdownMenuItem(
                    value: profesor.nprofesor,
                    child:
                    Text(profesor.nombre, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProfesorAsistencia = value;
                    _asistenciasMarcadas.clear();
                  });
                },
                decoration: InputDecoration(labelText: "Profesor"),
              ),
              SizedBox(height: 10),
              if (_selectedProfesorAsistencia != null)
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: horariosDelProfesor.length,
                  itemBuilder: (context, index) {
                    final horario = horariosDelProfesor[index];
                    final materiaDesc = _materias
                        .firstWhere((m) => m.nmat == horario.nmat,
                        orElse: () =>
                            Materia(nmat: '', descripcion: 'N/A'))
                        .descripcion;

                    final bool esDiaCorrecto = (horario.dia == diaActual);

                    final asistenciaHoy = _asistencias.lastWhere(
                            (a) =>
                        a.nhorario == horario.nhorario &&
                            a.fecha.startsWith(fechaDeHoy),
                        orElse: () => Asistencia(
                            idasistencia: -1,
                            nhorario: -1,
                            fecha: '',
                            asistencia: false));

                    final bool yaAsistioHoy = asistenciaHoy.idasistencia != -1;

                    bool valorSwitch;
                    bool habilitadoSwitch;

                    if (yaAsistioHoy) {
                      valorSwitch = asistenciaHoy.asistencia;
                      habilitadoSwitch = false;
                    } else if (esDiaCorrecto) {
                      valorSwitch =
                          _asistenciasMarcadas[horario.nhorario!] ?? false;
                      habilitadoSwitch = true;
                    } else {
                      valorSwitch = false;
                      habilitadoSwitch = false;
                    }

                    return SwitchListTile(
                      title: Text(materiaDesc),
                      subtitle: Text(
                          "${horario.dia} ${horario.hora} | ${horario.edificio} - ${horario.salon}"),
                      value: valorSwitch,
                      onChanged: habilitadoSwitch
                          ? (val) {
                        setState(() {
                          _asistenciasMarcadas[horario.nhorario!] = val;
                        });
                      }
                          : null,
                      activeColor: habilitadoSwitch
                          ? Colors.deepOrangeAccent
                          : Colors.grey,
                      inactiveThumbColor:
                      habilitadoSwitch ? null : Colors.grey.shade400,
                      inactiveTrackColor:
                      habilitadoSwitch ? null : Colors.grey.shade300,
                    );
                  },
                ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent),
                onPressed: _selectedProfesorAsistencia == null
                    ? null
                    : _guardarAsistenciasMarcadas,
                child: Text("Guardar Firmas"),
              ),
              Divider(height: 30),
              // +++ CAMBIOS MURGO (Contraste) +++
              Text("Asistencias Registradas",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorsw ? Colors.white : Colors.black87)),
              // +++ FIN CAMBIOS MURGO +++
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: asistenciasOrdenadas.length,
                itemBuilder: (context, index) {
                  final asistencia = asistenciasOrdenadas[index];

                  final horarioAsistencia = _horarios.firstWhere(
                          (h) => h.nhorario == asistencia.nhorario,
                      orElse: () => Horario(
                          nprofesor: '',
                          nmat: '',
                          dia: '',
                          hora: '',
                          edificio: '',
                          salon: '',
                          nhorario: -1));

                  final materiaDesc = _materias
                      .firstWhere((m) => m.nmat == horarioAsistencia.nmat,
                      orElse: () => Materia(
                          nmat: '', descripcion: 'Horario borrado'))
                      .descripcion;

                  return Card(
                    color: colorsw ? Colors.grey[800] : Colors.orange.shade100,
                    child: ListTile(
                      leading: Icon(
                        asistencia.asistencia
                            ? Icons.check_circle
                            : Icons.cancel,
                        color:
                        asistencia.asistencia ? Colors.green : Colors.red,
                      ),
                      title: Text("Materia: $materiaDesc"),
                      subtitle: Text(
                          "Fecha: ${asistencia.fecha} (ID Horario: ${asistencia.nhorario})"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                _mostrarDialogoActualizarAsistencia(
                                    asistencia),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _eliminarAsistencia(asistencia.idasistencia!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- BUILDERS DE CONSULTAS ---

  // +++ CAMBIOS MURGO +++
  Widget _buildConsultasView() {
    return Container(
      color: colorsw ? Colors.grey[900] : Colors.orange.shade50,
      // Wrapper de Theme para contraste en toda la pestaña
      child: Theme(
        data: colorsw ? _getAppDarkTheme() : Theme.of(context).copyWith(
          brightness: Brightness.light,
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: Colors.brown[700]),
            hintStyle: TextStyle(color: Colors.black54),
            border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orangeAccent)),
          ),
          listTileTheme: ListTileThemeData(
              textColor: Colors.black,
              subtitleTextStyle: TextStyle(color: Colors.black87),
              iconColor: Colors.brown.shade700
          ),
          cardColor: Colors.orange.shade100,
        ),
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: [
                Tab(text: "Horarios"),       // Rodolfo
                Tab(text: "Asistencias"),    // Rodolfo
                Tab(text: "Por Edificio"),   // Rodolfo
                Tab(text: "Por Profesor"),   // Murgo
              ],
              labelColor: Colors.deepOrange,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.deepOrangeAccent,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildListaConsulta(_horariosDetallados, esHorario: true),  // Rodolfo
                  _buildListaConsulta(_asistenciasDetalladas, esHorario: false), // Rodolfo
                  _buildConsultaPorEdificio(), // Rodolfo
                  _buildConsultaPorProfesor(), // Murgo
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  // +++ FIN CAMBIOS MURGO +++


  // +++ CAMBIOS RODOLFO +++
  Widget _buildConsultaPorEdificio() {
    final List<Map<String, dynamic>> horariosFiltrados;
    if (_selectedEdificioConsulta == null) {
      horariosFiltrados = [];
    } else {
      horariosFiltrados = _horariosDetallados
          .where((h) => h['EDIFICIO'] == _selectedEdificioConsulta)
          .toList();

      horariosFiltrados.sort((a, b) {
        int diaCompare =
        _getDiaSemanaValor(a['DIA']).compareTo(_getDiaSemanaValor(b['DIA']));
        if (diaCompare != 0) return diaCompare;
        int salonCompare = (a['SALON'] as String).compareTo(b['SALON'] as String);
        if (salonCompare != 0) return salonCompare;
        return _getHoraInicioValor(a['HORA'])
            .compareTo(_getHoraInicioValor(b['HORA']));
      });
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // +++ CAMBIOS MURGO (Contraste) +++
          Text(
            "Consulta de Salones por Edificio",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorsw ? Colors.white : Colors.brown),
          ),
          // +++ FIN CAMBIOS MURGO +++
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedEdificioConsulta,
            hint: Text("Seleccione un Edificio"),
            // +++ CAMBIOS MURGO (Contraste) +++
            style: TextStyle(color: colorsw ? Colors.white : Colors.black),
            // +++ FIN CAMBIOS MURGO +++
            items: _edificiosConsulta.map((edificio) {
              return DropdownMenuItem(
                value: edificio,
                child: Text(edificio),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedEdificioConsulta = value;
              });
            },
            decoration: InputDecoration(
              labelText: "Edificio",
              border: OutlineInputBorder(),
            ),
          ),
          Divider(height: 30),
          if (_selectedEdificioConsulta == null)
            Center(child: Text("Seleccione un edificio para ver horarios."))
          else if (horariosFiltrados.isEmpty)
            Center(child: Text("No hay clases registradas en este edificio."))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: horariosFiltrados.length,
              itemBuilder: (context, index) {
                final item = horariosFiltrados[index];
                return Card(
                  child: ListTile(
                    // +++ CAMBIOS MURGO (Contraste) +++
                    leading: Icon(Icons.meeting_room,
                        color: colorsw
                            ? Colors.white70
                            : Colors.brown.shade700),
                    // +++ FIN CAMBIOS MURGO +++
                    title: Text(
                      "Salón: ${item['SALON']} - ${item['DIA']}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                        "Maestro: ${item['PROFESOR']}\n${item['MATERIA']} (${item['HORA']})"),
                    isThreeLine: true,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // +++ CAMBIOS MURGO +++
  // (Pestaña 4 - Por Profesor)
  Widget _buildConsultaPorProfesor() {
    final List<Map<String, dynamic>> horariosFiltrados;
    String? selectedProfName;

    if (_selectedProfesorConsulta != null) {
      final prof = _profesores.firstWhere(
              (p) => p.nprofesor == _selectedProfesorConsulta,
          orElse: () => Profesor(nprofesor: '', nombre: '', carrera: ''));
      selectedProfName = prof.nombre;
    }

    if (selectedProfName == null) {
      horariosFiltrados = [];
    } else {
      horariosFiltrados = _horariosDetallados
          .where((h) => h['PROFESOR'] == selectedProfName)
          .toList();

      horariosFiltrados.sort((a, b) {
        int diaCompare =
        _getDiaSemanaValor(a['DIA']).compareTo(_getDiaSemanaValor(b['DIA']));
        if (diaCompare != 0) return diaCompare;
        return _getHoraInicioValor(a['HORA'])
            .compareTo(_getHoraInicioValor(b['HORA']));
      });
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // +++ CAMBIOS MURGO (Contraste) +++
          Text(
            "Consulta de Horario por Profesor",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorsw ? Colors.white : Colors.brown),
          ),
          // +++ FIN CAMBIOS MURGO +++
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedProfesorConsulta,
            hint: Text("Seleccione un Profesor"),
            isExpanded: true,
            // +++ CAMBIOS MURGO (Contraste) +++
            style: TextStyle(color: colorsw ? Colors.white : Colors.black),
            // +++ FIN CAMBIOS MURGO +++
            items: _profesores.map((profesor) {
              return DropdownMenuItem(
                value: profesor.nprofesor, // Guardamos el ID
                child: Text(profesor.nombre, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedProfesorConsulta = value;
              });
            },
            decoration: InputDecoration(
              labelText: "Profesor",
              border: OutlineInputBorder(),
            ),
          ),
          Divider(height: 30),
          if (_selectedProfesorConsulta == null)
            Center(child: Text("Seleccione un profesor para ver su horario."))
          else if (horariosFiltrados.isEmpty)
            Center(child: Text("No hay clases registradas para este profesor."))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: horariosFiltrados.length,
              itemBuilder: (context, index) {
                final item = horariosFiltrados[index];
                return Card(
                  child: ListTile(
                    // +++ CAMBIOS MURGO (Contraste) +++
                    leading: Icon(Icons.school,
                        color: colorsw
                            ? Colors.white70
                            : Colors.brown.shade700),
                    // +++ FIN CAMBIOS MURGO +++
                    title: Text(
                      "${item['DIA']} - ${item['HORA']}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                        "${item['MATERIA']}\n${item['EDIFICIO']} - ${item['SALON']}"),
                    isThreeLine: true,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
  // +++ FIN CAMBIOS MURGO +++

  // +++ CAMBIOS RODOLFO +++
  Widget _buildListaConsulta(List<Map<String, dynamic>> data,
      {required bool esHorario}) {
    if (data.isEmpty) {
      return Center(child: Text("No hay datos para mostrar."));
    }
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        if (esHorario) {
          return Card(
            child: ListTile(
              leading: Icon(Icons.schedule, color: Colors.blue),
              title: Text(item['MATERIA'] ?? 'N/A'),
              subtitle: Text(
                  "${item['PROFESOR'] ?? 'N/A'} | ${item['DIA']} ${item['HORA']} | ${item['EDIFICIO']} - ${item['SALON']}"),
            ),
          );
        } else {
          bool asistio = item['ASISTENCIA'] == 1;
          return Card(
            child: ListTile(
              leading: Icon(
                asistio ? Icons.check_circle : Icons.cancel,
                color: asistio ? Colors.green : Colors.red,
              ),
              title: Text("${item['MATERIA'] ?? 'N/A'} (${item['FECHA']})"),
              subtitle: Text(
                  "${item['PROFESOR'] ?? 'N/A'} | ${item['DIA']} ${item['HORA']}"),
            ),
          );
        }
      },
    );
  }

  // --- FUNCIONES AUXILIARES (RODOLFO) ---

  // +++ CAMBIOS RODOLFO +++
  double _timeToDouble(int hour, int minute) => hour + minute / 60.0;

  // +++ CAMBIOS RODOLFO +++
  int _getDiaSemanaValor(String dia) {
    int index = _diasSemana.indexOf(dia);
    return index == -1 ? 99 : index;
  }

  // +++ CAMBIOS RODOLFO +++
  double _getHoraInicioValor(String horaRango) {
    final matches = _horaRegExp.firstMatch(horaRango);
    if (matches == null) return 99.0;
    final double horarioInicio =
    _timeToDouble(int.parse(matches.group(1)!), int.parse(matches.group(2)!));
    return horarioInicio;
  }

  // +++ CAMBIOS RODOLFO +++
  String _getDiaActualString() {
    final int hoy = DateTime.now().weekday;
    switch (hoy) {
      case DateTime.monday:
        return 'Lunes';
      case DateTime.tuesday:
        return 'Martes';
      case DateTime.wednesday:
        return 'Miércoles';
      case DateTime.thursday:
        return 'Jueves';
      case DateTime.friday:
        return 'Viernes';
      case DateTime.saturday:
        return 'Sábado';
      default:
        return '';
    }
  }

  // +++ CAMBIOS RODOLFO +++
  String _getFechaActualString() {
    return DateTime.now().toIso8601String().substring(0, 10);
  }

  // +++ CAMBIOS RODOLFO +++
  Widget _itemDrawer(int indice, IconData icono, String texto) {
    return ListTile(
      onTap: () {
        setState(() {
          _index = indice;
        });
        _limpiarControladores();

        if (indice == 4) {
          _cargarDatos();
        }
        if (indice == 2 || indice == 3) {
          _cargarProfesores();
          _cargarMaterias();
          _cargarHorarios();
        }
        if (indice == 3) {
          _cargarAsistencias();
        }
        Navigator.pop(context);
      },
      title: Row(
        children: [
          Expanded(child: Icon(icono, size: 20)),
          Expanded(
            flex: 2,
            child: Text(
              texto,
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  // --- BUILD (RODOLFO) ---
  // +++ CAMBIOS RODOLFO +++
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gestión Escolar"),
        // +++ CAMBIOS MURGO +++
        backgroundColor: colorsw ? Colors.grey[900] : Colors.deepOrange,
        // +++ FIN CAMBIOS MURGO +++
        centerTitle: true,
      ),
      body: contenido(),
      drawer: Drawer(
        // +++ CAMBIOS MURGO (Contraste Drawer) +++
        // El Drawer en sí no tiene color, su hijo es el que tiene el color.
        child: Theme(
          data: Theme.of(context).copyWith(
            // El brightness le dice a los Text/Icons que sean blancos
            brightness: colorsw ? Brightness.dark : Brightness.light,
          ),
          child: Container( // Se añade un Container para forzar el color de fondo
            color: colorsw ? Colors.grey[850] : Colors.white,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: 120,
                  child: Container(
                    color: Colors.deepOrange,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 16.0, top: 40.0),
                    child: Text(
                      'Menú',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                _itemDrawer(0, Icons.person, "PROFESORES"),
                _itemDrawer(1, Icons.book, "MATERIAS"),
                _itemDrawer(2, Icons.schedule, "HORARIOS"),
                _itemDrawer(3, Icons.check_box, "ASISTENCIAS"),
                _itemDrawer(4, Icons.query_stats, "CONSULTAS"),
                Divider(color: colorsw ? Colors.white24 : Colors.black26), // Color de divisor explícito
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        child: Text(
                          "Modo obscuro",
                          style: TextStyle(
                            fontSize: 18,
                            // El color lo toma del Theme.brightness
                          ),
                        ),
                      ),
                      Switch(
                        value: colorsw,
                        inactiveThumbColor: Colors.grey,
                        inactiveTrackColor: Colors.grey.shade300,
                        onChanged: (bool value) {
                          setState(() {
                            colorsw = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // +++ FIN CAMBIOS MURGO +++
      ),
    );
  }
}
