import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:suncare/src/preferencias/preferencias_usuario.dart';
import 'package:suncare/src/widgets/tab_statistic.dart';

class BluetoothProvider {
  final PreferenciasUsuario _preferencia = new PreferenciasUsuario();
  final CollectionReference usuarios =
      FirebaseFirestore.instance.collection('usuarios');

  Future<bool> guardarDataIv(
      double uv, int med, double dosis, int tiempo) async {
    bool respuesta = false;
    var idUser = _preferencia.userIdDB;
    final collection_data = usuarios.doc(idUser).collection('datos');

    var now = DateTime.now();
    var order = now.millisecondsSinceEpoch; //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    var horaTexto = now.toIso8601String();
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['uv'] = uv;
    data['med'] = med;
    data['sed'] = med / 10;
    data['dia'] = now.day;
    data['mes'] = now.month;
    data['anio'] = now.year;
    data['hora'] = now.hour;
    data['dosis'] = dosis;
    data['tiempo'] = tiempo;
    data['horaExacta'] = horaTexto.substring(11);
    data['diaTexto'] = now.weekday;
    data['order'] = order;               //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // here_dash
    collection_data.doc('$order').set(data).then((value) {
      respuesta = true;
      print('se inserto la data a FIREBASE');
    });
    return respuesta;
  }

  Future<bool> guardarDosisAcumulada(double acumulado) async {
    bool respuesta = false;
    var idUser = _preferencia.userIdDB;
    var now = DateTime.now();
    var id = now.toString().substring(0, 10);
    final collection_data =
        usuarios.doc(idUser).collection('dosisDiaria').doc(id);

    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['acumulado'] = acumulado;
    data['fecha'] = now;

    collection_data.set(data).then((value) {
      respuesta = true;
      print('se inserto la data a FIREBASE');
    });
    return respuesta;
  }

  //deprecado
  Future<OrdinalSales> dataEstadisticaFecha(DateTime fecha) async {
    print('dashhhhhh fecha $fecha');
    int dia = fecha.day;
    int mes = fecha.month;
    int anio = fecha.year;
    OrdinalSales dataFecha = new OrdinalSales('', 0);

    var idUser = _preferencia.userIdDB;
    final collection_data_fecha = usuarios
        .doc(idUser)
        .collection('datos')
        .where("dia", isEqualTo: dia)
        .where("mes", isEqualTo: mes)
        .where("anio", isEqualTo: anio);

    await collection_data_fecha.get().then((listaFB) {
      var l = listaFB.docs.length;
      if (l == 0) {
        int td = fecha.weekday;
        dataFecha.texto = textoDia(td);
        dataFecha.valor = 0;
      } else {
        int td = listaFB.docs[0]["diaTexto"];
        dataFecha.texto = textoDia(td);
        print('length: $l');
        listaFB.docs.forEach((element) {
          // double sed = element["sed"];
          // print('sed: ${element["sed"]}');
          dataFecha.valor = dataFecha.valor + element["sed"]; //element["sed"]
        });
      }
    });
    return dataFecha;
  }

  Future<String> dataTipoPielFuture() async {
    var idUser = _preferencia.userIdDB;
    final collection_data_fecha = usuarios.doc(idUser);
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

  Future<OrdinalSales> dataEstadisticaFecha2(DateTime fecha) async {
    print('dashhhhhh fecha $fecha');
    int dia = fecha.day;
    int mes = fecha.month;
    int anio = fecha.year;
    OrdinalSales dataFecha = new OrdinalSales('', 0, label: "");
    // var id = new DateTime(anio, mes, dia);
    var idUser = _preferencia.userIdDB;
    // print('dashh |${id.toString().substring(0, 10)}|');
    final collection_data_fecha = usuarios
        .doc(idUser)
        .collection('dosisDiaria')
        .doc(fecha.toString().substring(0, 10));
    // .where("dia", isEqualTo: dia)
    // .where("mes", isEqualTo: mes)
    // .where("anio", isEqualTo: anio);

    await collection_data_fecha.get().then((dataFB) {
      // var l = listaFB.docs.length;
      print('dashh t ${dataFB.data()}');

      if (dataFB.data() == null) {
        int td = fecha.weekday;
        dataFecha.texto = textoDia(td);
        dataFecha.valor = 0;
      } else {
        int td = fecha.weekday;
        dataFecha.texto = textoDia(td);
        dataFecha.valor = dataFB.data()["acumulado"];
        // dataFecha.label = dataFB.data()["sed"].toString();
      }
      // if ( dataFB.data()== 0) {
      //   int td = fecha.weekday;
      //   dataFecha.texto = textoDia(td);
      //   dataFecha.valor = 0;
      // } else {
      //   int td = listaFB.docs[0]["diaTexto"];
      //   dataFecha.texto = textoDia(td);
      //   print('length: $l');
      //   listaFB.docs.forEach((element) {
      //     // double sed = element["sed"];
      //     // print('sed: ${element["sed"]}');
      //     dataFecha.valor = dataFecha.valor + element["sed"]; //element["sed"]
      //   });
      // }
    });
    return dataFecha;
  }

  Future<OrdinalSales> dataEstadisticaDia(DateTime diaActual) async {
    int dia = diaActual.day;
    int mes = diaActual.month;
    int anio = diaActual.year;
    int hora = diaActual.hour;

    OrdinalSales dataDia = new OrdinalSales('', 0);
    var idUser = _preferencia.userIdDB;
    final collection_data_dia = usuarios
        .doc(idUser)
        .collection('datos')
        .where("dia", isEqualTo: dia)
        .where("mes", isEqualTo: mes)
        .where("anio", isEqualTo: anio)
        .where("hora", isEqualTo: hora);

    await collection_data_dia.get().then((listaFB) {
      print('sss ${listaFB.docs}');
      var l = listaFB.docs.length;
      if (l == 0) {
        dataDia.texto = "${diaActual.hour}";
        dataDia.valor = 0;
      } else {
        dataDia.texto = "${diaActual.hour}";
        listaFB.docs.forEach((element) {
          double sum = (element["uv"] / l);
          dataDia.valor = dataDia.valor + sum; //element["sed"]
        });
      }
    });
    return dataDia;
  }

  void sendAlertaTiempo(String alerta) async {
    print("sendAlertaTiempo $alerta");
    final header = {
      'Content-type': 'application/json',
      'Authorization':
          'key=AAAAFwdIfrY:APA91bHUIK4xyY51cPDU-EiIfgl-up4swBso9FC2hb803tGvDAjNtnA97Uks4VZm11yPfMUrHcKBNwT7CG2ulzPvSqJT6Gz4FrLKlE1YnkmyCFuUZ8-i7pMb8Q4BRqyDOW5weOdffqYs',
    };

    var key = _preferencia.tokenNotification;
    var body = {
      "to": key,
      "notification": {"title": "SuncareApp", "body": "Tiempo restante"},
      "data": {"alerta": alerta}
    };

    final respuesta = await http.post('https://fcm.googleapis.com/fcm/send',
        body: json.encode(body), headers: header);
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
