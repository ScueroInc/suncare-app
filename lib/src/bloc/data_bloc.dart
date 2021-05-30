import 'dart:math';

import 'package:rxdart/subjects.dart';
import 'package:suncare/src/preferencias/preferencias_usuario.dart';
import 'package:suncare/src/providers/data_provider.dart';
import 'package:suncare/src/models/clima_model.dart';

class DataCoreBloc {
  final PreferenciasUsuario _preferencia = new PreferenciasUsuario();
  final _tituloPaginaController = BehaviorSubject<String>();

  final _temperaturaClimaController = BehaviorSubject<double>();
  final _condicionClimaController = BehaviorSubject<String>();
  final _iconClimaController = BehaviorSubject<String>();
  final _lugarClimaController = BehaviorSubject<String>();
  final _regionClimaController = BehaviorSubject<String>();
  final _uvClimaController = BehaviorSubject<double>();
  final _spfClimaController = BehaviorSubject<int>();

  final _vitaminaDController = BehaviorSubject<double>();
  final _tiempoExposicionController = BehaviorSubject<int>();

  final _dataCoreProvider = DataCoreProvider();

  DataCoreBloc() {
    insertarDataPrincipal();
  }

  // Recuperar Data
  Stream<String> get tituloPaginaStream => _tituloPaginaController.stream;
  Stream<double> get climaStream => _temperaturaClimaController.stream;
  Stream<String> get condicionClimaStream => _condicionClimaController.stream;
  Stream<String> get iconClimaStream => _iconClimaController.stream;
  Stream<String> get lugarClimaStream => _lugarClimaController.stream;
  Stream<String> get regionClimaStream => _regionClimaController.stream;
  Stream<double> get uvClimaStream => _uvClimaController.stream;
  Stream<double> get vitaminaDClimaStream => _vitaminaDController.stream;
  Stream<int> get tiempoExposicionStream => _tiempoExposicionController.stream;

  // Insertar Data
  // void insertTEST() async {
  //   print('------------------------------------------');
  // }
  void insertarTituloPagina(String titulo) async {
    _tituloPaginaController.sink.add(titulo);
  }

  void insertarDataPrincipal() async {
    final ReqResRespuesta2 respuesta = await _dataCoreProvider.calcularData();

    _temperaturaClimaController.sink.add(respuesta.tempC);
    _condicionClimaController.sink.add(respuesta.text);
    _iconClimaController.sink.add(respuesta.icon);
    _lugarClimaController.sink.add(respuesta.name);
    _regionClimaController.sink.add(respuesta.region);
    _uvClimaController.sink.add(respuesta.uv);
  }

  void insertVitaminaD() async {
    _vitaminaDController.sink.add(20.0);
  }

  void insertarTiempoMaximoYVitaminaD(List<bool> listaSPF) async {
    int spf = -1;
    int valorSpf = 0;
    for (var i = 0; i < listaSPF.length; i++) {
      if (listaSPF[i] == true) {
        spf = i;
      }
    }

    String tipoPi = _preferencia.tipoPiel;
    int med = 0;
    double stf = 0;

    print('el tipo de piel es: $tipoPi');
    if (tipoPi == '') {
      // no hay valor para tipo de piel
      _tiempoExposicionController.sink.add(1);
      _vitaminaDController.sink.add(0.0);
      print('no hay valor para tipo de piel');
      return;
    } else {
      switch (tipoPi) {
        case 'Tipo I':
          med = 20;
          stf = 1.6000;
          break;
        case 'Tipo II':
          med = 25;
          stf = 1.0667;
          break;
        case 'Tipo III':
          med = 35;
          stf = 0.8000;
          break;
        case 'Tipo IV':
          med = 45;
          stf = 0.6095;
          break;
        case 'Tipo V':
          med = 60;
          stf = 0.4267;
          break;
        case 'Tipo VI':
          med = 100;
          stf = 0.3556;
          break;
        default:
          med = 1;
          stf = 1;
          break;
      }
    }

    switch (spf) {
      case -1:
        valorSpf = 1;
        break;
      case 0:
        valorSpf = 15;
        break;
      case 1:
        valorSpf = 30;
        break;
      case 2:
        valorSpf = 50;
        break;
      case 3:
        valorSpf = 70;
        break;
      case 4:
        valorSpf = 100;
        break;
    }

    var uv = Random().nextInt(29);
    uv++;
    print(uv);
    _uvClimaController.sink.add(uv + 0.0);
    var time = ((med) / (0.15 * uv)).round();
    time = time * valorSpf;

    print(' uv: $uv med: $med  valSpf $valorSpf');
    _tiempoExposicionController.sink.add(time);

    // var latitud =  await Permission.location.request();
    var latitud = 25.6;

    var ascf = _dataCoreProvider.calcularASCF(latitud);
    var sed = (med / 10);
    var svd = sed * ascf;
    var gcf = _dataCoreProvider.calcularGCF(latitud);
    var vdd = svd * gcf;
    //var edad = DateTime.now().difference(_preferencia.).inDays;
    var edad = 23;
    var fbe = _dataCoreProvider.calcularFBE(edad);
    var af = _dataCoreProvider.calcularAF(edad);
    var vitD = vdd * (4.861 / sed) * stf * fbe * af;

    _vitaminaDController.sink.add(vitD);
  }

  dispose() {
    _tituloPaginaController?.close();
    _temperaturaClimaController?.close();
    _condicionClimaController?.close();
    _iconClimaController?.close();
    _lugarClimaController?.close();
    _regionClimaController?.close();
    _uvClimaController?.close();
    _spfClimaController?.close();
    _vitaminaDController?.close();
    _tiempoExposicionController?.close();
  }
}
