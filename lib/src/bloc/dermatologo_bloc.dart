import 'dart:io';

import 'package:rxdart/subjects.dart';
import 'package:suncare/src/bloc/validators.dart';
import 'package:suncare/src/models/dermatologo_model.dart';
import 'package:suncare/src/models/mensaje_model.dart';
import 'package:suncare/src/models/paciente_model.dart';
import 'package:suncare/src/models/solicitud_model.dart';
import 'package:suncare/src/providers/dermatologo_provider.dart';
import 'package:suncare/src/models/solicitud_validacion_model.dart';
import 'package:rxdart/rxdart.dart';

class DermatologoBloc with Validators {
  final _dermatologosController = BehaviorSubject<List<DermatologoModel>>();
  final _cargandoController = BehaviorSubject<bool>();
  final _misPacientesController = BehaviorSubject<List<PacienteModel>>();
  final _misSolicitudesController = BehaviorSubject<List<SolicitudModel>>();
  final _dermatologoController = BehaviorSubject<DermatologoModel>();
  final _mensajesPorUsuarioController = BehaviorSubject<List<MensajeModel>>();
// listarMensajePorUsuario

  final _dermatologoProvider = new DermatologoProvider();

  final _emailController = BehaviorSubject<String>();
  final _nameController = BehaviorSubject<String>();
  final _lastNameController = BehaviorSubject<String>();

  // final _idMedicoVincularController
  //Escuchar los datos del Stream
  Stream<String> get emailStream => _emailController.transform(validarEmail);
  Stream<String> get nameStream => _nameController.transform(validarName);
  Stream<String> get lastNameStream =>
      _lastNameController.transform(validarLastname);
  //
  Stream<List<MensajeModel>> get mensajePorUsuarioStream =>
      _mensajesPorUsuarioController.stream;
  Stream<List<DermatologoModel>> get pacienteStream =>
      _dermatologosController.stream;
  Stream<bool> get cargandoStream => _cargandoController.stream;
  Stream<List<PacienteModel>> get misPacientesStream =>
      _misPacientesController.stream;
  Stream<List<SolicitudModel>> get misSolicitudesStream =>
      _misSolicitudesController.stream;
  Stream<DermatologoModel> get dermatologoBuscadoStream =>
      _dermatologoController.stream;

  Stream<bool> get formValidStream => CombineLatestStream.combine3(
      nameStream, lastNameStream, emailStream, (n, l, e) => true);
  //Insertar Data
  Future crearDermatologo(DermatologoModel dermatologo, SolicitudValidacionModel solicitudValidacion) async {
    _cargandoController.sink.add(true);
    final respuestaCrearDermatologo =
        await _dermatologoProvider.crearDermatologo(dermatologo, solicitudValidacion);

    (respuestaCrearDermatologo)
        ? print('crearDermatologo: TRUE')
        : print('crearDermatologo: FALSE');
    _cargandoController.sink.add(false);
  }

  void buscarDermatologo(String id) async {
    _cargandoController.sink.add(true);
    final dermatologoBuscado = await _dermatologoProvider.buscarDermatologo(id);
    _dermatologoController.sink.add(dermatologoBuscado);
    _cargandoController.sink.add(false);
  }

  void editarDermatologo(DermatologoModel dermatologo) async {
    _cargandoController.sink.add(true);
    await _dermatologoProvider.editarDermatologo(dermatologo);
    _cargandoController.sink.add(false);
  }

  void listarSolicitudes() async {
    final solicitudes = await _dermatologoProvider.listarSolicitudes();
    _misSolicitudesController.sink.add(solicitudes);
  }

  Future<bool> aceptarSolicitud(SolicitudModel solicitud) async {
    final respuesta = await _dermatologoProvider.aceptarSolicitud(solicitud);
    print(respuesta);
    return respuesta;
  }

  void listarMensajePorUsuario(String idUsuario) async {
    final mensajes =
        await _dermatologoProvider.listarMensajePorUsuario(idUsuario);
    _mensajesPorUsuarioController.sink.add(mensajes);
  }

  Future<bool> cancelarSolicitud(SolicitudModel solicitud) async {
    final respuesta = await _dermatologoProvider.cancelarSolicitud(solicitud);
    print(respuesta);
    return respuesta;
  }

  void listarPacientes() async {
    final pacientes = await _dermatologoProvider.listarPacientes();
    _misPacientesController.sink.add(pacientes);
  }

  Future<List<PacienteModel>> buscarPacientesPorNombre(String nombre) async {
    final pacientes =
        await _dermatologoProvider.buscarPacientesPorNombre(nombre);
    return pacientes;
  }

  Future<String> subirFoto(File imagen) async {
    final fotoUrl = await _dermatologoProvider.subirFoto(imagen);
    print('name foto: $fotoUrl');
    return fotoUrl;
  }

  Future<bool> crearMensaje(String idUsuario, String mensaje) async {
    final respuesta =
        await _dermatologoProvider.crearMensaje(idUsuario, mensaje);
    print('crearMensaje: $respuesta');
    return respuesta;
  }
  Future<Map<String, dynamic>> postNotificacion(String idUsuario) async {
    final respuesta =
        await _dermatologoProvider.postNotificacion(idUsuario);
    print('respeusta del fm bloc-> $respuesta');
    return respuesta;
  }

  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changeName => _nameController.sink.add;
  Function(String) get changeLastName => _lastNameController.sink.add;

  String get email => _emailController.value;
  String get name => _nameController.value;
  String get lastName => _lastNameController.value;
  dispose() {
    _dermatologosController?.close();
    _cargandoController?.close();
    _misPacientesController?.close();
    _misSolicitudesController?.close();
    _dermatologoController?.close();
    _mensajesPorUsuarioController?.close();

    _emailController?.close();
    _nameController?.close();
    _lastNameController?.close();
  }
}
