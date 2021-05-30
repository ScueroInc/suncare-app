import 'dart:async';

import 'package:suncare/src/bloc/validators.dart';
import 'package:rxdart/rxdart.dart';

class RecuperarContrasenaBloc with Validators {
  final _emailController = BehaviorSubject<String>();

  Stream<String> get emailStream => _emailController.transform(validarEmailBD);

  Stream<bool> get formValidStream =>
      CombineLatestStream.combine2(emailStream, emailStream, (a, b) => true);

  Function(String) get changeEmail => _emailController.sink.add;

  String get email => _emailController.value;

  dispose() {
    _emailController?.close();
    // _passwordController?.close();
    // _nameController?.close();
    // _lastNameController?.close();
  }
}
