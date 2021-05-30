import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:suncare/src/providers/usuario_provider.dart';
import 'package:suncare/src/utils/utils.dart' as utils;

class Validators {
  final validarEmail =
      StreamTransformer<String, String>.fromHandlers(handleData: (email, sink) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);

    if (regExp.hasMatch(email)) {
      if (email.contains('yopmail')) {
        sink.addError('Correo no válido');
      } else {
        sink.add(email);
      }
    } else {
      if (email == '') {
        sink.addError('');
      } else {
        sink.addError('Correo no válido');
      }
    }
  });

  final validarEmailBD =
      StreamTransformer<String, String>.fromHandlers(handleData: (email, sink) {
    final CollectionReference usuarios =
        FirebaseFirestore.instance.collection('usuarios');
    final CollectionReference derma =
        FirebaseFirestore.instance.collection('dermatologos');
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);

    if (regExp.hasMatch(email)) {
      if (email.contains('yopmail')) {
        sink.addError('Correo no válido');
      } else {
        // _validarEmailBD(email, usuarioProvider, sink);
        compararEmail(email, usuarios, derma, sink);
        sink.add(email);

        // sink.add(email);
      }
    } else {
      sink.addError('Correo no válido');
    }
  });

  final validarPassword = StreamTransformer<String, String>.fromHandlers(
      handleData: (password, sink) {
    if (password.length >= 8 &&
        password.length <= 16 &&
        utils.isSpecialCaracter(password)) {
      sink.add(password);
    } else {
      if (password == '') {
        sink.addError('');
      } else {
        // sink.addError('Correo no válido');
        // sink.addError('Más de 6 caracteres por favor');
        sink.addError(
            'La contraseña debe poseer entre 8 y 16 caracteres,\n incluyendo por lo menos una mayúscula y \n caracter especial');
      }
    }
  });

  final validarPasswordLogin = StreamTransformer<String, String>.fromHandlers(
      handleData: (password, sink) {
    if (password.length >= 8) { //Changed
      sink.add(password);
    } else {
      if (password == '') {
        sink.addError('');
      } else {
        // sink.addError('Correo no válido');
        sink.addError('Más de 8 caracteres por favor'); //Changed
      }
    }
  });

  final validarCmp =
      StreamTransformer<String, String>.fromHandlers(handleData: (cmp, sink) {
    if (cmp.length == 6) {
      sink.add(cmp);
    } else {
      if (cmp == '') {
        sink.addError('');
      } else {
        // sink.addError('Correo no válido');
      // sink.addError('El dermatólogo no esta registrado');
      sink.addError('El CMP es incorrecto');
      }
    }
  });

  final validarCmpRegistrado =
      StreamTransformer<String, String>.fromHandlers(handleData: (cmp, sink) {
    final CollectionReference derma =
        FirebaseFirestore.instance.collection('dermatologos');
    if (cmp.length == 6) {
      verificarCmp(cmp, derma, sink);
      // sink.add(cmp);
    } else {
      sink.addError('El CMP es incorrecto');
    }
  });

  final validarName =
      StreamTransformer<String, String>.fromHandlers(handleData: (name, sink) {
    final validCharacters = RegExp(r'^[a-zA-Z\u00f1\u00d1]+\s?[a-zA-z&%=\u00f1\u00d1]+$');
    //final validCharacters = RegExp(r'^[a-zA-Z&%=]+$');

    if (name.length >= 3 && name.length <= 30) {
      if (validCharacters.hasMatch(name)) {
        sink.add(name);
      } else {
        sink.addError('Datos no válidos');
      }
    } else {
      if (name == '') {
        sink.addError('');
      } else {
        sink.addError('Más de 3 caracteres por favor');
      }
    }
  });

  final validarMensaje = StreamTransformer<String, String>.fromHandlers(
      handleData: (mensaje, sink) {
    final validCharacters = RegExp(r'^[a-zA-Z0-9.,&%=]+$');
    mensaje = mensaje.replaceAll(RegExp(r' +'), '');

    if (validCharacters.hasMatch(mensaje)) {
      sink.add(mensaje);
    } else {
      if (mensaje == '') {
        sink.addError('');
      } else {
        sink.addError('No incluir caracteres especiales');
      }
    }
  });

  final validarLastname = StreamTransformer<String, String>.fromHandlers(
      handleData: (lastName, sink) {
    final validCharacters = RegExp(r'^[a-zA-Z\u00f1\u00d1&%=]+\s[a-zA-z&%=\u00f1\u00d1]+$');
   
    // final validCharacters = RegExp(r'^[a-zA-Z&%=]+$');

    if (lastName.length >= 4 && lastName.length <= 30) {
      if (validCharacters.hasMatch(lastName)) {
        sink.add(lastName);
      } else {
        sink.addError('Datos no válidos');
      }
    } else {
      if (lastName == '') {
        sink.addError('');
      } else {
        // sink.addError('Más de 3 caracteres por favor');
        sink.addError('Más de 4 caracteres por favor');
      }
    }
  });
}

Future verificarCmp(
    String cmp, CollectionReference d, EventSink<String> sink) async {
  var respuestaDermaFirebase = await d.where("codigo", isEqualTo: cmp);

  await respuestaDermaFirebase.get().then((value) {
    if (value.size > 0) {
      sink.add(cmp);
    } else {
      sink.addError('El dermatólogo no esta registrado');
    }
  });
}

Future compararEmail(String email, CollectionReference u, CollectionReference d,
    EventSink<String> sink) async {
  var respuestaFirebase = await u.where("correo", isEqualTo: email);
  var respuestaDermaFirebase = await d.where("correo", isEqualTo: email);

  await respuestaFirebase.get().then((value) {
    if (value.size > 0) {
      sink.add(email);
    } else {
      respuestaDermaFirebase.get().then((value) {
        if (value.size > 0) {
          sink.add(email);
        } else {
          sink.addError('Correo no registrado');
        }
      });
    }
  });
}
