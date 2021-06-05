import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:slide_countdown_clock/slide_countdown_clock.dart';
import 'package:suncare/src/bloc/connectivity_bloc.dart';
import 'package:suncare/src/bloc/data_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:suncare/src/bloc/provider.dart';
import 'package:suncare/src/models/clima_model.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:permission_handler/permission_handler.dart' as gpsPermition;
import 'package:suncare/src/providers/connectivity_provider.dart';

import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
// import 'package:slide_countdown_clock/slide_countdown_clock.dart';
import 'package:suncare/src/bloc/bluetooth_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class Tab_Home extends StatefulWidget {
  @override
  _Tab_HomeState createState() => _Tab_HomeState();
}

class _Tab_HomeState extends State<Tab_Home> {
  Position _currentPosition;
  String _currentAddress;
  BluetoothBloc _bluetoothBloc;
  Future<String> _futurePosition;
  Future<bool> _futureGpsOn;
  ConnectivityBloc _connectivityBloc;
  // @override
  //  void didChangeDependencies() {
  //   super.didChangeDependencies();

  //   Timer.periodic(Duration(seconds: 5), (timer) async{

  //     //dataCoreBloc.insertarTiempoMaximoYVitaminaD([false, false, false, false,true]);
  //   });

  // }

  @override
  void initState() {
    super.initState();
    _futureGpsOn = gpsIsOn();
    _futurePosition = showLocationFuture();
  }

  Future<String> showLocationFuture() async {
    var serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) {
      _currentPosition = await getPositionFuture();

      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);
      Placemark place = placemarks[0];
      print("start place");
      print(place);
      print("end place");
      print("location");

      _currentAddress =
          "${place.locality}, ${place.subAdministrativeArea}, ${place.country}";

      print(_currentPosition.latitude);
      print(_currentPosition.longitude);
      print(_currentAddress);
      print("End location");
    } else {
      print("DEcir el uusario que encienda el gps");
      //LocationPermission permission = await Geolocator.requestPermission();
    }
    return _currentAddress;
  }

  Future<Position> getPositionFuture() async {
    return await Geolocator.getCurrentPosition();
  }

  Future<bool> gpsIsOn() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<void> apiLocation() async {
    var queryParameters = {
      "lat": _currentPosition.latitude,
      "lon": _currentPosition.longitude,
      "appid": "cc5f74521fb2b42038cd700b0069f9e4"
    };
    var uri = Uri.https(
        "api.openweathermap.org", "/data/2.5/weather", queryParameters);
    // final location = await http.get(
    //     'api.openweathermap.org/data/2.5/weather?lat=${_currentPosition.latitude}&lon=${_currentPosition.longitude}&appid=cc5f74521fb2b42038cd700b0069f9e4');
    final location = await http.get(uri);
    final Map<String, dynamic> decodePosition = json.decode(location.body);
    return decodePosition["name"];
  }

  @override
  Widget build(BuildContext context) {
    this._bluetoothBloc = Provider.of_BluetoothBloc(context);
    _connectivityBloc = Provider.of_ConnectivityBloc(context);
    int duracionTotal = 30;
    Duration _duration = Duration(seconds: 10);

    return FutureBuilder(
        future: _futureGpsOn,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          print("----->>, ${snapshot.data}");
          if (snapshot.hasData) {
            bool isOn = snapshot.data;
            if (isOn == true) {
              return _pantallaDatos(context);
            } else {
              return Stack(
                children: [
                  _showMesssageDialog(
                      context, "Por favor, encienda la ubicación")
                ],
              );
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget _pantallaDatos(BuildContext context) {
    final dataCoreBloc = Provider.of_DataCoreBloc(context);
    return Container(
      padding: EdgeInsets.only(left: 16, top: 25, right: 16),
      child: Container(
        child: ListView(
          children: [
            SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StreamBuilder(
                  stream: dataCoreBloc.iconClimaStream,
                  initialData: 'assets/img/clock.png',
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    return FadeInImage(
                      width: 35.0,
                      height: 35.0,
                      placeholder: AssetImage('assets/img/clock.png'),
                      fit: BoxFit.cover,
                      // image: NetworkImage('${snapshot.data}'),
                      image: AssetImage('assets/img/img_default_clima.png'),
                      // image: NetworkImage(
                      //     'https://w7.pngwing.com/pngs/1008/673/png-transparent-weather-forecasting-rain-icon-weather-blue-text-weather-forecasting.png'),
                    );
                  },
                ),
                StreamBuilder(
                  stream: _connectivityBloc.connectivityStream,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.data == true) {
                      dataCoreBloc.insertarDataPrincipal();
                      return StreamBuilder(
                        stream: dataCoreBloc.climaStream,
                        initialData: 00.0,
                        builder: (BuildContext context,
                            AsyncSnapshot<double> snapshot) {
                          print('pipipi 1 ${snapshot.data}');
                          return Container(
                              child: Text('${snapshot.data} °  ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.amber[800])));
                        },
                      );
                    } else {
                      return Text('0.0 °  ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.amber[800]));
                    }
                  },
                ),
                // StreamBuilder(
                //   stream: dataCoreBloc.condicionClimaStream,
                //   initialData: '',
                //   builder:
                //       (BuildContext context, AsyncSnapshot<String> snapshot) {
                //     print('pipipi 2 ${snapshot.data}');
                //     return Container(
                //       child: Text('${snapshot.data}',
                //           style: TextStyle(fontSize: 20)),
                //     );
                //   },
                // )
              ],
            ),
            Divider(),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FutureBuilder(
                    future: _futurePosition,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      print('pipipi ---->> ${snapshot.data}');
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (!snapshot.hasError) {
                          return Text(snapshot.data);
                        }
                      } else {
                        return Row(children: [CircularProgressIndicator()]);
                      }
                    }),
                /* FutureBuilder(
                  future: _futurePosition,
                  builder: (BuildContext context, AsyncSnapshot snapshot){
                    if(snapshot.connectionState == ConnectionState.done){
                      if( !snapshot.hasError ){
                        //print(snapshot.data);
                        return Text('$_currentAddress');
                      }

                    } else {
                      return Row(children: [CircularProgressIndicator()]);
                    }

                  }
                ), */
              ],
            ),
            vistaValidacionSincronizacion(_bluetoothBloc, dataCoreBloc),
          ],
        ),
      ),
    );
  }

  Widget vistaValidacionSincronizacion(
      BluetoothBloc _bluetoothBloc, DataCoreBloc dataCoreBloc) {
    return StreamBuilder(
      stream: _bluetoothBloc.deviceStream,
      builder: (BuildContext context, AsyncSnapshot<BluetoothDevice> snapshot) {
        var data = snapshot.data;
        if (data != null) {
          //here_dash
          return Container(
            child: Column(
              children: [
                SizedBox(height: 60),
                Column(
                  children: [
                    Text('Índice de radiación UV',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.amber[800])),
                    SizedBox(height: 5),
                    StreamBuilder(
                      stream: _bluetoothBloc.dataIVStream,
                      initialData: 0.0,
                      builder: (BuildContext context,
                          AsyncSnapshot<double> snapshot) {
                        return Container(
                          child: Text('${snapshot.data}',
                              style: TextStyle(fontSize: 20)),
                        );
                      },
                    )
                  ],
                ),
                Divider(),
                SizedBox(height: 15),
                Column(
                  children: [
                    Text('Tiempo seguro de exposición',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.amber[800])),
                    StreamBuilder(
                      stream: _bluetoothBloc.dataTiempoAnteriorStream,
                      initialData: 0.0,
                      builder: (BuildContext context,
                          AsyncSnapshot<double> snapshot) {
                        double tiempo = snapshot.data;
                        var t = "--";
                        if (tiempo.toInt() > 0) {
                          t = "${tiempo.toInt()} minutos";
                        }
                        return Container(
                          child: Text('${t} ', style: TextStyle(fontSize: 20)),
                        );
                      },
                    ),
                  ],
                ),
                Divider(),
                SizedBox(height: 15),
                Column(
                  children: [
                    Text('Tiempo restante de exposición segura ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.amber[800])),
                    StreamBuilder(
                      stream: _bluetoothBloc.dataTiempoStream,
                      initialData: 0.0,
                      builder: (BuildContext context,
                          AsyncSnapshot<double> snapshot) {
                        return StatefulBuilder(builder: (context, setState) {
                          double tiempo = snapshot.data;

                          if (_bluetoothBloc.lastIV == 0) {
                            return Container(
                              child:
                                  Text('Pausa', style: TextStyle(fontSize: 20)),
                            );
                          } else {
                            var t = DateTime.now().millisecondsSinceEpoch +
                                1000 * 60 * tiempo;
                            print('+dashh $t');

                            return CountdownTimer(
                              endTime: t.toInt(),
                              widgetBuilder: (_, CurrentRemainingTime time) {
                                if (time == null) {
                                  return Text('00:00:00',
                                      style: TextStyle(fontSize: 20));
                                }
                                var dia = "";
                                if (time.days != null) {
                                  dia = "${time.days} dias";
                                }
                                String hora = "00";
                                if (time.hours != null) {
                                  hora = "${time.hours}";
                                }
                                print(
                                    "raaaa dia $dia - hora $hora - min ${time.min} - sec ${time.sec}");
                                if (dia == "" &&
                                    hora == "00" &&
                                    time.min == 20 &&
                                    time.sec == 0) {
                                  //llamar serviciod
                                  _bluetoothBloc.sendAlertaTiempo("20");
                                }

                                if (dia == "" &&
                                    hora == "00" &&
                                    time.min == 0 &&
                                    time.sec == 0) {
                                  print("raaaa IF");
                                  //llamar servicio
                                  _bluetoothBloc.sendAlertaTiempo("0");
                                }
                                return Text(
                                  '${dia}  ${hora} : ${time.min} : ${time.sec} ',
                                  style: TextStyle(fontSize: 20),
                                );
                              },
                            );
                          }
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        } else {
          return Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                SizedBox(height: 85),
                Text('Primero debe sincronizar un wearable'),
                MaterialButton(
                    child: Text(
                      'Sincronizar',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.amber[800],
                    shape: StadiumBorder(),
                    elevation: 1,
                    onPressed: () async {
                      Navigator.pushNamed(context, 'bluetooth');
                    })
              ]));
        }
      },
    );
  }

  Widget _showMesssageDialog(BuildContext context, String message) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: 20),
          Container(
            child: Text(message, textAlign: TextAlign.center),
          ),
          SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            FlatButton(
              child:
                  Text('Aceptar', style: TextStyle(color: Colors.amber[800])),
              onPressed: () async {
                final status = await Permission.location.request();
                accesoGPS(status);
                Navigator.popAndPushNamed(context, 'home');
              },
            ),
          ])
        ],
      ),
    );
  }

  void accesoGPS(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        // navegar
        break;
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
      case PermissionStatus.permanentlyDenied:
        gpsPermition.openAppSettings();
        break;
      case PermissionStatus.undetermined:
        break;
      case PermissionStatus.limited:
        break;
    }
  }
}

// Widget _vistaHome(DataCoreBloc dataCoreBloc) {
//   return Container(
//       padding: EdgeInsets.only(left: 16, top: 25, right: 16),
//       child: Container(
//         child: ListView(
//           children: [
//             // Center(child: Text('Inicio')),
//             Divider(),
//             Row(
//               children: [
//                 StreamBuilder(
//                   stream: dataCoreBloc.iconClimaStream,
//                   initialData:
//                       'https://w7.pngwing.com/pngs/1008/673/png-transparent-weather-forecasting-rain-icon-weather-blue-text-weather-forecasting.png',
//                   builder:
//                       (BuildContext context, AsyncSnapshot<String> snapshot) {
//                     print('sssssss');
//                     print(snapshot.data);
//                     return FadeInImage(
//                       width: 35.0,
//                       height: 35.0,
//                       placeholder: AssetImage('assets/img/clock.png'),
//                       fit: BoxFit.cover,
//                       // image: NetworkImage('${snapshot.data}'),
//                       image: NetworkImage(
//                           'https://w7.pngwing.com/pngs/1008/673/png-transparent-weather-forecasting-rain-icon-weather-blue-text-weather-forecasting.png'),
//                     );
//                   },
//                 ),
//                 StreamBuilder(
//                   stream: dataCoreBloc.climaStream,
//                   initialData: 00.0,
//                   builder:
//                       (BuildContext context, AsyncSnapshot<double> snapshot) {
//                     return Container(
//                       child: Text('${snapshot.data} °  '),
//                     );
//                   },
//                 ),
//                 StreamBuilder(
//                   stream: dataCoreBloc.condicionClimaStream,
//                   initialData: '',
//                   builder:
//                       (BuildContext context, AsyncSnapshot<String> snapshot) {
//                     return Container(
//                       child: Text('${snapshot.data}'),
//                     );
//                   },
//                 )
//               ],
//             ),
//             Divider(),
//             Center(
//               child: StreamBuilder(
//                 stream: dataCoreBloc.lugarClimaStream,
//                 initialData: '',
//                 builder:
//                     (BuildContext context, AsyncSnapshot<String> snapshot) {
//                   return Container(
//                     child: Text('${snapshot.data}'),
//                   );
//                 },
//               ),
//             ),
//             Divider(),
//             SizedBox(height: 10),
//             Column(
//               children: [
//                 Text('Radiación Uv'),
//                 StreamBuilder(
//                   stream: dataCoreBloc.uvClimaStream,
//                   initialData: 0.0,
//                   builder:
//                       (BuildContext context, AsyncSnapshot<double> snapshot) {
//                     return Container(
//                       child: Text('${snapshot.data}'),
//                     );
//                   },
//                 )
//               ],
//             ),
//             Divider(),
//             SizedBox(height: 10),
//             Column(
//               children: [
//                 Text('Vitamina D adquirida'),
//                 StreamBuilder(
//                   stream: dataCoreBloc.uvClimaStream,
//                   initialData: 0.0,
//                   builder:
//                       (BuildContext context, AsyncSnapshot<double> snapshot) {
//                     return Container(
//                       child: Text('${snapshot.data} mcg'),
//                     );
//                   },
//                 )
//               ],
//             ),
//             Divider(),
//             SizedBox(height: 10),
//             Column(
//               children: [
//                 Text('Máxima radiación UV en'),
//                 StreamBuilder(
//                   stream: dataCoreBloc.tiempoExposicionStream,
//                   builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
//                     return StatefulBuilder(builder: (context, setState) {
//                       setState(() {
//                         // duracionTotal = 5;
//                       });
//                       final d = snapshot.data ?? 5;
//                       final duration = Duration(seconds: d);
//                       return SlideCountdownClock(
//                         duration: duration,
//                       );
//                     });
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ));
// }

Future<int> getData() async {
  final respuesta = await http.get('https://reqres.in/api/users');
  final Map<String, dynamic> decodeData = json.decode(respuesta.body);

  return decodeData["total"];
}

Future<ReqResRespuesta2> getData3() async {
  final _key = 'b735988ad9msh4e73a3878b2a467p1b1acajsne46f109f4ca8';
  final _urlBase = 'https://weatherapi-com.p.rapidapi.com';
  final _endPoint = 'forecast.json';

  final respuesta = await http.get(
      'https://weatherapi-com.p.rapidapi.com/current.json?q=Peru&lang=ES',
      headers: {
        "x-rapidapi-key": 'b735988ad9msh4e73a3878b2a467p1b1acajsne46f109f4ca8',
        "x-rapidapi-host": "weatherapi-com.p.rapidapi.com",
        "useQueryString": 'true'
      });

  final Map<String, dynamic> decodeData = json.decode(respuesta.body);
  final ReqResRespuesta2 data = new ReqResRespuesta2();
  data.name = decodeData["location"]["name"];
  data.region = decodeData["location"]["region"];
  data.country = decodeData["location"]["country"];
  data.tempC = decodeData["current"]["temp_c"];
  data.tempF = decodeData["current"]["temp_f"];
  data.text = decodeData["current"]["condition"]["text"];
  data.icon =
      "http://${decodeData["current"]["condition"]["icon"].toString().substring(2)}";
  // decodeData["current"]["condition"]["icon"].toString().substring(2);
  print("---> ${data.icon}");
  // data.icon = data.icon.substring(2);
  data.uv = decodeData["current"]["uv"];
  data.humidity = decodeData["current"]["humidity"];
  data.gustMph = decodeData["current"]["gustMph"];
  data.gustKph = decodeData["current"]["gustKph"];

  print(decodeData);
  return data;
}
