import 'dart:async';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:slide_countdown_clock/slide_countdown_clock.dart';
import 'package:suncare/src/bloc/data_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:suncare/src/bloc/provider.dart';
import 'package:suncare/src/models/clima_model.dart';

class Tab_Home extends StatefulWidget {
  @override
  _Tab_HomeState createState() => _Tab_HomeState();
}

class _Tab_HomeState extends State<Tab_Home> {
  Position _currentPosition;
  String _currentAddress;

  //StreamSubscription<Position> _positionStream;

  @override
  void dispose() {
   // _positionStream.cancel();
    super.dispose();  
  }
  
  @override
   void didChangeDependencies() {
    super.didChangeDependencies();
    
    //dataCoreBloc = Provider.of_DataCoreBloc(context);
    Timer.periodic(Duration(seconds: 5), (timer) async{
    // _getCurrentLocation2();
     //_currentPosition = await _getCurrentLocation2();
     //_currentAddress = _getAddressFromLatLng2(_currentPosition);
      /* print("location");

      print(_currentPosition.latitude);
      print(_currentPosition.longitude);
      print(_currentAddress);
      print("End location"); */
      //dataCoreBloc.insertarTiempoMaximoYVitaminaD([false, false, false, false,true]);
    }); 

  }
  @override
  void initState() { 
    super.initState();
    _getCurrentLocation2();
  }
 
  void intetoConLocation(){
    //var locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
    /* _positionStream = Geolocator.getPositionStream(desiredAccuracy:LocationAccuracy.high ).listen((Position position) {
      setState(() {
        print(position);
        _currentPosition = position;
      });

      
    }); */
  }

  void showLocation() async {
    try {
      var serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if(serviceEnabled) {
        _getCurrentLocation2();
        print("location");

      print(_currentPosition.latitude);
      print(_currentPosition.longitude);
      print(_currentAddress);
      print("End location");
      } else {
        print("DEcir el uusario que encienda el gps");
        //LocationPermission permission = await Geolocator.requestPermission();
      }
    } catch (e){
      print(e);
    }
  }

 /*  _getCurrentLocation() {
    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        _getAddressFromLatLng();
      });
    }).catchError((e) {
      print(e);
    });
  } */
   /* Future _getCurrentLocation2() async {
    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            forceAndroidLocationManager: true);
      print("esta es position-> ${position}");
      
    } catch(e) {
      position = await Geolocator.getLastKnownPosition();
      print("esta es position si es error-> ${position}");
      print("y este es el error $e");
    }    
      _currentPosition = position;
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);
        
      Placemark place = placemarks[0];

     
        setState(() {
        _currentAddress =
            "${place.locality}, ${place.subAdministrativeArea},${place.country}";
          
        });
     
    //return position;
  }  */
  //// getcurrent anterior
  _getCurrentLocation2() async {
    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            forceAndroidLocationManager: true);
      print("esta es position-> $position");
      
    } catch(e) {
      position = await Geolocator.getLastKnownPosition();
      print("esta es position si es error-> $position");
      print(e);
    }    
     // _currentPosition = position;
     if(mounted){
        setState(() {
          _currentPosition = position;
          _getAddressFromLatLng();
        });
     }
    //return position;
  } 


  _getAddressFromLatLng() async {
    
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = placemarks[0];
      //print("start place");
      //print(place);
      //print("end place");

      setState(() {
        _currentAddress =
            "${place.locality}, ${place.subAdministrativeArea},${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  _getAddressFromLatLng2(Position _currentPosition) async {
    Placemark place;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      place = placemarks[0];
      print("start place");
      print(place);
      print("end place");

      /* setState(() {
        _currentAddress =
            "${place.administrativeArea}, ${place.locality}, ${place.country}";
      }); */
    } catch (e) {
      print(e);
    }
    final address= "${place.administrativeArea}, ${place.locality}, ${place.country}";
    return address;
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
    final dataCoreBloc = Provider.of_DataCoreBloc(context);
    int duracionTotal = 30;
    Duration _duration = Duration(seconds: 10);

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
                  initialData:
                      'https://w7.pngwing.com/pngs/1008/673/png-transparent-weather-forecasting-rain-icon-weather-blue-text-weather-forecasting.png',
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    return FadeInImage(
                      width: 35.0,
                      height: 35.0,
                      placeholder: AssetImage('assets/img/clock.png'),
                      fit: BoxFit.cover,
                      // image: NetworkImage('${snapshot.data}'),
                      image: NetworkImage(
                          'https://w7.pngwing.com/pngs/1008/673/png-transparent-weather-forecasting-rain-icon-weather-blue-text-weather-forecasting.png'),
                    );
                  },
                ),
                StreamBuilder(
                  stream: dataCoreBloc.climaStream,
                  initialData: 00.0,
                  builder:
                      (BuildContext context, AsyncSnapshot<double> snapshot) {
                    return Container(
                      child: Text('${snapshot.data} °  ', 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize:20, color: Color.fromRGBO(143, 148, 251, 6)))
                    );
                  },
                ),
                StreamBuilder(
                  stream: dataCoreBloc.condicionClimaStream,
                  initialData: '',
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    return Container(
                      child: Text('${snapshot.data}', style: TextStyle(fontSize:20)),
                    );
                  },
                )
              ],
            ),
            Divider(),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                      child: Text('$_currentAddress'),
                )
                /* StreamBuilder(
                  stream: dataCoreBloc.lugarClimaStream,
                  initialData: '',
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    // final name = apiLocation();
                    return Container(
                      // child: Text('${snapshot.data}'),
                      child: Text('${snapshot.data}'),
                    );
                  },
                ), */
                /*  StreamBuilder(
                  stream: dataCoreBloc.regionClimaStream,
                  initialData: '',
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    return Container(
                      child: Text('   ${snapshot.data}', style: TextStyle(fontSize:20)),
                    );
                  },
                ), */
              ],
            ),
            Divider(),
            SizedBox(height: 60),
            Column(
              children: [
                Text('Índice de radiación UV', style: TextStyle(fontWeight: FontWeight.bold, fontSize:20, color: Color.fromRGBO(143, 148, 251, 6))),
                SizedBox(height: 5),
                StreamBuilder(
                  stream: dataCoreBloc.uvClimaStream,
                  initialData: 0.0,
                  builder:
                      (BuildContext context, AsyncSnapshot<double> snapshot) {
                    return Container(
                      child: Text('${snapshot.data}', style: TextStyle(fontSize:20)),
                    );
                  },
                )
              ],
            ),
            /* Divider(),
            SizedBox(height: 15),
            Column(
              children: [
                Text('Vitamina D adquirida',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize:20, color: Color.fromRGBO(143, 148, 251, 6))),
                StreamBuilder(
                  stream: dataCoreBloc.vitaminaDClimaStream,
                  initialData: 0.0,
                  builder:
                      (BuildContext context, AsyncSnapshot<double> snapshot) {
                    return Container(
                      child: Text('${snapshot.data.toStringAsFixed(2)} mcg', style: TextStyle(fontSize:20)),
                    );
                  },
                )
              ],
            ), */
            Divider(),
            SizedBox(height: 15),
            Column(
              children: [
                Text('Tiempo de exposición segura restante',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize:20, color: Color.fromRGBO(143, 148, 251, 6))),
                StreamBuilder(
                  stream: dataCoreBloc.tiempoExposicionStream,
                  builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                    return StatefulBuilder(builder: (context, setState) {
                      print('---! ${snapshot.data}  !---');
                      // final duration = Duration(seconds: d);
                      // return SlideCountdownClock(
                      //   duration: Duration(seconds: duracionTotal),
                      // );
                      return (snapshot.data == null)
                          ? Text('  **  **', style: TextStyle(fontSize:20))
                          : Column(
                              children: [
                                Text(' -- ${snapshot.data} --', style: TextStyle(fontSize:20)),
                                SlideCountdownClock(
                                  duration: Duration(seconds: snapshot.data),
                                  onDone: () {},
                                  separator: ':',
                                )
                              ],
                            );
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // void _showMesssageDialog(String message) {
  //   showDialog(
  //     context: context,
  //     builder: (ctx) {
  //       return AlertDialog(
  //         title: Text('Accesos GPS'),
  //         content: Text(message),

  //         actions: [
  //           FlatButton(
  //             child: Text('si'),
  //             onPressed: () {
  //               Navigator.of(ctx).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
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
