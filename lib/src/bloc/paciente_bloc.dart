import 'dart:io';

import 'package:rxdart/subjects.dart';
import 'package:suncare/src/bloc/validators.dart';
import 'package:suncare/src/models/mensaje_model.dart';
import 'package:suncare/src/models/paciente_model.dart';
import 'package:suncare/src/providers/paciente_provider.dart';
import 'package:rxdart/rxdart.dart';

class PacienteBloc with Validators {
  final _pacientesController = BehaviorSubject<List<PacienteModel>>();
  final _cargandoController = BehaviorSubject<bool>();
  final _pacienteController = BehaviorSubject<PacienteModel>();
  final _mensajesController = BehaviorSubject<List<MensajeModel>>();
  final _pacientesProvider = new PacienteProvider();

  final _emailController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();
  final _nameController = BehaviorSubject<String>();
  final _lastNameController = BehaviorSubject<String>();
  final _tipoPielController = BehaviorSubject<String>();
  final _imagenPerfilController = BehaviorSubject<File>();

  Stream<String> get emailStream => _emailController.transform(validarEmail);
  Stream<String> get passwordStream =>
      _passwordController.transform(validarPassword);
  Stream<String> get nameStream => _nameController.transform(validarName);
  Stream<String> get lastNameStream =>
      _lastNameController.transform(validarLastname);
  Stream<File> get imagenPerfilStream => _imagenPerfilController.stream;
  Stream<String> get tipoPielStream => _tipoPielController.stream;
  Stream<bool> get formValidStream => CombineLatestStream.combine4(
      emailStream, nameStream, lastNameStream,tipoPielStream, (e, n, l,t) => true);

  // Escuchar los datos del Stream
  Stream<List<PacienteModel>> get pacienteStream => _pacientesController.stream;
  Stream<List<MensajeModel>> get mensajesStream => _mensajesController.stream;
  Stream<bool> get cargandoStream => _cargandoController.stream;
  Stream<PacienteModel> get pacienteBuscadoStream => _pacienteController.stream;

  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;
  Function(String) get changeName => _nameController.sink.add;
  Function(String) get changeLastName => _lastNameController.sink.add;
  Function(String) get changeTipoPiel => _tipoPielController.sink.add;
  Function(File) get changeImagenPerfil => _imagenPerfilController.sink.add;
  //Insertar Data
  void crearPaciente(PacienteModel paciente) async {
    _cargandoController.sink.add(true);
    final respuestaCrearPaciente =
        await _pacientesProvider.crearPaciente(paciente);
    (respuestaCrearPaciente)
        ? print('crearPaciente: TRUE')
        : print('crearPaciente: FALSE');
    _cargandoController.sink.add(false);
  }

  void buscarMensajes() async {
    final mensajes = await _pacientesProvider.buscarMensajes();
    _mensajesController.sink.add(mensajes);
  }

  void buscarPaciente(String id) async {
    _cargandoController.sink.add(true);
    final pacienteBuscado = await _pacientesProvider.buscarPaciente(id);
    _pacienteController.sink.add(pacienteBuscado);
    _cargandoController.sink.add(false);
  }

  void editarPaciente(PacienteModel paciente) async {
    _cargandoController.sink.add(true);
    await _pacientesProvider.editarPaciente(paciente);
    _cargandoController.sink.add(false);
  }

  Future<bool> vincularMedico(String id) async {
    return await _pacientesProvider.vincularMedico(id);
  }

  Future<String> subirFoto(File imagen) async {
    final fotoUrl = await _pacientesProvider.subirFoto(imagen);
    print('name foto: $fotoUrl');
    return fotoUrl;
  }

  String get email => _emailController.value;
  String get password => _passwordController.value;
  String get name => _nameController.value;
  String get lastName => _lastNameController.value;

  dispose() {
    _pacientesController?.close();
    _cargandoController?.close();
    _pacienteController?.close();
    _mensajesController?.close();
    _emailController?.close();
    _passwordController?.close();
    _nameController?.close();
    _lastNameController?.close();
    _tipoPielController?.close();
    _imagenPerfilController?.close();
  }
}
