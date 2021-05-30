import 'dart:async';
import 'dart:io';

import 'package:suncare/src/bloc/validators.dart';
import 'package:rxdart/rxdart.dart';

class RegistrarDermatologoBloc with Validators {
  final _emailController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();
  final _nameController = BehaviorSubject<String>();
  final _lastNameController = BehaviorSubject<String>();
  final _cmpController = BehaviorSubject<String>();
  final _imagenPerfilController = BehaviorSubject<File>();
  final _imagenDniController = BehaviorSubject<File>();

  Stream<String> get emailStream => _emailController.transform(validarEmail);
  Stream<String> get passwordStream =>
      _passwordController.transform(validarPassword);
  Stream<String> get nameStream => _nameController.transform(validarName);
  Stream<String> get lastNameStream =>
      _lastNameController.transform(validarLastname);
  Stream<String> get cmpStream => _cmpController.transform(validarCmp);
  Stream<File> get imagenPerfilStream => _imagenPerfilController.stream;
  Stream<File> get imagenDniStream => _imagenDniController.stream;

  Stream<bool> get formValidImage => CombineLatestStream.combine5(
      emailStream,
      passwordStream,
      cmpStream,
      nameStream,
      lastNameStream,
      (e, p, c, n, l) => true);

  Stream<bool> get formValidStream => CombineLatestStream.combine6(
      emailStream,
      passwordStream,
      cmpStream,
      nameStream,
      lastNameStream,
      formValidImage,
      (e, p, c, n, l, f) => true);
  Stream<bool> get formValidStreamWithPhoto => CombineLatestStream.combine8(
      emailStream,
      passwordStream,
      cmpStream,
      nameStream,
      lastNameStream,
      imagenPerfilStream,
      imagenDniStream,
      formValidImage,
      (e, p, c, n, l,i,d, f) => true);

  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;
  Function(String) get changeName => _nameController.sink.add;
  Function(String) get changeLastName => _lastNameController.sink.add;
  Function(String) get changeCmp => _cmpController.sink.add;
  Function(File) get changeImagenPerfil => _imagenPerfilController.sink.add;
  Function(File) get changeImagenDni => _imagenDniController.sink.add;

  String get email => _emailController.value;
  String get password => _passwordController.value;
  String get name => _nameController.value;
  String get lastName => _lastNameController.value;
  String get cmp => _cmpController.value;

  dispose() {
    _emailController?.close();
    _passwordController?.close();
    _nameController?.close();
    _lastNameController?.close();
    _cmpController?.close();
    _imagenPerfilController?.close();
    _imagenDniController?.close();
  }
}
