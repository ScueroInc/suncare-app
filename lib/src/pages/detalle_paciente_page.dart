import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:suncare/src/bloc/connectivity_bloc.dart';
import 'package:suncare/src/bloc/mensaje_bloc.dart';
import 'package:suncare/src/bloc/paciente_bloc.dart';
import 'package:suncare/src/bloc/provider.dart';
import 'package:suncare/src/models/paciente_model.dart';
import 'package:suncare/src/models/solicitud_model.dart';
import 'package:suncare/src/providers/connectivity_provider.dart';
import 'package:suncare/src/widgets/my_snack_bar.dart';
import 'package:suncare/src/utils/utils.dart' as utils;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:suncare/src/widgets/tab_statistic.dart';

class DetallePacientePage extends StatelessWidget {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  ConnectivityBloc _connectivityBloc;
  PacienteBloc _pacienteBloc;
  DermatologoBloc _dermatologoBloc;
  PacienteModel pacienteArgument;
  MensajesBloc _mensajesBloc;
  String miMensaje = '';
  Size size;
  bool showAuxError = false;
  ConnectivityProvider _connectivityProvider;
  @override
  Widget build(BuildContext context) {
    _connectivityBloc = Provider.of_ConnectivityBloc(context);
    _pacienteBloc = Provider.of_PacienteBloc(context);
    _dermatologoBloc = Provider.of_DermatologoBloc(context);
    _mensajesBloc = Provider.of_MensajeBloc(context);
    _connectivityProvider = ConnectivityProvider.instance;
    size = MediaQuery.of(context).size;

    pacienteArgument = ModalRoute.of(context).settings.arguments;

    if (_connectivityBloc.conectividad == false) {
      showAuxError = true;
    } else {
      _dermatologoBloc.insertarDataInitSemanal(
          new DateTime.now(), pacienteArgument.id);
    }

    print(pacienteArgument.id);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text('Detalle semanal'),
      ),
      //body: contenido(),
      body: Stack(
        children: [
          // (showAuxError == false) ? contenido() : null,
          contenido(),
          StreamBuilder(
            stream: _connectivityProvider.connectivityStream,
            initialData: true,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              var isConnected = snapshot.data;
              if (isConnected != null) {
                _connectivityProvider.setShowError(isConnected);
              }
              return utils
                  .mostrarInternetConexionWithStream(_connectivityProvider);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.message),
          backgroundColor: Colors.amber,
          //onPressed: () => crearMensaje(context, _mensajesBloc)),
          onPressed: () => Navigator.pushNamed(context, 'mensaje_dermatologo',
              arguments: pacienteArgument.id)),
    );
  }

  Widget contenido() {
    if (_connectivityBloc.conectividad == false) {
      pacienteArgument = PacienteModel();
    }
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20.0),
        width: size.width,
        child: Column(
          children: [
            Container(
              width: size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 3.0,
                      offset: Offset(0.0, 5.0),
                      spreadRadius: 3.0),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      '${pacienteArgument.nombre}',
                      style: TextStyle(fontSize: 20),
                    ),
                    subtitle: Text('Nombre'),
                  ),
                  ListTile(
                    title: Text(
                      '${pacienteArgument.apellido}',
                      style: TextStyle(fontSize: 20),
                    ),
                    subtitle: Text('Apellidos'),
                  ),
                  ListTile(
                    title: Text(
                      '${pacienteArgument.miEdad()}',
                      style: TextStyle(fontSize: 20),
                    ),
                    subtitle: Text('Edad'),
                  ),
                  Row(children: [
                    SizedBox(width: 18),
                    Text(
                      '${pacienteArgument.tipoPiel}',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(width: 50),
                    Container(
                      width: 18,
                      height: 18,
                      color: _tipoColorPiel(pacienteArgument.tipoPiel, 1),
                    ),
                    Container(
                      width: 18,
                      height: 18,
                      color: _tipoColorPiel(pacienteArgument.tipoPiel, 2),
                    ),
                    Container(
                      width: 18,
                      height: 18,
                      color: _tipoColorPiel(pacienteArgument.tipoPiel, 3),
                    ),
                    Container(
                      width: 18,
                      height: 18,
                      color: _tipoColorPiel(pacienteArgument.tipoPiel, 4),
                    )
                  ]),
                  Row(
                    children: [
                      SizedBox(width: 18),
                      Text('Tipo de piel',
                          style: TextStyle(color: Colors.black54))
                    ],
                  ),
                  SizedBox(height: 18)
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Evolución',
              style: TextStyle(fontSize: 35),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 3.0,
                      offset: Offset(0.0, 5.0),
                      spreadRadius: 3.0),
                ],
              ),
              width: size.width,
              // height: size.height * 0.62,
              child: _RadiacionUVSemana(size, true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _RadiacionUVSemana(Size size, bool animate) {
    if (_connectivityBloc.conectividad == false) {
      pacienteArgument = PacienteModel();
    }

    return StreamBuilder(
      stream: _dermatologoBloc.listaReporteSemanalStream,
      // initialData: initialData ,
      builder: (BuildContext context,
          AsyncSnapshot<List<charts.Series<OrdinalSales, String>>> snapshot) {
        if (snapshot.hasData) {
          var list = snapshot.data;

          return Column(
            children: [
              Container(
                padding: EdgeInsets.all(20.0),
                width: double.infinity,
                child: FutureBuilder(
                  future:
                      _dermatologoBloc.dataTipoPielFuture(pacienteArgument.id),
                  initialData: "",
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                          // color: Colors.red,
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
                    height: size.height * 0.20,
                    // color: Colors.red,
                    padding: EdgeInsets.only(left: 5),
                    child: RotatedBox(
                      quarterTurns: -1,
                      child: Text("Dosis acumulada (J/m²)",
                          textAlign: TextAlign.center),
                    ),
                  ),
                  Container(
                    // color: Colors.amber,
                    width: size.width * 0.80,
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
              Text('Días')
            ],
          );
        } else {
          return Container();
        }
      },
    );
  }

  void crearMensaje(BuildContext context, MensajesBloc bloc) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            title: Text('Nuevo Mensaje'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: 160,
                  child: TextFormField(
                    initialValue: miMensaje,
                    minLines: 5,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      icon: Icon(Icons.mail),
                      border: InputBorder.none,
                      hintText: 'Mensaje',
                    ),
                    onChanged: (value) => miMensaje = value,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FlatButton(
                        child: Text('Cancelar',
                            style: TextStyle(color: Colors.amber[800])),
                        onPressed: () => Navigator.of(context).pop()),
                    FlatButton(
                        child: Text('Enviar',
                            style: TextStyle(color: Colors.amber[800])),
                        onPressed: () async {
                          bool respuesta = await _dermatologoBloc.crearMensaje(
                              pacienteArgument.id, miMensaje);
                          if (respuesta) {
                            mostrarSnackBar(Icons.thumb_up, 'Mensaje enviado',
                                Colors.amber);
                            Navigator.pushReplacementNamed(
                                context, 'mensaje_dermatologo');
                          } else {
                            mostrarSnackBar(
                                Icons.error, 'Ocurrió un error', Colors.red);
                          }
                        })
                  ],
                )
              ],
            ),
          );
        });
  }

  void mostrarSnackBar(IconData icon, String mensaje, Color color) {
    final snackbar = mySnackBar(icon, mensaje, color);
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  Color _tipoColorPiel(String tipo, int tono) {
    Color color;

    switch (tipo) {
      case 'Tipo I':
        if (tono == 1) {
          color = Color(0xfff1dfd1);
        } else if (tono == 2) {
          color = Color(0xffeedacd);
        } else if (tono == 3) {
          color = Color(0xffe5cdbf);
        } else if (tono == 4) {
          color = Color(0xffe3c6b3);
        }
        break;
      case 'Tipo II':
        if (tono == 1) {
          color = Color(0xffe8d5c6);
        } else if (tono == 2) {
          color = Color(0xffedd1b9);
        } else if (tono == 3) {
          color = Color(0xffebc4a9);
        } else if (tono == 4) {
          color = Color(0xffddb191);
        }
        break;
      case 'Tipo III':
        if (tono == 1) {
          color = Color(0xffead4c0);
        } else if (tono == 2) {
          color = Color(0xffe7c8a6);
        } else if (tono == 3) {
          color = Color(0xffe8c79b);
        } else if (tono == 4) {
          color = Color(0xffdeb67f);
        }
        break;
      case 'Tipo IV':
        if (tono == 1) {
          color = Color(0xffe1c5b1);
        } else if (tono == 2) {
          color = Color(0xffddb798);
        } else if (tono == 3) {
          color = Color(0xffd0a37c);
        } else if (tono == 4) {
          color = Color(0xffca9165);
        }
        break;
      case 'Tipo V':
        if (tono == 1) {
          color = Color(0xffc2ab96);
        } else if (tono == 2) {
          color = Color(0xffbca085);
        } else if (tono == 3) {
          color = Color(0xffa98462);
        } else if (tono == 4) {
          color = Color(0xff8f653c);
        }
        break;
      case 'Tipo VI':
        if (tono == 1) {
          color = Color(0xffb29a8f);
        } else if (tono == 2) {
          color = Color(0xff9f8373);
        } else if (tono == 3) {
          color = Color(0xff8c6654);
        } else if (tono == 4) {
          color = Color(0xff724c34);
        }
        break;
      default:
    }
    return color;
  }
}
