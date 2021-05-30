import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime_type/mime_type.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:suncare/src/models/mensaje_model.dart';
import 'package:suncare/src/models/paciente_model.dart';
import 'package:suncare/src/preferencias/preferencias_usuario.dart';

class PacienteProvider {
  final CollectionReference pacientes =
      FirebaseFirestore.instance.collection('usuarios');
  final CollectionReference dermatologos =
      FirebaseFirestore.instance.collection('dermatologos');

  final PreferenciasUsuario _preferencia = new PreferenciasUsuario();

  Future<List<MensajeModel>> buscarMensajes() async {
    List<MensajeModel> listaMensajes = new List();
    // var idUsuario = '2aJfwxkXSafcgPEnSvvaR4UX7073';
    var idUsuario = _preferencia.userIdDB;

    var respuestaFirebase =
        await pacientes.doc(idUsuario).collection('mensaje');

    await respuestaFirebase.get().then((listaFB) {
      listaFB.docs.forEach((element) {
        print(element["idMedico"]);
        listaMensajes.add(MensajeModel(
          idMedico: element["idMedico"],
          fecha: element["fecha"],
          mensaje: element["mensaje"],
        ));
      });
    });
    // var respuestaFirebase = await pacientes
    //     .doc(idUsuario)
    //     .collection('mensaje')
    //     .where("idMedico", isEqualTo: "a");
    // print('-----');
    // await respuestaFirebase.get().then((listaFB) {
    //   print('--> ${listaFB.size}');
    //   // listaFB.docs.forEach((element) {
    //   //   print(element);
    //   // });
    //   listaFB.docs.forEach((element) {
    //     print('*** ${element["a"]}');
    //   });
    // });

    return listaMensajes;
  }

  Future<bool> crearPaciente(PacienteModel paciente) async {
    print('crearPaciente from PROVIDER');
    bool respuesta = false;
    // await pacientes.add(paciente.toJson()).then((value) async {
    //   await pacientes.doc(value.id).update({'id': value.id});
    //   respuesta = true;
    // }).catchError((e) {
    //   print('err: $e');
    //   respuesta = false;
    // });
    await pacientes.doc(paciente.id).set(paciente.toJson()).then((value) {
      respuesta = true;
    });
    return respuesta;
  }

  Future<PacienteModel> buscarPaciente(String id) async {
    var snapshot = await pacientes.doc(id).get();
    print('////////');
    print(snapshot.data());
    var s = PacienteModel.fromJson(snapshot.data());
    print(s);
    print('////////');

    return PacienteModel.fromJson(snapshot.data());
  }

  Future<bool> editarPaciente(PacienteModel paciente) async {
    print('/*************/');
    print(paciente);
    // _preferencia.tipoPiel = paciente.tipoPiel;
    print('la del paciente FIRE* ${paciente.tipoPiel}');
    print('la del paciente MEMO* ${_preferencia.tipoPiel}');
    print('/*************/');
    var snapshot = await pacientes.doc(paciente.id);
    var s = await pacienteModelToJson(paciente);
    var e = await json.decode(s);
    await snapshot.update(e);
    return true;
  }

  Future<bool> vincularMedico(String id) async {
    var idUser = _preferencia.userIdDB;
    var idNombre = _preferencia.userNombreDB;
    bool respuesta = false;
    var idMedicoEncontrado = '';
    await dermatologos.get().then((query) {
      query.docs.forEach((element) {
        print(element.data());
        if (element["codigo"] == id) {
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

    return respuesta;
  }

  Future<String> subirFoto(File imagen) async {
    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/di8bhgjd5/image/upload?upload_preset=rbmsizlm');

    final mimeType = mime(imagen.path).split('/');

    final imagenUploadRequest = http.MultipartRequest(
      'POST',
      url,
    );

    final file = await http.MultipartFile.fromPath('file', imagen.path,
        contentType: MediaType(mimeType[0], mimeType[1]));

    imagenUploadRequest.files.add(file);

    final streamResponse = await imagenUploadRequest.send();
    final respuesta = await http.Response.fromStream(streamResponse);

    if (respuesta.statusCode != 200 && respuesta.statusCode != 201) {
      print('no sé guardo la imagen');
      return null;
    }

    final decodeData = json.decode(respuesta.body);

    return decodeData['secure_url'];
  }
}
