import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:suncare/src/bloc/bluetooth_bloc.dart';
import 'package:suncare/src/bloc/connectivity_bloc.dart';
import 'package:suncare/src/bloc/datos_estadisticos.dart';
import 'package:suncare/src/bloc/provider.dart';

class Tab_Statistic extends StatelessWidget {
  ConnectivityBloc _connectivityBloc;
  BluetoothBloc _bluetoothBloc;
  EstadisticosBloc _estadisticosBloc;
  TextEditingController _inputFieldDateController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _bluetoothBloc = Provider.of_BluetoothBloc(context);
    _connectivityBloc = Provider.of_ConnectivityBloc(context);
    _estadisticosBloc = Provider.of_EstadisticosBloc(context);
    _estadisticosBloc.insertarDataInitSemanal(new DateTime.now());
    _estadisticosBloc.insertarDataInitDia(new DateTime.now());
    // final List<charts.Series> seriesList = _createSampleData(29, 4, 2021);
    final bool animate = false;

    return StreamBuilder(
      stream: _connectivityBloc.connectivityStream,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.data == true) {
          return Center(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              children: [
                _Title(context, size),
                _RadiacionUVSemana(size, animate),
                SizedBox(height: 10),
                _RadiacionUVDia(size, true)
              ],
            ),
          );
        } else {
          return Container();
        }
      },
    );

    // return Center(
    //   child: ListView(
    //     padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
    //     children: [
    //       _Title(context, size),
    //       _RadiacionUVSemana(size, animate),
    //       SizedBox(height: 10),
    //       _RadiacionUVDia(size, true)
    //     ],
    //   ),
    // );
  }

  Widget _Title(BuildContext context, Size size) {
    return Container(
      // color: Colors.red,
      height: size.height * 0.15,
      child: ListView(
        children: [
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: TextField(
                enableInteractiveSelection: false,
                controller: _inputFieldDateController,
                decoration: InputDecoration(
                  icon: Icon(Icons.calendar_today),
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  hintText: 'Busque una fecha',
                  // labelText: 'Ingrese una fecha',
                ),
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  _selectDate(context);
                },
              ),
            ),
          ),
          Divider(
            color: Colors.black54,
          ),
          Center(
            child: Container(
              padding: EdgeInsets.only(top: 15),
              child: Text('¿ Cómo vamos ?'),
            ),
          )
        ],
      ),
    );
  }

  Widget _RadiacionUVSemana(Size size, bool animate) {
    return StreamBuilder(
      stream: _estadisticosBloc.listaReporteSemanalStream,
      // initialData: initialData ,
      builder: (BuildContext context,
          AsyncSnapshot<List<charts.Series<OrdinalSales, String>>> snapshot) {
        if (snapshot.hasData) {
          var list = snapshot.data;
          // List<OrdinalSales> datos = list[0].data;
          // double prom = 0.0;
          // datos.map((OrdinalSales data) {
          //   // prom = prom + (int.parse(data.label) / datos.length);
          // });
          // for (OrdinalSales item in datos) {
          //   double n = double.tryParse(item.label) ?? 0.0;
          //   prom = prom + (n / datos.length);
          // }
          return Column(
            children: [
              Container(
                width: double.infinity,
                child: FutureBuilder(
                  future: _estadisticosBloc.dataTipoPielFuture(),
                  initialData: "",
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                          child: Text("SED = ${snapshot.data} J/m²"));
                    } else {
                      return Text("SED");
                    }
                  },
                ),
              ),
              Row(
                children: [
                  Container(
                    width: size.width * 0.07,
                    height: size.height * 0.25,
                    // color: Colors.red,
                    child: RotatedBox(
                      quarterTurns: -1,
                      child: Text("Dosis acumulada (J/m²)",
                          textAlign: TextAlign.center),
                    ),
                  ),
                  Container(
                    // color: Colors.amber,
                    width: size.width * 0.85,
                    height: size.height * 0.25,
                    child: Center(
                      child: charts.BarChart(
                        list,
                        animate: animate,
                        barRendererDecorator:
                            new charts.BarLabelDecorator<String>(),
                        domainAxis: new charts.OrdinalAxisSpec(),
                      ),
                    ),
                  )
                ],
              ),
              Text("Días")
            ],
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget _RadiacionUVDia(Size size, bool animate) {
    return StreamBuilder(
      stream: _estadisticosBloc.listaReporteDiarioStream,
      // initialData: initialData ,
      builder: (BuildContext context,
          AsyncSnapshot<List<charts.Series<OrdinalSales, String>>> snapshot) {
        if (snapshot.hasData) {
          var list = snapshot.data;

          return Column(
            children: [
              Row(
                children: [
                  Container(
                    width: size.width * 0.07,
                    height: size.height * 0.25,
                    // color: Colors.red,
                    child: RotatedBox(
                      quarterTurns: -1,
                      child: Text("UVI", textAlign: TextAlign.center),
                    ),
                  ),
                  Container(
                    width: size.width * 0.85,
                    height: size.height * 0.25,
                    child: Center(
                      child: charts.BarChart(
                        list,
                        animate: animate,
                        barRendererDecorator:
                            new charts.BarLabelDecorator<String>(),
                        domainAxis: new charts.OrdinalAxisSpec(),
                      ),
                    ),
                  )
                ],
              ),
              Center(
                child: Text("Horas"),
              ),
            ],
          );
        } else {
          return Container();
        }
      },
    );
  }

  _selectDate(BuildContext context) async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(1970),
        lastDate: new DateTime.now(),
        locale: Locale('es', 'ES'));
    if (picked != null) {
      print('la fecha picked es ${picked}');
      String dia = picked.day.toString().padLeft(2, '0');
      String mes = picked.month.toString().padLeft(2, '0');
      String yea = picked.year.toString().padLeft(4, '0');
      _inputFieldDateController.text = '$yea-$mes-$dia';
      _estadisticosBloc.insertarDataInitSemanal(
          DateTime(picked.year, picked.month, picked.day));
      _estadisticosBloc
          .insertarDataInitDia(DateTime(picked.year, picked.month, picked.day));
    }
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  String texto;
  double valor;
  String label;
  OrdinalSales(this.texto, this.valor, {this.label});
}
