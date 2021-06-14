import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/gen/flutterblue.pb.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:suncare/src/bloc/connectivity_bloc.dart';
import 'package:suncare/src/bloc/provider.dart';
import 'package:suncare/src/preferencias/preferencias_usuario.dart';
import 'package:suncare/src/widgets/my_snack_bar.dart';
import 'package:suncare/src/widgets/tab_home.dart';
import 'package:suncare/src/widgets/tab_pacientes.dart';
import 'package:suncare/src/widgets/tab_statistic.dart';
import 'package:suncare/src/widgets/tab_setting.dart';
import 'package:suncare/src/providers/connectivity_provider.dart';
import 'package:suncare/src/utils/utils.dart' as utils;

class HomeDermatologoPage extends StatefulWidget {
  @override
  _HomeDermatologoPageState createState() => _HomeDermatologoPageState();
}

class _HomeDermatologoPageState extends State<HomeDermatologoPage> {
  final PreferenciasUsuario _preferencia = new PreferenciasUsuario();
  final tabs = [Tab_Pacientes(), Tab_Setting()];
  int _currentIndex = 0;

  ConnectivityProvider _connectivityProvider = ConnectivityProvider.instance;
  bool _source = true;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _connectivityProvider.initialize();
    _connectivityProvider.connectivityStream.listen((source) {
      if (mounted) {
        setState(() {
          _source = source;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text('Pacientes'),
      ),
      drawer: _crearMenuUsuario(context),
      bottomNavigationBar: Container(
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: Colors.redAccent,
          items: [
            BottomNavigationBarItem(
                label: 'Pacientes', icon: Icon(Icons.people)),
            // BottomNavigationBarItem(
            //     label: 'Datos', icon: Icon(Icons.analytics)),
            BottomNavigationBarItem(
                label: 'Configuración', icon: Icon(Icons.settings))
          ],
          onTap: _onItemTapped,
        ),
      ),
      body: Stack(children: [
        Container(
          child: tabs[_currentIndex],
        ),
        utils.nostrarInternetAnimated(_source),
      ]),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
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
              Navigator.pushNamed(context, 'perfil_dermatologo');
            },
          ),
          ListTile(
            leading: Icon(Icons.perm_identity, color: Colors.amber[800]),
            title: Text('Solicitudes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, 'solicitudes');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.amber[800]),
            title: Text('Cerrar sesión'),
            onTap: () {
              _showMesssageDialog(context, '¿Desea cerrar sesión?');
              // Navigator.pushNamed(context, 'solicitudes');
            },
          ),
        ],
      ),
    );
  }

  void _mostrarDialogo(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            title: Text('Nivel de  SPF'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                    title: Text('SPF 15'),
                    value: true,
                    onChanged: (value) {
                      print('ss ${value}');
                    }),
                CheckboxListTile(
                    title: Text('SPF 30'),
                    value: true,
                    onChanged: (value) {
                      print('ss ${value}');
                    }),
                CheckboxListTile(
                    title: Text('SPF 50'),
                    value: true,
                    onChanged: (value) {
                      print('ss ${value}');
                    }),
                CheckboxListTile(
                    title: Text('SPF 70'),
                    value: true,
                    onChanged: (value) {
                      print('ss ${value}');
                    }),
                CheckboxListTile(
                    title: Text('SPF 100'),
                    value: true,
                    onChanged: (value) {
                      print('ss ${value}');
                    }),
              ],
            ),
            actions: [
              FlatButton(
                  child: Text('Cancelar'),
                  onPressed: () => Navigator.of(context).pop()),
              FlatButton(child: Text('Aceptar'), onPressed: () {})
            ],
          );
        });
  }

  void _showMesssageDialog(BuildContext context, String message) {
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
                            Navigator.pushReplacementNamed(
                                context, 'home_dermatologo')
                          }),
                  FlatButton(
                    child: Text('Aceptar',
                        style: TextStyle(color: Colors.amber[800])),
                    onPressed: () async {
                      final connectivity =
                          await Connectivity().checkConnectivity();
                      final hasInternet =
                          connectivity != ConnectivityResult.none;
                      if (_source == true && hasInternet) {
                        Navigator.of(ctx)..pop()..pop();
                        _preferencia.cerrarSesion();
                        mostrarSnackBar(
                            Icons.thumb_up, "Sesión finalizada", Colors.amber);
                        Timer(Duration(seconds: 2), () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, 'login', (route) => false);
                        });
                      } else {
                        Navigator.of(ctx)..pop()..pop();
                      }
                    },
                  ),
                ])
          ],
        ),
      ),
    );
  }

  void mostrarSnackBar(IconData icon, String mensaje, Color color) {
    final snackbar = mySnackBar(icon, mensaje, color);
    scaffoldKey.currentState.showSnackBar(snackbar);
  }
}
