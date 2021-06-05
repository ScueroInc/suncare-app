import 'dart:collection';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter_blue/flutter_blue.dart' as blue;
import 'package:connectivity/connectivity.dart';
import 'package:custom_switch/custom_switch.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:suncare/src/bloc/bluetooth_bloc.dart';
import 'package:suncare/src/bloc/connectivity_bloc.dart';
import 'package:suncare/src/bloc/data_bloc.dart';
import 'package:suncare/src/bloc/provider.dart';
import 'package:suncare/src/models/paciente_model.dart';
import 'package:suncare/src/pages/acceso_bluetooth.dart';
import 'package:suncare/src/preferencias/preferencias_usuario.dart';
import 'package:suncare/src/providers/connectivity_provider.dart';
import 'package:suncare/src/providers/data_provider.dart';
import 'package:suncare/src/providers/push_notification_provider.dart';
import 'package:suncare/src/widgets/my_snack_bar.dart';
import 'package:suncare/src/widgets/tab_home.dart';
import 'package:suncare/src/widgets/tab_statistic.dart';
import 'package:suncare/src/widgets/tab_setting.dart';
import 'package:suncare/src/utils/utils.dart' as utils;
// import 'location'
import 'package:permission_handler/permission_handler.dart' as gpsPermition;
//

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final PreferenciasUsuario _preferencia = new PreferenciasUsuario();
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  // Location location = new Location();
  // var permisoGPS;
  bool primeraVez = false;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  PacienteModel paciente = new PacienteModel();
  ConnectivityBloc _connectivityBloc;
  PacienteBloc pacienteBloc;
  DataCoreBloc dataCoreBloc;
  BluetoothBloc _bluetoothBloc;
  String idMedicoVincular = '';
  int index;
  PushNotificationsProvider pushProvider;
  //Map _source = { ConnectivityResult.wifi : true };
  ConnectivityProvider _connectivityProvider = ConnectivityProvider.instance;
  bool _source = true;
  //bool isConnected;
  // DataCoreBloc _dataCoreBloc = Provider.of_DataCoreBloc(context);

  @override
  void initState() {
    // dataCoreBloc = Provider.of_DataCoreBloc(context);
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    pushProvider = new PushNotificationsProvider();
    pushProvider.initNotifications();
    saveTokenDeviceData();

    _connectivityProvider.initialize();
    _connectivityProvider.connectivityStream.listen((source) {
      print("internet $source");
      if (mounted) {
        setState(() {
          _source = source;
        });
      }
    });

    pushProvider.mensajesStream.listen((argumento) {
      print('argumento desde main: |$argumento|');

      if (argumento == "20") {
        print('centro al if de message FIREBASE');
        showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) {
              return AlertDialog(
                title: Text("¡Cuidado!"),
                content:
                    Text("Quedan menos de 20 minutos de exposición segura"),
                actions: [
                  TextButton(
                      child: Text('Ok'),
                      onPressed: () => {Navigator.pop(context)}),
                ],
              );
            });
      }

      if (argumento == "0") {
        print('centro al if de message FIREBASE');
        showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) {
              return AlertDialog(
                title: Text("¡Alerta!"),
                content: Text("El tiempo de exposición ya no es seguro"),
                actions: [
                  TextButton(
                      child: Text('Ok'),
                      onPressed: () => {Navigator.pop(context)}),
                ],
              );
            });
      }
    });

    blue.FlutterBlue.instance.state.listen((event) {
      print('raaaaaa ${event}');
      if (event == blue.BluetoothState.off) {
        print('raaaaaa off desincronizar');
        _bluetoothBloc.insertarEstadoBluetooth(false);
        _bluetoothBloc.desincronizar();
      }
      if (event == blue.BluetoothState.on) {
        print('raaaaaa on');
        _bluetoothBloc.insertarEstadoBluetooth(true);
      }
    });
  }

  saveTokenDeviceData() {
    if (Platform.isIOS) {
      pushProvider.saveDeviceTokenIOS(_preferencia.userIdDB);
    } else {
      print(
          "se guardará el tokeDevice de este user ${_preferencia.userIdDB}, ${_preferencia.userTipoDB}");
      pushProvider.saveDeviceToken(_preferencia.userIdDB);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    dataCoreBloc = Provider.of_DataCoreBloc(context); //dash

    print(_preferencia.token);

    int tiempoBusqueda = 60;
    Timer.periodic(Duration(seconds: tiempoBusqueda), (timer) async {
      var listSPF =
          List<bool>.from(json.decode(_preferencia.spfJson).map((x) => x));
      var device = _bluetoothBloc.lastDevice;

      if (device != null) {
        //here_dash
        print('si hay un dispositivo observando enviando data');
        _bluetoothBloc.insertarIVController(tiempoBusqueda);
      } else {
        print('Ejecutando un servicio cada $tiempoBusqueda seg   ELSE');
      }
    });
  }

  @override
  void didChangeAppLifecycleState(lifecycle) {
    super.didChangeAppLifecycleState(lifecycle);

    // print('Cambio del ciclo de vida del home');
    switch (lifecycle) {
      case AppLifecycleState.inactive:
        // print('xxx-> inactivo');
        break;
      case AppLifecycleState.resumed:
        // print('xxx-> resumed');
        break;
      case AppLifecycleState.paused:
        // print('xxx-> paused');
        break;
      default:
    }
  }

  final tabs = [Tab_Home(), Tab_Statistic(), Tab_Setting()];

  List<bool> _spf;
  // bool _test = false;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final idUser = _preferencia.userIdDB;

    dataCoreBloc = Provider.of_DataCoreBloc(context); //dash
    pacienteBloc = Provider.of_PacienteBloc(context);
    _bluetoothBloc = Provider.of_BluetoothBloc(context);
    pacienteBloc.buscarPaciente(idUser);
    _connectivityProvider = ConnectivityProvider.instance;

    _connectivityBloc = Provider.of_ConnectivityBloc(context);
    // _preferencia.primeraVez = primeraVez;

    if (_preferencia.primeraVez == null) {
      _preferencia.primeraVez = false;
    }
    // print(_preferencia.primeraVez);
    // dataCoreBloc.insertarTituloPagina('Inicio');
    //
    _spf = List<bool>.from(json.decode(_preferencia.spfJson).map((x) => x));
    return FutureBuilder(
      future: Permission.location.isGranted,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator(strokeWidth: 2));
        } else {
          var permisoGPS = snapshot.data;
          if (permisoGPS) {
            return StreamBuilder(
                stream: pacienteBloc.pacienteBuscadoStream,
                builder: (context, snapshot) {
                  paciente = snapshot.data;
                  _preferencia.tipoPiel = paciente.tipoPiel;
                  return vistaNormal(context);
                });
          } else {
            // return vistaNormal(context);
            return _onload(context);
          }
        }
      },
    );
  }

  Widget _onload(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suncare'),
      ),
      body: Center(
        child: AlertDialog(
          title: Text('GPS'),
          content: Text('¿Permitir que SunCare tenga acceso a su ubicación?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Aceptar'),
              onPressed: () async {
                final status = await Permission.location.request();
                accesoGPS(status);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => super.widget));
                // Navigator.of(context).pop();
              },
            ),
          ],
        ),
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

  Widget vistaNormal(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: StreamBuilder(
            stream: dataCoreBloc.tituloPaginaStream,
            initialData: '',
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                return Container(
                  child: Text(snapshot.data),
                );
              }
            },
          ),
          // actions: [
          //   IconButton(
          //     icon: Icon(Icons.edit),
          //     onPressed: () {
          //       // Navigator.pushNamed(context, 'modificarPerfil');
          //     },
          //   ),
          // ],
        ),
        drawer: _crearMenuUsuario(context),
        bottomNavigationBar: Container(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            selectedItemColor: Colors.redAccent,
            items: [
              BottomNavigationBarItem(label: 'Inicio', icon: Icon(Icons.home)),
              BottomNavigationBarItem(
                  label: 'Detalle', icon: Icon(Icons.analytics)),
              BottomNavigationBarItem(
                  label: 'Configuración', icon: Icon(Icons.settings))
            ],
            onTap: _onItemTapped,
          ),
        ),
        body: Stack(
          children: [
            Container(
              child: paciente.tipoPiel != null
                  ? tabs[_currentIndex]
                  : AlertDialog(
                      title: Text('Bienvenido'),
                      content: Text('Modifica tus datos'),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('Ok'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.pushNamed(context, 'modificarPerfil');
                          },
                        )
                      ],
                    ),
            ),
            utils.mostrarInternetConexion(_source)
            /* StreamBuilder(
            stream: _connectivityProvider.connectivityStream ,
            initialData: true,
            builder: (BuildContext context, AsyncSnapshot snapshot){
              var isConnected = snapshot.data;
              if(isConnected != null){
                _connectivityProvider.setShowError(isConnected);
              }
              return utils.mostrarInternetConexionWithStream(_connectivityProvider);
            },
          ), */
          ],
        ));
  }

  Widget vistaPermiso(BuildContext context) {
    return Scaffold(
      body: Text('permiso'),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      switch (index) {
        case 0:
          dataCoreBloc.insertarTituloPagina('Inicio');
          break;
        case 1:
          dataCoreBloc.insertarTituloPagina('Detalle de exposición UV');
          break;
        case 2:
          dataCoreBloc.insertarTituloPagina('Configuración');
          break;
        default:
      }
    });
  }

  Drawer _crearMenuUsuario(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircleAvatar(
                    radius: 25,
                    child: Image(image: AssetImage('assets/img/clock.png')),
                  ),
                  Text(_preferencia.userNombreDB)
                ],
              ),
            ),
            decoration: BoxDecoration(color: Colors.amber),
          ),
          ListTile(
            leading: Icon(Icons.perm_identity, color: Colors.amber[800]),
            title: Text('Perfil'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, 'perfil');
            },
          ),
          ListTile(
            leading: Icon(Icons.message, color: Colors.amber[800]),
            title: Text('Recomendaciones'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, 'mensaje');
            },
          ),
          ListTile(
            leading: Icon(Icons.perm_identity, color: Colors.amber[800]),
            title: Text('Vincular dermatólogo'),
            onTap: () async {
              // await _mostrarVinculacion(context);
              Navigator.pop(context);
              Navigator.pushNamed(context, 'vinculacion');
            },
          ),
          ListTile(
            leading: Icon(Icons.perm_identity, color: Colors.amber[800]),
            title: Text('SPF del bloqueador solar'),
            onTap: () async {
              await _mostrarDialogo(context);
            },
          ),
          // ListTile(
          //   leading: Icon(Icons.checkroom_outlined,
          //       color: Color.fromRGBO(143, 148, 251, 6)),
          //   title: Text('Vestimenta'),
          //   onTap: () {
          //     Navigator.pop(context);
          //     Navigator.pushNamed(context, 'vestimenta');
          //   },
          // ),
          ListTile(
            leading:
                Icon(Icons.center_focus_weak_sharp, color: Colors.amber[800]),
            title: Text('Sincronizar wearable'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, 'bluetooth');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.amber[800]),
            title: Text('Cerrar sesión'),
            onTap: () {
              _showMesssageDialog('Sesión', '¿Desea cerrar sesión?');
            },
          ),
        ],
      ),
    );
  }

  void _mostrarVinculacion(BuildContext context) async {
    await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('Vincular Doctor'),
              content: Container(
                height: 60,
                child: TextField(
                  decoration: InputDecoration(
                      icon:
                          Icon(Icons.local_hospital, color: Colors.deepPurple),
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      hintText: 'CMP'),
                  onChanged: (value) {
                    idMedicoVincular = value;
                  },
                ),
              ),
              actions: [
                // ignore: deprecated_member_use
                FlatButton(
                    child: Text('Cancelar'),
                    onPressed: () => Navigator.of(context).pop()),
                // ignore: deprecated_member_use
                FlatButton(
                    child: Text('Aceptar'),
                    onPressed: () async {
                      print('el valor es de $idMedicoVincular');
                      bool res =
                          await pacienteBloc.vincularMedico(idMedicoVincular);

                      if (res == true) {
                        Navigator.of(context).pop();
                      } else {
                        mostrarSnackBar('Ocurrio un error');
                      }
                    }),
              ],
            );
          });
        });
  }

  void mostrarSnackBar(String mensaje) {
    final snackbar = SnackBar(
      content: Text(mensaje),
      duration: Duration(microseconds: 1500),
    );

    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  void _mostrarDialogo(BuildContext context) async {
    await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Stack(
              children: [
                //utils.mostrarInternetConexion(false),
                AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  title: Text('Nivel de  SPF'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CheckboxListTile(
                          title: Text('SPF 15'),
                          value: _spf[0],
                          onChanged: (value) {
                            setState(() {});
                            _spf = [false, false, false, false, false];
                            _spf[0] = value;
                            index = 0;
                            // print('s15 ${value}');
                          }),
                      CheckboxListTile(
                          title: Text('SPF 30'),
                          value: _spf[1],
                          onChanged: (value) {
                            setState(() {
                              _spf = [false, false, false, false, false];
                              _spf[1] = value;
                              index = 1;
                            });
                            // print('s30 ${value}');
                          }),
                      CheckboxListTile(
                          title: Text('SPF 50'),
                          value: _spf[2],
                          onChanged: (value) {
                            setState(() {
                              _spf = [false, false, false, false, false];
                              _spf[2] = value;
                              index = 2;
                            });
                            // print('s50 ${value}');
                          }),
                      CheckboxListTile(
                          title: Text('SPF 70'),
                          value: _spf[3],
                          onChanged: (value) {
                            setState(() {
                              _spf = [false, false, false, false, false];
                              _spf[3] = value;
                              index = 3;
                            });
                            // print('s70 ${value}');
                          }),
                      CheckboxListTile(
                          title: Text('SPF 100'),
                          value: _spf[4],
                          onChanged: (value) {
                            setState(() {
                              _spf = [false, false, false, false, false];
                              _spf[4] = value;
                              index = 4;
                            });
                            // print('s100 ${value}');
                          }),
                      SizedBox(height: 20),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            FlatButton(
                              child: Text('Cancelar',
                                  style: TextStyle(color: Colors.amber[800])),
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                            ),
                            FlatButton(
                                child: Text('Guardar',
                                    style: TextStyle(color: Colors.amber[800])),
                                onPressed: () {
                                  if (_source == true) {
                                    // guardar en preference
                                    bool isValid = false;
                                    // guarda en firebase
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();

                                    for (var item in _spf) {
                                      isValid = item;
                                      if (isValid) {
                                        break;
                                      }
                                    }

                                    if (_connectivityBloc.conectividad ==
                                        false) {
                                      // NO hay internet
                                      return;
                                    } else {
                                      if (isValid) {
                                        _preferencia.spfJson = _spf;
                                        mostrarSnackBar2(
                                            Icons.thumb_up,
                                            'Cambios guardados con éxito',
                                            Colors.amber);
                                        // _showMesssageDialog('Cambios guardados con éxito');
                                      } else {
                                        setState(() {
                                          _spf[index] = true;
                                        });
                                        mostrarSnackBar2(
                                            Icons.error,
                                            'No olvides aplicarte protector solar',
                                            Colors.amber);
                                        // _showMesssageDialog('Escóge tu nivel de SPF');
                                      }
                                    }
                                  } else {
                                    Navigator.of(context)..pop()..pop();
                                  }
                                  // cerrar ventana
                                })
                          ])
                    ],
                  ),
                ),
              ],
            );
          });
        });
  }

  void mostrarSnackBar2(IconData icon, String mensaje, Color color) {
    final snackbar = mySnackBar(icon, mensaje, color);
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  void _showMesssageDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: 20),
            Container(
              child: Text(message, textAlign: TextAlign.center),
            ),
            SizedBox(height: 20),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FlatButton(
                      child: Text('Cancelar',
                          style: TextStyle(color: Colors.amber[800])),
                      onPressed: () => {
                            Navigator.of(context).pop(),
                            Navigator.pushReplacementNamed(context, 'home')
                          }),
                  FlatButton(
                      child: Text('Aceptar',
                          style: TextStyle(color: Colors.amber[800])),
                      onPressed: () {
                        if (_source == true) {
                          Navigator.of(ctx)..pop()..pop();
                          _preferencia.cerrarSesion();
                          mostrarSnackBar2(Icons.thumb_up, "Sesión finalizada",
                              Colors.amber);
                          Timer(Duration(seconds: 2), () {
                            Navigator.pushNamedAndRemoveUntil(
                                context, 'login', (route) => false);
                          });
                        } else {
                          Navigator.of(ctx)..pop()..pop();
                        }
                      }),
                ])
          ],
        ),
      ),
    );
  }

  void validarPermisosGPS() async {
    var perFPS = await Geolocator.isLocationServiceEnabled();

    print('gps esta $perFPS');

    // return true;
  }

  // void _showMesssageDialog(BuildContext context, String message) {
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       title: SizedBox(height: 3),
  //       content: Text(message),
  //       actions: <Widget>[
  //         FlatButton(
  //           child: Text('Cancelar'),
  //           onPressed: () => Navigator.of(context).pop()),
  //         FlatButton(
  //           child: Text('Aceptar'),
  //           onPressed: () {
  //             Navigator.of(ctx).pop();
  //             _preferencia.cerrarSesion();
  //             Navigator.pushReplacementNamed(context, 'login');
  //           },
  //         )
  //       ],
  //     ),
  //   );
  // }
}
