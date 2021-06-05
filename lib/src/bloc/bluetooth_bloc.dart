import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_blue/flutter_blue.dart' as blue;

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:flutter_blue/flutter_blue.dart';
import 'package:rxdart/rxdart.dart';
import 'package:suncare/src/preferencias/preferencias_usuario.dart';
import 'package:suncare/src/providers/bluetooth_provider.dart';
import 'package:suncare/src/widgets/tab_statistic.dart';

class BluetoothBloc {
  final PreferenciasUsuario _preferencia = new PreferenciasUsuario();
  final _bluetoothProvider = BluetoothProvider();

  StreamSubscription<BluetoothDiscoveryResult> _streamSubscription;
  List<BluetoothDiscoveryResult> results = <BluetoothDiscoveryResult>[];
  final instance = FlutterBluetoothSerial.instance;
  final _deviceFind = BehaviorSubject<bool>();
  final _deviceController = BehaviorSubject<BluetoothDevice>();
  final _resultScan = BehaviorSubject<List<BluetoothDiscoveryResult>>();
  final _buscandoDispositivosController = BehaviorSubject<bool>();
  final _dataIVController = BehaviorSubject<double>();
  final _dataIVAnteriorController = BehaviorSubject<double>();
  final _dataTiempoController = BehaviorSubject<double>();
  final _dataTiempoAnteriorController = BehaviorSubject<double>();
  final _startTiempoController = BehaviorSubject<bool>();
  final _tiempoController = BehaviorSubject<double>();
  final _tiempoEsperadoController = BehaviorSubject<int>();
  final _tiempoRealController = BehaviorSubject<int>();
  final _dosisController = BehaviorSubject<double>();
  final _dosisAcumuladaController = BehaviorSubject<double>();
  final _estadoBluetoothController = BehaviorSubject<bool>();

  BluetoothBloc() {}
  Stream<bool> get escuchandoStateBlueStream =>
      _estadoBluetoothController.stream;

  Stream<List<BluetoothDiscoveryResult>> get resultScanStream =>
      _resultScan.stream;

  Stream<bool> get buscandoDispositivosStream =>
      _buscandoDispositivosController.stream;

  Stream<double> get dataIVStream => _dataIVController.stream;
  Stream<double> get dataIVAnteriorStream => _dataIVAnteriorController.stream;
  Stream<double> get dataTiempoAnteriorStream =>
      _dataTiempoAnteriorController.stream;
  Stream<double> get dataTiempoStream => _dataTiempoController.stream;
  Stream<BluetoothDevice> get deviceStream => _deviceController.stream;
  void limpiarLista() async {
    _resultScan.sink.add([]);
  }

  void insertarEstadoBluetooth(bool state) {
    _estadoBluetoothController.sink.add(state);
  }

  void desincronizar() async {
    print('raaaaaa  desincronizando ..');
    _deviceController.sink.add(null);
  }

  void startDiscovery() async {
    _resultScan.sink.add([]);

    instance.startDiscovery().listen((data) {
      this._buscandoDispositivosController.sink.add(true);
      // addLista(data);
      if (data.device.address == '00:21:13:02:D3:80') {
        results = [];
        results.add(data);
        _resultScan.sink.add(results);
      }
    }).onDone(() {
      print('Termino de BUSCAR');
      this._buscandoDispositivosController.sink.add(false);
    });
  }

  Future<bool> conectarDevice(BluetoothDevice device) async {
    print(' CLICK conectarDevice');
    // final BluetoothConnection connection =
    //     await BluetoothConnection.toAddress(device.address);
    // connection.input.listen((event) {
    //   String dataStr = ascii.decode(event);
    //   print('-----> $dataStr');
    // });
    //
    //
    this._deviceController.sink.add(device);
    return true;
  }

  void addLista(BluetoothDiscoveryResult data) async {
    print('******************************************');
    results = _resultScan.value;
    bool insertar = false;
    print('exe: ${data.device.address} y n:${results.length}');

    if (_resultScan.value.length == 0) {
      results.add(data);
      _resultScan.sink.add(results);
      return;
    }

    print('la old d es ${results.length}');
    _resultScan.value.forEach((element) {
      print('-> ${element.device.address}');
      if (element.device.address != data.device.address) {
        insertar = true;
        print('en el if b:${insertar}');
      }
    });
    if (insertar) {
      print('hora de insertar');
      results.add(data);
      _resultScan.sink.add(results);
    }
    print('la new d es ${results.length}');
    print('------------------------------------------');
  }

  void insertarIVController(int tiempoBusqueda) async {
    // if (_tiempoController.value == null) {}
    var iv = generarIV();
    double acu = 0;
    if (iv != 0) {
      int med = getMED();
      double sed = med / 10;
      int spf = getSPF();
      double dosis = 0;
      double dosisAcumulada = 0;
      if (_startTiempoController.value == true) {
        acu = _dosisAcumuladaController.value;
        print('+dashh ti ${tiempoBusqueda}');
        print('+dashh iv ${_dataIVController.value}');
        print('+dashh sp ${spf}');
        dosis =
            (3 * _dataIVController.value * (tiempoBusqueda / 60)) / (200 * spf);
        dosisAcumulada = dosis + _dosisAcumuladaController.value;
        _dosisAcumuladaController.sink.add(dosisAcumulada);

        print('+dashh do ${dosis}');
      } else {
        _dosisAcumuladaController.sink.add(0);
        _startTiempoController.sink.add(true);
      }
      print('+dashh da ${dosisAcumulada}');
      await _bluetoothProvider.guardarDosisAcumulada(dosisAcumulada);
      _dataIVController.sink.add(iv);
      // double dosisAcu = _dosisAcumuladaController.value;

      double t = calcularTiempo(sed, spf, acu);
      /*---------------------------lil----------------------------------- */
      if (_dataTiempoController.value == null) {
        _dataTiempoController.sink.add(t);
        _dataTiempoAnteriorController.sink.add(t);
      }

      double tAnterior = _dataTiempoController.value;
      print('+dashh |${iv} ${_dataIVController.value}| --- $tAnterior');
      if (iv != _dataIVController.value) {
        _dataTiempoAnteriorController.sink.add(tAnterior);
      }
      /*---------------------------lil----------------------------------- */
      print('+dashh ti ${t}');
      print('+dashh ta ${_dataTiempoAnteriorController.value}');
      _dataTiempoController.sink.add(t);

      await _bluetoothProvider.guardarDataIv(iv, med, dosis, tiempoBusqueda);
    } else {
      _dataTiempoController.sink.add(0); //lil
      print('+dashh --- ${_dataTiempoController.value}');
      _dataIVController.sink.add(iv);
    }
    print('+dashh -----------------------------------------}');
  }

  double calcularTiempo(double sed, int valorSpf, double dosisAcu) {
    // double dosisAcu = _dosisAcumuladaController.value;
    double uv = _dataIVController.value;
    print('+dashh |($sed - $dosisAcu) * $valorSpf * 200 / ( $uv *3)|');
    // double dosisAcu = _dosisAcumuladaController.value;
    // if (dosisAcu == null) {
    //   dosisAcu = 0;
    //   _dosisAcumuladaController.sink.add(0);
    // } else {}
    double time = ((sed - dosisAcu) / (0.015 * uv));
    time = time * valorSpf;
    return time;
  }

  BluetoothDevice get lastDevice => _deviceController.value;
  double get lastIV => _dataIVController.value;
  double generarIV() {
    var now = DateTime.now();

    double n = getUVPorHora(now.hour);
    // var r = new Random();
    // double n = r.nextInt(25) + r.nextDouble();
    // n = n.roundToDouble();

    return n;
  }

  double getUVPorHora(int hora) {
    double uv = 0.0;

    switch (hora) {
      case 0:
        uv = 10.0;
        break;
      case 1:
        uv = 10.0;
        break;
      case 2:
        uv = 10.0;
        break;
      case 3:
        uv = 10.0;
        break;
      case 4:
        uv = 10.0;
        break;
      case 7:
        uv = 0.2;
        break;
      case 8:
        uv = 0.8;
        break;
      case 9:
        uv = 4.0;
        break;
      case 10:
        uv = 5.6;
        break;
      case 11:
        uv = 8.5;
        break;
      case 12:
        uv = 9.0;
        break;
      case 13:
        uv = 8.0;
        break;
      case 14:
        uv = 5.3;
        break;
      case 15:
        uv = 4.0;
        break;
      case 16:
        uv = 2.0;
        break;
      case 17:
        uv = 1.2;
        break;
      case 18:
        uv = 0.3;
        break;
      case 19:
        uv = 10.0;
        break;
      case 20:
        uv = 10.0;
        break;
      case 21:
        uv = 10.0;
        break;
      case 22:
        uv = 10.0;
        break;
      case 23:
        uv = 10.0;
        break;
      default:
    }

    return uv;
  }

  int getMED() {
    String tipoPi = _preferencia.tipoPiel;
    int med = 0;

    if (tipoPi == '') {
    } else {
      switch (tipoPi) {
        case 'Tipo I':
          med = 20;
          break;
        case 'Tipo II':
          med = 25;
          break;
        case 'Tipo III':
          med = 35;
          break;
        case 'Tipo IV':
          med = 45;
          break;
        case 'Tipo V':
          med = 60;
          break;
        case 'Tipo VI':
          med = 100;
          break;
        default:
          med = 1;
          break;
      }
    }

    return med;
  }

  int getSPF() {
    int spf = -1;
    int valorSpf = 0;
    var listaSPF =
        List<bool>.from(json.decode(_preferencia.spfJson).map((x) => x));

    for (var i = 0; i < listaSPF.length; i++) {
      if (listaSPF[i] == true) {
        spf = i;
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

    return valorSpf;
  }

  void sendAlertaTiempo(String alerta) async {
    print('sendAlertaTiempo');
    _bluetoothProvider.sendAlertaTiempo(alerta);
  }

  void dispose() {
    _streamSubscription?.cancel();
    _deviceFind?.close();
    _deviceController?.close();
    _resultScan?.close();
    _buscandoDispositivosController?.close();
    _dataIVController?.close();
    _dataTiempoController?.close();

    _dataTiempoAnteriorController?.close();

    _tiempoController?.close();
    _tiempoEsperadoController?.close();
    _tiempoRealController?.close();
    _dosisController?.close();
    _dosisAcumuladaController?.close();
    _startTiempoController?.close();
    _estadoBluetoothController?.close();
    _dataIVAnteriorController?.close();
  }
}
