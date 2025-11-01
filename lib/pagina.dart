import 'package:flutter/material.dart';
import 'asistencia.dart';
import 'horario.dart';
import 'profesor.dart';
import 'materia.dart';
import 'base.dart';

class APP03 extends StatefulWidget {
  const APP03({super.key});

  @override
  State<APP03> createState() => _APP03State();
}

class _APP03State extends State<APP03> with SingleTickerProviderStateMixin {
  int _index = 0;
  bool colorsw = false;
  late TabController _tabController;

  List<Profesor> _profesores = [];
  List<Materia> _materias = [];
  List<Horario> _horarios = [];
  List<Asistencia> _asistencias = [];
  List<Map<String, dynamic>> _horariosDetallados = [];
  List<Map<String, dynamic>> _asistenciasDetalladas = [];

  final nprofesorCtrl = TextEditingController();
  final nombreCtrl = TextEditingController();
  final carreraCtrl = TextEditingController();

  final nmatCtrl = TextEditingController();
  final descripcionCtrl = TextEditingController();

  final horaCtrl = TextEditingController();

  String? _selectedNProfesor;
  String? _selectedNMat;
  String? _selectedDia;
  String? _selectedEdificio;
  String? _selectedSalon;
  List<String> _salonesDisponibles = [];

  TimeOfDay? _selectedHoraInicio;
  TimeOfDay? _selectedHoraFin;

  final List<String> _diasSemana = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado'
  ];
  final List<String> _salonesUD = List.generate(11, (i) => 'UD${i + 1}');
  final List<String> _salonesLABC = [
    'LABCSA',
    'LABCSB',
    'LABCSC',
    'CSC1',
    'CSC2',
    'TDM',
    'TBD'
  ];
  final List<String> _salonesCB = List.generate(10, (i) => 'CB${i + 1}');

  final nhorarioAsistenciaCtrl = TextEditingController();
  final fechaCtrl = TextEditingController();
  bool _asistenciaValor = false;

  String? _selectedProfesorAsistencia;
  Map<int, bool> _asistenciasMarcadas = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarDatos();
  }

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

  void _cargarDatos() async {
    _cargarProfesores();
    _cargarMaterias();
    await _cargarHorarios();
    _cargarAsistencias();
    _cargarDatosConsulta();
  }

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
    });
  }

  void _cargarProfesores() async {
    final profesores = await DBAsistencia.mostrarProfesores();
    if (mounted) {
      setState(() {
        _profesores = profesores;
      });
    }
  }

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

  void _eliminarProfesor(String nprofesor) async {
    await DBAsistencia.eliminarProfesor(nprofesor);
    _cargarProfesores();
    _cargarDatosConsulta();
    _mostrarSnackBar("Profesor eliminado");
  }

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

  void _cargarMaterias() async {
    final materias = await DBAsistencia.mostrarMaterias();
    if (mounted) {
      setState(() {
        _materias = materias;
      });
    }
  }

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

  void _eliminarMateria(String nmat) async {
    await DBAsistencia.eliminarMateria(nmat);
    _cargarMaterias();
    _cargarDatosConsulta();
    _mostrarSnackBar("Materia eliminada");
  }

  void _mostrarDialogoActualizarMateria(Materia materia) {
    nmatCtrl.text = materia.nmat;
    descripcionCtrl.text = materia.descripcion;
    _mostrarDialogo(
      "Actualizar Materia",
      _buildFormularioMateria(actualizando: true),
      onGuardar: () => _actualizarMateria(),
    );
  }

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

    final RegExp horaRegExp = RegExp(
        r'^([01]?\d|2[0-3]):([0-5]\d) a ([01]?\d|2[0-3]):([0-5]\d)$');

    final matches = horaRegExp.firstMatch(horaRango);
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
        final matchesExistente = horaRegExp.firstMatch(hExistente.hora);
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

  void _eliminarHorario(int nhorario) async {
    await DBAsistencia.eliminarHorario(nhorario);
    _cargarHorarios();
    _cargarDatosConsulta();
    _mostrarSnackBar("Horario eliminado");
  }

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
    final RegExp horaRegExp = RegExp(
        r'^([01]?\d|2[0-3]):([0-5]\d) a ([01]?\d|2[0-3]):([0-5]\d)$');
    final matches = horaRegExp.firstMatch(horario.hora);
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

  void _cargarAsistencias() async {
    final asistencias = await DBAsistencia.mostrarAsistencias();
    if (mounted) {
      setState(() {
        _asistencias = asistencias;
      });
    }
  }

  void _guardarAsistenciasMarcadas() async {
    if (_asistenciasMarcadas.isEmpty && _selectedProfesorAsistencia != null) {
      final horariosDelProfesor = _horarios
          .where((h) => h.nprofesor == _selectedProfesorAsistencia)
          .toList();
      for (var h in horariosDelProfesor) {
        _asistenciasMarcadas[h.nhorario!] =
            _asistenciasMarcadas[h.nhorario!] ?? false;
      }
    }

    if (_asistenciasMarcadas.isEmpty) {
      _mostrarSnackBar("Seleccione un profesor y marque sus asistencias.");
      return;
    }

    final String fechaActual = DateTime.now()
        .toIso8601String()
        .replaceAll('T', ' ')
        .substring(0, 23);

    int contador = 0;
    try {
      for (var entry in _asistenciasMarcadas.entries) {
        final asistencia = Asistencia(
          nhorario: entry.key,
          fecha: fechaActual,
          asistencia: entry.value,
        );
        await DBAsistencia.insertarAsistencia(asistencia);
        contador++;
      }

      _limpiarControladores();
      _cargarAsistencias();
      _cargarDatosConsulta();
      _mostrarSnackBar("$contador asistencias guardadas correctamente.");
    } catch (e) {
      _mostrarSnackBar("Error al guardar asistencias: $e");
    }
  }

  void _eliminarAsistencia(int idasistencia) async {
    await DBAsistencia.eliminarAsistencia(idasistencia);
    _cargarAsistencias();
    _cargarDatosConsulta();
    _mostrarSnackBar("Asistencia eliminada");
  }

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

  void _mostrarSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _mostrarDialogo(String title, Widget content,
      {required VoidCallback onGuardar}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.orange.shade50,
          title: Text(title, style: TextStyle(color: Colors.brown)),
          content: SingleChildScrollView(child: content),
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
      },
    );
  }

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

  Widget _buildFormularioHorario({bool actualizando = false}) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          void _updateState(VoidCallback fn) {
            if (actualizando) {
              setDialogState(fn);
            } else {
              setState(fn);
            }
          }

          void _onEdificioChanged(String? newValue) {
            _updateState(() {
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
                initialValue: _selectedNProfesor,
                hint: Text("Seleccione un Profesor"),
                isExpanded: true,
                items: _profesores.map((profesor) {
                  return DropdownMenuItem(
                    value: profesor.nprofesor,
                    child: Text(profesor.nombre, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (value) {
                  _updateState(() {
                    _selectedNProfesor = value;
                  });
                },
                decoration: InputDecoration(labelText: "Profesor"),
                validator: (value) => value == null ? 'Campo requerido' : null,
              ),
              DropdownButtonFormField<String>(
                initialValue: _selectedNMat,
                hint: Text("Seleccione una Materia"),
                isExpanded: true,
                items: _materias.map((materia) {
                  return DropdownMenuItem(
                    value: materia.nmat,
                    child: Text(materia.descripcion, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (value) {
                  _updateState(() {
                    _selectedNMat = value;
                  });
                },
                decoration: InputDecoration(labelText: "Materia"),
                validator: (value) => value == null ? 'Campo requerido' : null,
              ),
              DropdownButtonFormField<String>(
                initialValue: _selectedDia,
                hint: Text("Seleccione un Día"),
                items: _diasSemana.map((dia) {
                  return DropdownMenuItem(
                    value: dia,
                    child: Text(dia),
                  );
                }).toList(),
                onChanged: (value) {
                  _updateState(() {
                    _selectedDia = value;
                  });
                },
                decoration: InputDecoration(labelText: "Día de la semana"),
                validator: (value) => value == null ? 'Campo requerido' : null,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.access_time, color: Colors.brown.shade700),
                title: Text("Rango de Hora"),
                subtitle: Text(
                  _getHoraRangoTexto(),
                  style: TextStyle(
                      color: _selectedHoraInicio == null
                          ? Colors.grey.shade600
                          : Colors.black,
                      fontSize: 16),
                ),
                onTap: () {
                  _seleccionarRangoHora(context, _updateState);
                },
              ),
              Divider(color: Colors.grey.shade700, height: 1),
              DropdownButtonFormField<String>(
                initialValue: _selectedEdificio,
                hint: Text("Seleccione un Edificio"),
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
                initialValue: _selectedSalon,
                hint: Text(_selectedEdificio == null
                    ? "Seleccione Edificio"
                    : "Seleccione un Salón"),
                isExpanded: true,
                items: _salonesDisponibles.map((salon) {
                  return DropdownMenuItem(
                    value: salon,
                    child: Text(salon),
                  );
                }).toList(),
                onChanged: _salonesDisponibles.isEmpty
                    ? null
                    : (value) {
                  _updateState(() {
                    _selectedSalon = value;
                  });
                },
                decoration: InputDecoration(labelText: "Salón"),
                validator: (value) => value == null ? 'Campo requerido' : null,
              ),
            ],
          );
        });
  }

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

  Widget _buildProfesoresCRUD() {
    return Container(
      color: colorsw ? Colors.grey[800] : Colors.orange.shade50,
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text("Gestión de Profesores",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown)),
            _buildFormularioProfesor(actualizando: false),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent),
              onPressed: _agregarProfesor,
              child: Text("Guardar Profesor"),
            ),
            Divider(height: 30),
            Text("Profesores Registrados",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _profesores.length,
              itemBuilder: (context, index) {
                final profesor = _profesores[index];
                return Card(
                  color: colorsw ? Colors.grey[700] : Colors.orange.shade100,
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
    );
  }

  Widget _buildMateriasCRUD() {
    return Container(
      color: colorsw ? Colors.grey[800] : Colors.orange.shade50,
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text("Gestión de Materias",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown)),
            _buildFormularioMateria(actualizando: false),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent),
              onPressed: _agregarMateria,
              child: Text("Guardar Materia"),
            ),
            Divider(height: 30),
            Text("Materias Registradas",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _materias.length,
              itemBuilder: (context, index) {
                final materia = _materias[index];
                return Card(
                  color: colorsw ? Colors.grey[700] : Colors.orange.shade100,
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
    );
  }

  Widget _buildHorariosCRUD() {
    return Container(
      color: colorsw ? Colors.grey[800] : Colors.orange.shade50,
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text("Gestión de Horarios",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown)),
            _buildFormularioHorario(actualizando: false),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent),
              onPressed: _agregarHorario,
              child: Text("Guardar Horario"),
            ),
            Divider(height: 30),
            Text("Horarios Registrados",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _horarios.length,
              itemBuilder: (context, index) {
                final horario = _horarios[index];
                final profNombre = _profesores
                    .firstWhere((p) => p.nprofesor == horario.nprofesor,
                    orElse: () =>
                        Profesor(nprofesor: '', nombre: 'N/A', carrera: ''))
                    .nombre;
                final matDesc = _materias
                    .firstWhere((m) => m.nmat == horario.nmat,
                    orElse: () => Materia(nmat: '', descripcion: 'N/A'))
                    .descripcion;

                return Card(
                  color: colorsw ? Colors.grey[700] : Colors.orange.shade100,
                  child: ListTile(
                    title: Text("$matDesc (${horario.hora})"),
                    subtitle: Text(
                        "$profNombre | ${horario.dia} | ${horario.edificio} - ${horario.salon}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () =>
                              _mostrarDialogoActualizarHorario(horario),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAsistenciasCRUD() {
    final horariosDelProfesor = _horarios
        .where((h) => h.nprofesor == _selectedProfesorAsistencia)
        .toList();

    return Container(
      color: colorsw ? Colors.grey[800] : Colors.orange.shade50,
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text("Firmar Asistencias",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown)),
            DropdownButtonFormField<String>(
              initialValue: _selectedProfesorAsistencia,
              hint: Text("Seleccione un Profesor para firmar"),
              isExpanded: true,
              items: _profesores.map((profesor) {
                return DropdownMenuItem(
                  value: profesor.nprofesor,
                  child: Text(profesor.nombre, overflow: TextOverflow.ellipsis),
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
                      orElse: () => Materia(nmat: '', descripcion: 'N/A'))
                      .descripcion;

                  return SwitchListTile(
                    title: Text(materiaDesc),
                    subtitle: Text(
                        "${horario.dia} ${horario.hora} | ${horario.edificio} - ${horario.salon}"),
                    value: _asistenciasMarcadas[horario.nhorario!] ?? false,
                    onChanged: (val) {
                      setState(() {
                        _asistenciasMarcadas[horario.nhorario!] = val;
                      });
                    },
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
            Text("Asistencias Registradas",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _asistencias.length,
              itemBuilder: (context, index) {
                final asistencia = _asistencias[index];
                return Card(
                  color: colorsw ? Colors.grey[700] : Colors.orange.shade100,
                  child: ListTile(
                    leading: Icon(
                      asistencia.asistencia
                          ? Icons.check_circle
                          : Icons.cancel,
                      color:
                      asistencia.asistencia ? Colors.green : Colors.red,
                    ),
                    title: Text("Horario: ${asistencia.nhorario}"),
                    subtitle: Text("Fecha: ${asistencia.fecha}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () =>
                              _mostrarDialogoActualizarAsistencia(asistencia),
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
    );
  }

  Widget _buildConsultasView() {
    return Container(
      color: colorsw ? Colors.grey[800] : Colors.orange.shade50,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: "Horarios Detallados"),
              Tab(text: "Asistencias Detalladas"),
            ],
            labelColor: Colors.deepOrange,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.deepOrangeAccent,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildListaConsulta(_horariosDetallados, esHorario: true),
                _buildListaConsulta(_asistenciasDetalladas, esHorario: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
            color: colorsw ? Colors.grey[700] : Colors.orange.shade100,
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
            color: colorsw ? Colors.grey[700] : Colors.orange.shade100,
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

  Widget _itemDrawer(int indice, IconData icono, String texto) {
    return ListTile(
      onTap: () {
        setState(() {
          _index = indice;
        });
        _limpiarControladores();
        if (indice == 4) {
          _cargarDatosConsulta();
        }
        if (indice == 2 || indice == 3 || indice == 4) {
          _cargarProfesores();
          _cargarMaterias();
          _cargarHorarios();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gestión Escolar"),
        backgroundColor: !colorsw ? Colors.deepOrange : Colors.grey,
        centerTitle: true,
      ),
      body: contenido(),
      drawer: Drawer(
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
            Divider(),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  SizedBox(
                    child: Text(
                      "Modo obscuro",
                      style:
                      TextStyle(fontSize: 18, color: Colors.orangeAccent),
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
    );
  }
}