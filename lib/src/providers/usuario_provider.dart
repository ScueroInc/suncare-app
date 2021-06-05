import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:http/http.dart' as http;
import 'package:suncare/src/preferencias/preferencias_usuario.dart';

class UsuarioProvider {
  final String _firebaseToken = 'AIzaSyDCDC0_ksQfnbw3FBghH0F8r1DKwFmeVh4';
  final PreferenciasUsuario _preferencia = new PreferenciasUsuario();
  final String urlCorreo =
      'https://suncare-api.herokuapp.com/api/enviarcorreo/correo/';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };

    final respuesta = await http.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_firebaseToken',
        body: json.encode(authData));

    Map<String, dynamic> decodeRespuesta = json.decode(respuesta.body);
    print(decodeRespuesta);

    if (decodeRespuesta.containsKey('idToken')) {
      //guardar token
      _preferencia.token = decodeRespuesta['idToken'];
      _preferencia.userIdDB = decodeRespuesta['localId'];

      return {
        'ok': true,
        'token': decodeRespuesta['idToken'],
        'localId': decodeRespuesta['localId']
      };
    } else {
      return {'ok': false, 'mensaje': decodeRespuesta['error']['message']};
    }
  }

  Future<Map<String, dynamic>> registrar(String email, String password) async {
    print('correo  ===> $email');
    print('password===> $password');
    final authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };

    final respuesta = await http.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_firebaseToken',
        body: json.encode(authData));

    Map<String, dynamic> decodeRespuesta = json.decode(respuesta.body);
    print(decodeRespuesta);

    if (decodeRespuesta.containsKey('idToken')) {
      //guardar token
      // _preferencia.token = decodeRespuesta['idToken'];
      // _preferencia.userIdDB = decodeRespuesta['localId'];

      return {
        'ok': true,
        'token': decodeRespuesta['idToken'],
        'localId': decodeRespuesta['localId']
      };
    } else {
      return {'ok': false, 'mensaje': decodeRespuesta['error']['message']};
    }
  }

  Future enviarRecuperarContrasena(String email) async {
    final authData = {
      'requestType': "PASSWORD_RESET",
      'email': email,
    };
    await http.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=$_firebaseToken',
        body: json.encode(authData));
    // Map<String, dynamic> decodeRespuesta = json.decode(respuesta.body);
    // print(decodeRespuesta);

    // if (decodeRespuesta.containsKey('idToken')) {
    //   //guardar token
    //   _preferencia.token = decodeRespuesta['idToken'];
    //   _preferencia.userIdDB = decodeRespuesta['localId'];

    //   return {
    //     'ok': true,
    //     'token': decodeRespuesta['idToken'],
    //     'localId': decodeRespuesta['localId']
    //   };
    // } else {
    //   return {'ok': false, 'mensaje': decodeRespuesta['error']['message']};
    // }
  }

  Future enviarVerificacionPorCorreo(String correo) async {
    final asunto = "Solicitud de registro en SunCare App";
    final mensaje =
        "¡Saludos!<br>Gracias por enviar una solicitud de registro, esta será evaluada en los próximos días. Queda atento(a) a nuestra respuesta.<br>Atentamente,<br>Equipo de Gestión de accesos de SunCare.";

    final data = {"correo": correo, "asunto": asunto, "mensaje": mensaje};

    final response = await http.post(urlCorreo, body: data);
    Map<String, dynamic> decodeRespuesta = json.decode(response.body);
    print(decodeRespuesta);
  }

  Future<String> tipoUsuario(String id) async {
    var respuesta = '';
    CollectionReference usuarios =
        await FirebaseFirestore.instance.collection("usuarios");

    var snapshot = await usuarios.doc(id).get();
    print(snapshot);
    Map<String, dynamic> data = snapshot.data();
    // snapshot.data()
    print(id);
    print('XXXXXXXXXXXX');
    // print(data['tipo']);
    // if (data['tipo'] == 'paciente') {
    //   respuesta = 'paciente';
    // } else {
    //   respuesta = 'dermatologo';
    // }
    if (snapshot.data() != null) {
      respuesta = 'paciente';
    } else {
      respuesta = 'dermatologo';
    }
    print(respuesta);
    print(snapshot.data());
    print('XXXXXXXXXXXX');
    return respuesta;
  }

  Future<String> getNombreUser(String id, String tipo) async {
    CollectionReference usuarios;
    String nombreCompleto = "";
    if (tipo == 'paciente') {
      usuarios = await FirebaseFirestore.instance.collection("usuarios");
    } else {
      usuarios = await FirebaseFirestore.instance.collection("dermatologos");
    }
    await usuarios
        .doc(id)
        .get()
        .then((value) => {nombreCompleto = value['nombre']});

    return nombreCompleto;
  }

  Future<String> dermatogoloEsAceptado(String id) async {
    var dermatologo = await FirebaseFirestore.instance
        .collection('dermatologos')
        .doc(id)
        .get();
    print('datos del derma a verificar estadoSolicitud: ${dermatologo.data()}');
    var estado = dermatologo['solicitudes']['estadoSolicitud'];
    print('estadoSolicitud del derma-> $estado');
    return estado;
  }
}
