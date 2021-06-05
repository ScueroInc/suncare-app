import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:suncare/src/bloc/connectivity_bloc.dart';
import 'package:suncare/src/bloc/provider.dart';
import 'package:suncare/src/preferencias/preferencias_usuario.dart';
import 'package:suncare/src/providers/connectivity_provider.dart';
import 'package:suncare/src/utils/utils.dart' as utils;

class AdministrarCuenta extends StatefulWidget {
  @override
  _AdministrarCuentaState createState() => _AdministrarCuentaState();
}

class _AdministrarCuentaState extends State<AdministrarCuenta> {
  final PreferenciasUsuario _preferencia = new PreferenciasUsuario();

  Map _source = {ConnectivityResult.wifi: true};
  ConnectivityProvider _connectivityProvider = ConnectivityProvider.instance;
  bool isConnected = true;
  ConnectivityBloc _connectivityBloc;

  @override
  void initState() {
    super.initState();
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
    _connectivityBloc = Provider.of_ConnectivityBloc(context);
    switch (_source.keys.toList()[0]) {
      case ConnectivityResult.mobile:
      case ConnectivityResult.wifi:
        isConnected = true;
    }

    return SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: Colors.amber,
              title: Text('Administrar cuenta'),
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    // if (_preferencia.primeraVez)
                    // Navigator.pushNamed(context, 'home');
                    _preferencia.userTipoDB == 'paciente'
                        ? Navigator.pushNamed(context, 'home')
                        : Navigator.pushNamed(context, 'home_dermatologo');
                  }),
            ),
            body: Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(15.0),
                  child: _listaOpciones(context),
                ),
                // mostrarInternetConexion(isConnected)
                utils.nostrarInternetErrorStream(_connectivityBloc)
              ],
            )));
  }

  _listaOpciones(BuildContext context) {
    // final dataCoreBloc = Provider.of_DataCoreBloc(context);

    return Column(
      children: [
        Card(
          child: ListTile(
            title: Text('Desactivar cuenta'),
            onTap: () {
              _showMesssageDialog(
                  '¿Está seguro de que desea deshabilitar su cuenta?');
              // Navigator.pushReplacementNamed(context, 'perfil');
              // dataCoreBloc.insertarTiempoMaximo(30);
            },
          ),
        )
      ],
    );
  }

  void _showMesssageDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
          title: Text('Deshabilitar cuenta', textAlign: TextAlign.center),
          content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  FlatButton(
                    child:
                        Text('No', style: TextStyle(color: Colors.amber[800])),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                  ),
                  FlatButton(
                    child:
                        Text('Sí', style: TextStyle(color: Colors.amber[800])),
                    onPressed: () async {
                      // switch (_source.keys.toList()[0]) {
                      //   case ConnectivityResult.none:
                      //     setState(() {
                      //       isConnected = false;
                      //     });

                      //     break;
                      //   case ConnectivityResult.mobile:
                      //   case ConnectivityResult.wifi:
                      //     setState(() {
                      //       isConnected = true;
                      //     });
                      // }
                      // if (_source.keys.toList()[0] != ConnectivityResult.none) {
                      //   _preferencia.suspenderCuenta(_preferencia.token);
                      //   Navigator.of(ctx).pop();
                      //   Navigator.pushReplacementNamed(context, 'login');
                      // }
                      if (_connectivityBloc.conectividad == true) {
                        await _preferencia.suspenderCuenta(_preferencia.token);
                        Navigator.of(ctx).pop();
                        Navigator.pushReplacementNamed(context, 'login');
                      } else {
                        print('_checkStatus else administrarCuenta');
                        Navigator.of(ctx).pop();
                        _connectivityBloc.setErrorStream(true);
                      }
                    },
                  )
                ])
          ])),
    );
  }

  Widget mostrarInternetConexion(bool isConnected) {
    return Positioned(
      right: 0,
      left: 0,
      top: 0,
      height: 24,
      child: AnimatedContainer(
          curve: Curves.easeInBack,
          duration: Duration(milliseconds: 1000),
          color: isConnected ? null : Colors.black38,
          child: isConnected
              ? null
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text("Error de conexión a Internet")],
                )),
    );
  }
}
