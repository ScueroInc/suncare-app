import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:suncare/src/models/dermatologo_model.dart';
import 'package:suncare/src/preferencias/preferencias_usuario.dart';

import 'dermatologo_provider.dart';

class VinculacionProvider {
  final DermatologoProvider dermatologoProvider = new DermatologoProvider();
  final PreferenciasUsuario _preferencia = new PreferenciasUsuario();
  final CollectionReference pacientes =
      FirebaseFirestore.instance.collection('usuarios');
  final CollectionReference dermatologos =
      FirebaseFirestore.instance.collection('dermatologos');

  VinculacionProvider() {}

  Future<Map<String, String>> estadoActual() async {
    final idUsuario = _preferencia.userIdDB;
    Map<String, String> datos = Map<String, String>();
    String idMedico = "";
    var respuestaFirebase = await pacientes.doc(idUsuario).get();
    print(respuestaFirebase.data());
    bool respuesta = respuestaFirebase.data()["vinculacion"];
    print(respuestaFirebase.data()["vinculacionIdMedico"]);

    if (respuesta == true) {
      //ya tiene una vunculaciona ctiva
      datos['estado'] = "ACTIVO";
      datos['idMedico'] = respuestaFirebase.data()["vinculacionIdMedico"];
      // idMedico = respuestaFirebase.data()["vinculacionIdMedico"];
    } else {
      if (respuestaFirebase.data()["vinculacionIdMedico"] == null) {
        //no hay ninguna vinculacion pendiente
        datos['estado'] = "NULA";
      } else {
        // vinculacion pendiente
        datos['estado'] = "PENDIENTE";
        // idMedico = respuestaFirebase.data()["vinculacionIdMedico"];
        datos['idMedico'] = respuestaFirebase.data()["vinculacionIdMedico"];
      }
    }

    return datos;
  }

  Future<DermatologoModel> datosVinculacion(String idMedico) async {
    DermatologoModel dermatologo =
        await dermatologoProvider.buscarDermatologo(idMedico);
    return dermatologo;
  }

  Future<bool> crearVinculacion(String codigoMedico) async {
    var idUser = _preferencia.userIdDB;
    var idNombre = _preferencia.userNombreDB;
    bool respuesta = false;
    var idMedicoEncontrado = '';
    await dermatologos.get().then((query) {
      query.docs.forEach((element) {
        print(element.data());
        if (element["codigo"] == codigoMedico) {
          print('encontrado');
          idMedicoEncontrado = element['id'];
          return element;
        }
      });
    });
    if (idMedicoEncontrado == '') return false;

    final Map<String, dynamic> data = Map<String, dynamic>();
    data['idUser'] = idUser;
    data['estado'] = false;
    data['nombre'] = idNombre;
    var fecha = new DateTime.now();
    data['fecha'] = fecha.toString();
    print('/**/');
    print('data a enviar');
    print(idMedicoEncontrado);
    print(idUser);
    print(data);
    print('/**/');

    await dermatologos
        .doc(idMedicoEncontrado)
        .collection('pacientes')
        .doc(idUser)
        .set(data)
        .then((value) {
      respuesta = true;
    });

    await pacientes.doc(idUser).update({
      // 'vinculacion': true,
      'vinculacionIdMedico': idMedicoEncontrado,
      'vinculacionFecha': DateTime.now().toString()
    });

    return respuesta;
  }

  Future<bool> cancelarVinculacion(String idMedico) async {
    final idUsuario = _preferencia.userIdDB;
    bool respuesta = false;

    await dermatologos
        .doc(idMedico)
        .collection('pacientes')
        .doc(idUsuario)
        .delete();

    await pacientes.doc(idUsuario).update({
      'vinculacion': false,
      'vinculacionIdMedico': FieldValue.delete(),
      'vinculacionFecha': FieldValue.delete()
    }).then((value) {
      respuesta = true;
    });
    return respuesta;
  }
}
