import 'dart:async';

import 'package:suncare/src/bloc/validators.dart';
import 'package:rxdart/rxdart.dart';

class RegistrarBloc with Validators {
  final _emailController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();
  final _nameController = BehaviorSubject<String>();
  final _lastNameController = BehaviorSubject<String>();

  Stream<String> get emailStream => _emailController.transform(validarEmail);
  Stream<String> get passwordStream =>
      _passwordController.transform(validarPassword);
  Stream<String> get nameStream => _nameController.transform(validarName);
  Stream<String> get lastNameStream =>
      _lastNameController.transform(validarLastname);

  Stream<bool> get formValidStream => CombineLatestStream.combine4(emailStream,
      passwordStream, nameStream, lastNameStream, (e, p, n, l) => true);

  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;
  Function(String) get changeName => _nameController.sink.add;
  Function(String) get changeLastName => _lastNameController.sink.add;
  // Function(bool) get changeFormValid;
  String get email => _emailController.value;
  String get password => _passwordController.value;
  String get name => _nameController.value;
  String get lastName => _lastNameController.value;


  dispose() {
    _emailController?.close();
    _passwordController?.close();
    _nameController?.close();
    _lastNameController?.close();
  }
}
