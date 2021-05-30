import 'dart:convert';

import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class PreferenciasUsuario {
  static final PreferenciasUsuario _instancia =
      new PreferenciasUsuario._internal();

  final String _firebaseToken = 'AIzaSyDCDC0_ksQfnbw3FBghH0F8r1DKwFmeVh4';

  factory PreferenciasUsuario() {
    return _instancia;
  }

  PreferenciasUsuario._internal();

  SharedPreferences _prefs;

  initPreferencias() async {
    this._prefs = await SharedPreferences.getInstance();
    // this
    //     ._prefs
    //     .setString('_spfJson', json.encode([false, false, false, false, true]));
    // this._prefs.setBool('primeraVez', false);
  }

  get primeraVez {
    return _prefs.getBool('primeraVez') ?? false;
  }

  set primeraVez(bool value) {
    _prefs.setBool('primeraVez', value);
  }

  get tipoPiel {
    return _prefs.getString('tipoPiel');
  }

  set tipoPiel(String value) {
    _prefs.setString('tipoPiel', value);
  }

  get spfJson {
    return _prefs.getString('_spfJson') ??
        json.encode([false, false, false, false, true]);
  }

  set spfJson(List<bool> list) {
    // print('${list[1]}');
    var x = json.encode(list);
    print('${x}');
    _prefs.setString('_spfJson', x);
  }

  // GET y SET del nombre
  get token {
    return _prefs.getString('token') ?? '';
  }

  set token(String value) {
    _prefs.setString('token', value);
  }

  get tokenNotification {
    return _prefs.getString('tokenNotification') ?? '';
  }

  set tokenNotification(String value) {
    _prefs.setString('tokenNotification', value);
  }

  get userIdDB {
    return _prefs.getString('userIdDB') ?? '';
  }

  set userIdDB(String value) {
    _prefs.setString('userIdDB', value);
  }

  get userNombreDB {
    return _prefs.getString('userNombreDB') ?? '';
  }

  set userNombreDB(String value) {
    _prefs.setString('userNombreDB', value);
  }

  get userTipoDB {
    return _prefs.getString('userTipoDB') ?? '';
  }

  set userTipoDB(String value) {
    _prefs.setString('userTipoDB', value);
  }

  // GET y SET de la última página
  get ultimaPagina {
    return _prefs.getString('ultimaPagina') ?? 'login';
  }

  set ultimaPagina(String value) {
    _prefs.setString('ultimaPagina', value);
  }

  Future suspenderCuenta(String idToken) async {
    final authData = {
      'idToken': idToken,
    };
    await http.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:delete?key=$_firebaseToken',
        body: json.encode(authData));
  }

  void cerrarSesion() {
    _prefs.setBool('primeraVez', false);
    _prefs.setString('tipoPiel', '');
    _prefs.setString(
        '_spfJson', json.encode([false, false, false, false, true]));
    _prefs.setString('token', '');
    _prefs.setString('tokenNotification', '');
    _prefs.setString('userIdDB', '');
    _prefs.setString('userNombreDB', '');
    _prefs.setString('userTipoDB', '');
    _prefs.setString('ultimaPagina', '');
  }
}
