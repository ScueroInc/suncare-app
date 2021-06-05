import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mime_type/mime_type.dart';
import 'package:suncare/src/models/dermatologo_model.dart';
import 'package:suncare/src/models/mensaje_model.dart';
import 'package:suncare/src/models/paciente_model.dart';
import 'package:suncare/src/models/solicitud_model.dart';
import 'package:suncare/src/models/solicitud_validacion_model.dart';
import 'package:suncare/src/preferencias/preferencias_usuario.dart';
import 'package:suncare/src/widgets/tab_pacientes.dart';
import 'package:suncare/src/widgets/tab_statistic.dart';

class DermatologoProvider {
  final CollectionReference dermatologos =
      FirebaseFirestore.instance.collection('dermatologos');
  final CollectionReference usuarios =
      FirebaseFirestore.instance.collection('usuarios');
  final PreferenciasUsuario _preferencia = new PreferenciasUsuario();

  Future<bool> crearDermatologo(DermatologoModel dermatologo,
      SolicitudValidacionModel solicitudvalidacion) async {
    print('crearDermatologo from PROVIDER');
    var now = DateTime.now();
    dermatologo.order = now.millisecondsSinceEpoch;
    bool respuesta = false;

    try {
      await dermatologos.doc(dermatologo.id).set(dermatologo.toJson());

      await dermatologos
          .doc(dermatologo.id)
          .update({'solicitudes': solicitudvalidacion.toJson()});

      var datavalidada = await validarDatosDermatologo(dermatologo);

      await dermatologos.doc(dermatologo.id).update(datavalidada).then((value) {
        respuesta = true;
      });

      print('datavalidada-> $datavalidada');
    } catch (e) {
      print('error al crear al dermatologo $e');
    }
    return respuesta;
  }

  Future<Map<String, dynamic>> validarDatosDermatologo(
      DermatologoModel dermatologo) async {
    var body = {
      "nombres": dermatologo.nombre.toUpperCase(),
      "apellidos": dermatologo.apellido.toUpperCase(),
      "cmp": dermatologo.codigo
    };

    print('body enviado->$body');

    var bodyString = json.encode(body);
    print('bodystring enviado->>> $bodyString');
    final respuesta = await http.post(
        'https://suncare-api.herokuapp.com/api/validar',
        body: bodyString,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        });

    final Map<String, dynamic> decodeData = json.decode(respuesta.body);
    print('datavalidada del api-> $decodeData');
    return decodeData;
  }

  Future<List<MensajeModel>> listarMensajePorUsuario(String idUsuario) async {
    var idDermatologo = _preferencia.userIdDB;
    print('idDermatologo $idDermatologo');
    List<MensajeModel> listaMensajes = new List();
    var respuestaFirebase = await usuarios
        .doc(idUsuario)
        .collection('mensaje')
        .where("idMedico", isEqualTo: idDermatologo)
        .orderBy('fecha', descending: true);

    await respuestaFirebase.get().then((listaFB) {
      listaFB.docs.forEach((element) {
        print(element["mensaje"]);
        var date = DateTime.fromMillisecondsSinceEpoch(element["fecha"]); //!
        print("fecha string ${date.toString()}");
        listaMensajes.add(MensajeModel(
          idMedico: element["idMedico"],
          fecha: date.toString(), //!
          mensaje: element["mensaje"],
        ));
      });
    });
    return listaMensajes;
  }

  Future<String> dataTipoPielFuture(String id) async {
    // var idUser = _preferencia.userIdDB;
    final collection_data_fecha = usuarios.doc(id);
    var strinTipoPiel = "";
    var x = await collection_data_fecha.get();
    if (x.data() == null) {
      strinTipoPiel = "";
    } else {
      strinTipoPiel = x.data()["tipoPiel"];
    }

    switch (x.data()["tipoPiel"]) {
      case "Tipo I":
        strinTipoPiel = "2";
        break;
      case "Tipo II":
        strinTipoPiel = "2.5";
        break;
      case "Tipo III":
        strinTipoPiel = "3.5";
        break;
      case "Tipo IV":
        strinTipoPiel = "4.5";
        break;
      case "Tipo V":
        strinTipoPiel = "6";
        break;
      case "Tipo VI":
        strinTipoPiel = "10";
        break;
      default:
    }
    return strinTipoPiel;
  }

  Future<List<SolicitudModel>> listarSolicitudes() async {
    String idDermatologo = _preferencia.userIdDB;
    List<SolicitudModel> listaSolicitudes = new List();

    var respuestaFirebase = await usuarios
        .where("vinculacionIdMedico", isEqualTo: idDermatologo)
        .where("vinculacion", isEqualTo: false);

    await respuestaFirebase.get().then((listaFB) {
      print('se encontro ${listaFB.size}');
      print(listaFB.docs);
      print('---------------');
      listaFB.docs.forEach((element) {
        listaSolicitudes.add(SolicitudModel(
          idUser: element["id"],
          vinculacion: element["vinculacion"],
          vinculacionIdMedico: element["vinculacionIdMedico"],
          vinculacionFecha: element["vinculacionFecha"],
          nombre: element["nombre"] + " " + element["apellido"],
          imagenProfile: element["imagenProfile"],
        ));
      });
    });
    // print(listaSolicitudes[0].nombre);
    // print(listaSolicitudes[0].imagenProfile);
    // print(listaSolicitudes[0].vinculacionFecha);
    // print(listaSolicitudes[0].vinculacionIdMedico);
    // print(listaSolicitudes[0].vinculacion);
    return listaSolicitudes;
  }

  Future<bool> editarDermatologo(DermatologoModel dermatologo) async {
    print('/*************/');
    print(dermatologo);
    print('/*************/');
    var snapshot = await dermatologos.doc(dermatologo.id);
    var s = await dermatologoModelToJson(dermatologo);
    var e = await json.decode(s);
    await snapshot.update(e);
    return true;
  }

  Future<DermatologoModel> buscarDermatologo(String id) async {
    var snapshot = await dermatologos.doc(id).get();
    print('////////');
    print(snapshot.data());
    var s = DermatologoModel.fromJson(snapshot.data());
    print(s);
    print('////////');

    return DermatologoModel.fromJson(snapshot.data());
  }

  Future<bool> cancelarSolicitud(SolicitudModel solictud) async {
    String idDermatologo = _preferencia.userIdDB;
    bool respuesta = false;
    var snapshot = await dermatologos
        .doc(idDermatologo)
        .collection('pacientes')
        .doc(solictud.idUser)
        .delete();

    // solictud.vinculacion = true;
    // print('-*-*-*-');
    // print('dermatologos');
    // print(idDermatologo);
    // print('pacientes');
    // print(solictud.idUser);
    // print('-*-*-*- ${solictud.toJson()}');
    // await snapshot.update(solictud.toJson());

    await usuarios.doc(solictud.idUser).update({
      'vinculacion': false,
      'vinculacionIdMedico': FieldValue.delete(),
      'vinculacionFecha': FieldValue.delete()
    }).then((value) {
      respuesta = true;
    });

    return respuesta;
  }

  Future<bool> aceptarSolicitud(SolicitudModel solictud) async {
    String idDermatologo = _preferencia.userIdDB;
    bool respuesta = false;
    print('**********');
    print(solictud.idUser);
    print(solictud.vinculacion);
    print(solictud.vinculacionFecha);
    print(solictud.vinculacionIdMedico);
    print('**********');
    await usuarios.doc(solictud.idUser).update({
      'vinculacion': true,
      'vinculacionIdMedico': solictud.vinculacionIdMedico,
      'vinculacionFecha': DateTime.now().toString()
    }).then((value) {
      respuesta = true;
    });

    return respuesta;
  }

  Future<List<PacienteModel>> listarPacientes() async {
    String idDermatologo = _preferencia.userIdDB;
    List<PacienteModel> listaPaciente = new List();

    var respuestaFirebase = await usuarios
        .where("vinculacionIdMedico", isEqualTo: idDermatologo)
        .where("vinculacion", isEqualTo: true)
        .orderBy("nombre");

    // var s = respuestaFirebase.snapshots();
    // print(s);
    await respuestaFirebase.get().then((listaFB) {
      listaFB.docs.forEach((element) {
        listaPaciente.add(PacienteModel(
          nombre: element["nombre"],
          apellido: element["apellido"],
          id: element["id"],
          correo: element["correo"],
          imagenProfile: element["imagenProfile"],
          nacimiento: element["nacimiento"],
          tipoPiel: element["tipoPiel"],
        ));
      });
    });

    return listaPaciente;
  }

  Future<List<PacienteModel>> buscarPacientesPorNombre(String nombre) async {
    String idDermatologo = _preferencia.userIdDB;
    List<PacienteModel> listaPaciente = new List();
    print('voy a buscar ${nombre}');
    print('voy a buscar ${idDermatologo}');

    String a = "", b = "";
    if (nombre != "") {
      a = nombre.substring(0, 1).toUpperCase();
      b = nombre.substring(1).toLowerCase();
    }

    var respuestaFirebase = await usuarios
        .where("vinculacionIdMedico", isEqualTo: idDermatologo)
        .where("vinculacion", isEqualTo: true)
        .where("nombre", isGreaterThanOrEqualTo: a + b)
        .where("nombre", isLessThanOrEqualTo: a + b + '\uf8ff')
        .get();

    var docs = await respuestaFirebase.docs;

    docs.forEach((element) {
      print('-----> ${element["nombre"]}');
      listaPaciente.add(PacienteModel(
        nombre: element["nombre"],
        apellido: element["apellido"],
        id: element["id"],
        correo: element["correo"],
        imagenProfile: element["imagenProfile"],
        nacimiento: element["nacimiento"],
        tipoPiel: element["tipoPiel"],
      ));
    });
    return listaPaciente;
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

  Future<bool> crearMensaje(String idUsuario, String mensaje) async {
    bool respuesta = false;
    final idMedico = _preferencia.userIdDB;
    final ruta = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(idUsuario)
        .collection('mensaje');

    print('-------');
    print(idUsuario);
    print(idMedico);
    print('-------');
    await ruta.add({
      'idMedico': idMedico,
      'mensaje': mensaje,
      'fecha': DateTime.now().toUtc().millisecondsSinceEpoch,
    }).then((value) => respuesta = true);

    return respuesta;
  }

  Future<Map<String, dynamic>> postNotificacion(String idPaciente) async {
    print("idPaciente a buscar->$idPaciente");
    String tokenPaciente;
    final paciente = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(idPaciente)
        .get()
        .then((value) => {
              print(value),
              tokenPaciente = value['tokens']['tokenDevice'],
            });
    print('token obtenido-> $tokenPaciente');

    String key =
        'AAAAFwdIfrY:APA91bHUIK4xyY51cPDU-EiIfgl-up4swBso9FC2hb803tGvDAjNtnA97Uks4VZm11yPfMUrHcKBNwT7CG2ulzPvSqJT6Gz4FrLKlE1YnkmyCFuUZ8-i7pMb8Q4BRqyDOW5weOdffqYs';
    var body = {
      "to": tokenPaciente,
      "notification": {
        "title": "Nuevas recomendaciones",
        "body": "Tu dermatologo te ha enviado nuevas recomendaciones"
      },
      "data": {
        "alerta": "mensaje",
        "click_action": "FLUTTER_NOTIFICATION_CLICK"
      }
    };

    print('body enviado->$body');

    var bodyString = json.encode(body);
    print('bodystring enviado->>> $bodyString');
    final respuesta = await http.post('https://fcm.googleapis.com/fcm/send',
        body: bodyString,
        headers: {
          'Content-type': 'application/json',
          "Authorization": "key=$key"
        });

    final Map<String, dynamic> decodeData = json.decode(respuesta.body);
    print('respuesta del fcm-> $decodeData');
    return decodeData;
  }

  Future<OrdinalSales> dataEstadisticaFecha2(
      DateTime fecha, String idUser) async {
    print('dashhhhhh fecha $fecha');
    int dia = fecha.day;
    int mes = fecha.month;
    int anio = fecha.year;
    OrdinalSales dataFecha = new OrdinalSales('', 0, label: "");

    final collection_data_fecha = usuarios
        .doc(idUser)
        .collection('dosisDiaria')
        .doc(fecha.toString().substring(0, 10));
    // .where("dia", isEqualTo: dia)
    // .where("mes", isEqualTo: mes)
    // .where("anio", isEqualTo: anio);

    var dataFB = await collection_data_fecha.get();

    if (dataFB.data() == null) {
      int td = fecha.weekday;
      dataFecha.texto = textoDia(td);
      dataFecha.valor = 0;
    } else {
      int td = fecha.weekday;
      dataFecha.texto = textoDia(td);
      dataFecha.valor = dataFB.data()["acumulado"];
      dataFecha.label =
          dataFB.data()["acumulado"].toStringAsFixed(1).toString();
    }
    return dataFecha;
  }

  String textoDia(int td) {
    String texto = "";
    switch (td) {
      case 1:
        texto = "L";
        break;
      case 2:
        texto = "Ma";
        break;
      case 3:
        texto = "Mi";
        break;
      case 4:
        texto = "J";
        break;
      case 5:
        texto = "V";
        break;
      case 6:
        texto = "S";
        break;
      case 7:
        texto = "D";
        break;
      default:
        texto = "";
    }
    return texto;
  }
}
