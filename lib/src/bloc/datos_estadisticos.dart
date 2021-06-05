import 'package:charts_flutter/flutter.dart' as charts;
import 'package:suncare/src/preferencias/preferencias_usuario.dart';
import 'package:suncare/src/providers/bluetooth_provider.dart';
import 'package:suncare/src/widgets/tab_statistic.dart';
import 'package:rxdart/rxdart.dart';

class EstadisticosBloc {
  final PreferenciasUsuario _preferencia = new PreferenciasUsuario();
  final _bluetoothProvider = BluetoothProvider();
  final _listaReporteSemanalController =
      BehaviorSubject<List<charts.Series<OrdinalSales, String>>>();
  final _listaReporteDiarioController =
      BehaviorSubject<List<charts.Series<OrdinalSales, String>>>();

  Stream<List<charts.Series<OrdinalSales, String>>>
      get listaReporteSemanalStream => _listaReporteSemanalController.stream;
  Stream<List<charts.Series<OrdinalSales, String>>>
      get listaReporteDiarioStream => _listaReporteDiarioController.stream;

  Future<OrdinalSales> dataEstadisticaFecha(DateTime fecha) async {
    // var f =_bluetoothProvider.dataEstadisticaFecha();
    OrdinalSales data = await _bluetoothProvider.dataEstadisticaFecha2(fecha);
    print('kinkin 1 $fecha ${data.valor}');
    return data;
  }

  Future<String> dataTipoPielFuture() async {
    // var f =_bluetoothProvider.dataEstadisticaFecha();
    // OrdinalSales data = await _bluetoothProvider.dataEstadisticaFecha2(fecha);
    // print('kinkin 1 $fecha ${data.valor}');
    var xtipoPiel = await _bluetoothProvider.dataTipoPielFuture();
    print('datata 0 ${xtipoPiel}');
    return xtipoPiel;
  }

  Future<OrdinalSales> dataEstadisticaDia(DateTime fecha) async {
    // var f =_bluetoothProvider.dataEstadisticaFecha();
    OrdinalSales data = await _bluetoothProvider.dataEstadisticaDia(fecha);
    print('kinkin 2 dataEstadisticaDia ${data.valor}');
    return data;
  }

  void insertarDataInitSemanal(DateTime fecha) async {
    List<charts.Series<OrdinalSales, String>> listDataSemanal = [];
    // bool val = false;
    // var d1 = await dataEstadisticaFecha(dia, mes, anio);
    // for (var i = 1; i <= 7; i++) {
    print("kinkin $fecha");
    // }
    var d6 = await dataEstadisticaFecha(
        new DateTime(fecha.year, fecha.month, fecha.day - 6));
    var d5 = await dataEstadisticaFecha(
        new DateTime(fecha.year, fecha.month, fecha.day - 5));
    var d4 = await dataEstadisticaFecha(
        new DateTime(fecha.year, fecha.month, fecha.day - 4));
    var d3 = await dataEstadisticaFecha(
        new DateTime(fecha.year, fecha.month, fecha.day - 3));
    var d2 = await dataEstadisticaFecha(
        new DateTime(fecha.year, fecha.month, fecha.day - 2));
    var d1 = await dataEstadisticaFecha(
        new DateTime(fecha.year, fecha.month, fecha.day - 1));
    var d0 = await dataEstadisticaFecha(
        new DateTime(fecha.year, fecha.month, fecha.day - 0));

    var data = [d6, d5, d4, d3, d2, d1, d0];

    var dataSemanal = new charts.Series<OrdinalSales, String>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (OrdinalSales sales, _) => sales.texto,
        measureFn: (OrdinalSales sales, _) => sales.valor,
        data: data,
        labelAccessorFn: (OrdinalSales sales, _) {
          var ret = "";
          if (sales.valor == 0.0) {
            ret = '';
          } else {
            ret = '${sales.valor.toStringAsFixed(1).toString()}';
          }
          return ret;
        });
    listDataSemanal.add(dataSemanal);
    _listaReporteSemanalController.sink.add(listDataSemanal);
  }

  void insertarDataInitDia(DateTime fecha) async {
    List<charts.Series<OrdinalSales, String>> listDataDia = [];

    var data = [
      // await dataEstadisticaDia(
      //     new DateTime(fecha.year, fecha.month, fecha.day, 6)),
      // await dataEstadisticaDia(
      //     new DateTime(fecha.year, fecha.month, fecha.day, 7)),
      await dataEstadisticaDia(
          new DateTime(fecha.year, fecha.month, fecha.day, 8)),
      await dataEstadisticaDia(
          new DateTime(fecha.year, fecha.month, fecha.day, 9)),
      await dataEstadisticaDia(
          new DateTime(fecha.year, fecha.month, fecha.day, 10)),
      await dataEstadisticaDia(
          new DateTime(fecha.year, fecha.month, fecha.day, 11)),
      await dataEstadisticaDia(
          new DateTime(fecha.year, fecha.month, fecha.day, 12)),
      await dataEstadisticaDia(
          new DateTime(fecha.year, fecha.month, fecha.day, 13)),
      await dataEstadisticaDia(
          new DateTime(fecha.year, fecha.month, fecha.day, 14)),
      await dataEstadisticaDia(
          new DateTime(fecha.year, fecha.month, fecha.day, 15)),
      await dataEstadisticaDia(
          new DateTime(fecha.year, fecha.month, fecha.day, 16)),
      await dataEstadisticaDia(
          new DateTime(fecha.year, fecha.month, fecha.day, 17)),
      await dataEstadisticaDia(
          new DateTime(fecha.year, fecha.month, fecha.day, 18))
    ];
    var dataDia = new charts.Series<OrdinalSales, String>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (OrdinalSales sales, _) => sales.texto,
        measureFn: (OrdinalSales sales, _) => sales.valor,
        data: data,
        labelAccessorFn: (OrdinalSales sales, _) {
          var ret = "";
          if (sales.valor == 0) {
            ret = '';
          } else {
            ret = '${sales.valor.toStringAsFixed(0).toString()}';
          }
          return ret;
        });
    listDataDia.add(dataDia);
    _listaReporteDiarioController.sink.add(listDataDia);
  }

  void dispose() {
    _listaReporteSemanalController?.close();
    _listaReporteDiarioController?.close();
  }
}
