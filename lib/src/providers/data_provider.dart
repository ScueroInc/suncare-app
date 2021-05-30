import 'dart:convert';
// import 'package:location/location.dart' as lc;
// import 'package:geolocator/geolocator.dart';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

import 'package:suncare/src/models/clima_model.dart';
import 'package:suncare/src/preferencias/preferencias_usuario.dart';

class DataCoreProvider {
  final PreferenciasUsuario _preferencia = new PreferenciasUsuario();

  Future<ReqResRespuesta2> calcularData() async {
 
    

    // final location = await http.get(
    //     'api.openweathermap.org/data/2.5/weather?lat=${}&lon=${}&appid=cc5f74521fb2b42038cd700b0069f9e4');
    // final Map<String, dynamic> decodePosition = json.decode(location.body);


    // final location = await http.get(
    //     'api.openweathermap.org/data/2.5/weather?lat=-11&lon=-12appid=cc5f74521fb2b42038cd700b0069f9e4');

    final respuesta = await http.get(
        'https://weatherapi-com.p.rapidapi.com/current.json?q=Peru&lang=ES',
        headers: {
          "x-rapidapi-key":
              'b735988ad9msh4e73a3878b2a467p1b1acajsne46f109f4ca8',
          "x-rapidapi-host": "weatherapi-com.p.rapidapi.com",
          "useQueryString": 'true'
        });
    final Map<String, dynamic> decodeData = json.decode(respuesta.body);
    final ReqResRespuesta2 data = new ReqResRespuesta2();

    print('-----calcularData----');
    print(data);
    data.name = decodeData["location"]["name"];
    // data.name = decodePosition["name"];

    data.region = decodeData["location"]["region"];
    data.uv = decodeData["current"]["uv"];
    data.country = decodeData["location"]["country"];
    data.tempC = decodeData["current"]["temp_c"];
    data.tempF = decodeData["current"]["temp_f"];
    data.text = decodeData["current"]["condition"]["text"];
    data.icon =
        "http://${decodeData["current"]["condition"]["icon"].toString().substring(2)}";

    return data;
  }

  

  Future calcularMED() async {}

  double calcularFBE(int edad) {
    return 0.05;
  }

  double calcularAF(int edad) {
    if (edad <= 20) {
      return 1.0;
    } else if (21 <= edad && edad <= 40) {
      return 0.83;
    } else if (41 <= edad && edad <= 59) {
      return 0.66;
    } else {
      return 0.49;
    }
  }

  double calcularASCF(double latitud) {
    var estacion = calcularEstacion();
    double respuesta = 0.0;

    switch (estacion) {
      case 'Summer':
        if (latitud <= 30) {
          respuesta = 1.11;
        } else if (30 < latitud && latitud <= 35) {
          respuesta = 1.104;
        } else {
          respuesta = 1.067;
        }
        break;
      case 'Fall':
        if (latitud <= 30) {
          respuesta = 1.061;
        } else if (30 < latitud && latitud <= 35) {
          respuesta = 1.029;
        } else {
          respuesta = 0.963;
        }
        break;
      case 'Winter':
        if (latitud <= 30) {
          respuesta = 0.91;
        } else if (30 < latitud && latitud <= 35) {
          respuesta = 0.842;
        } else {
          respuesta = 0.7;
        }
        break;
      case 'Spring':
        if (latitud <= 30) {
          respuesta = 0.742;
        } else if (30 < latitud && latitud <= 35) {
          respuesta = 1.049;
        } else {
          respuesta = 1.008;
        }
        break;
    }

    return respuesta;
  }

  double calcularGCF(double latitud) {
    var estacion = calcularEstacion();
    double respuesta = 0.0;

    switch (estacion) {
      case 'Summer':
        if (latitud <= 30) {
          respuesta = 0.593;
        } else if (30 < latitud && latitud <= 35) {
          respuesta = 0.6;
        } else {
          respuesta = 0.608;
        }
        break;
      case 'Fall':
        if (latitud <= 30) {
          respuesta = 0.655;
        } else if (30 < latitud && latitud <= 35) {
          respuesta = 0.655;
        } else {
          respuesta = 0.681;
        }
        break;
      case 'Winter':
        if (latitud <= 30) {
          respuesta = 0.655;
        } else if (30 < latitud && latitud <= 35) {
          respuesta = 0.655;
        } else {
          respuesta = 0.681;
        }
        break;
      case 'Spring':
        if (latitud <= 30) {
          respuesta = 0.593;
        } else if (30 < latitud && latitud <= 35) {
          respuesta = 0.6;
        } else {
          respuesta = 0.68;
        }
        break;
    }

    return respuesta;
  }

  String calcularEstacion() {
    final fecha = DateTime.now();
    //segun
    final fecha1 = DateTime.parse('${fecha.year}-01-01');
    final fecha2 = DateTime.parse('${fecha.year}-03-21');
    final fecha3 = DateTime.parse('${fecha.year}-06-22');
    final fecha4 = DateTime.parse('${fecha.year}-09-24');
    final fecha5 = DateTime.parse('${fecha.year}-12-22');
    final fecha6 = DateTime.parse('${fecha.year}-12-31');

    if (fecha.isAfter(fecha1) && fecha.isBefore(fecha2)) {
      print(fecha);
      print('esta verano');
      return 'Summer';
    }

    if (fecha.isAfter(fecha2) && fecha.isBefore(fecha3)) {
      print(fecha);
      print('esta otño');
      return 'Fall';
    }

    if (fecha.isAfter(fecha3) && fecha.isBefore(fecha4)) {
      print(fecha);
      print('esta invierno');
      return 'Winter';
    }

    if (fecha.isAfter(fecha4) && fecha.isBefore(fecha5)) {
      print(fecha);
      print('esta primavera');
      return 'Spring';
    }

    if (fecha.isAfter(fecha5) && fecha.isBefore(fecha6)) {
      print(fecha);
      print('esta verano');
      return 'Summer';
    }
  }
}
