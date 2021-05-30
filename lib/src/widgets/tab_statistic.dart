import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class Tab_Statistic extends StatelessWidget {
  TextEditingController _inputFieldDateController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final List<charts.Series> seriesList = _createSampleData();
    final bool animate = false;

    return Center(
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
        children: [
          _Title(context, size),
          _RadiacionUV(size, seriesList, animate),
          _VitaminaD(size, seriesList, true)
        ],
      ),
    );
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

  Widget _RadiacionUV(Size size, List<charts.Series> seriesList, bool animate) {
    return Container(
      height: size.height * 0.30,
      child: Center(
        child: charts.BarChart(
          seriesList,
          animate: animate,
        ),
      ),
    );
  }

  Widget _VitaminaD(Size size, List<charts.Series> seriesList, bool animate) {
    return Container(
      height: size.height * 0.30,
      child: Center(
        child: charts.BarChart(
          seriesList,
          animate: animate,
        ),
      ),
    );
  }

  static List<charts.Series<OrdinalSales, String>> _createSampleData() {
    final data = [
      new OrdinalSales('L', 50),
      new OrdinalSales('M', 40),
      new OrdinalSales('M', 65),
      new OrdinalSales('J', 55),
      new OrdinalSales('V', 15),
      new OrdinalSales('S', 25),
      new OrdinalSales('D', 100),
    ];

    return [
      new charts.Series<OrdinalSales, String>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: data,
      )
    ];
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
    }
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}
