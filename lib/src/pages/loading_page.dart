import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:suncare/src/bloc/data_bloc.dart';
import 'package:suncare/src/bloc/provider.dart';
import 'package:suncare/src/preferencias/preferencias_usuario.dart';

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  final PreferenciasUsuario _preferencia = new PreferenciasUsuario();
  DataCoreBloc dataCoreBloc;
  bool primeraVez = false;
  @override
  void initState() {
    super.initState();
    print("primeraVez -> ${_preferencia.primeraVez}");
    print("tipo -> ${_preferencia.userTipoDB}");
    primeraVez = _preferencia.primeraVez;
    print("primeraVez -> $primeraVez");
    _validarTipoUsuario();
  }

  @override
  Widget build(BuildContext context) {
    dataCoreBloc = Provider.of_DataCoreBloc(context); //dash

    dataCoreBloc.insertarTituloPagina('Inicio');
    print("build ");
    return Scaffold(
      // backgroundColor: Color.fromRGBO(143, 148, 251, 6),
      body: Center(
        child: Container(
          child: (primeraVez == false &&
                  _preferencia.userTipoDB == 'paciente' &&
                  _preferencia.userTipoDB == 'dermatologo')
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Necesitar Completar su perfil para empezar',
                      style: TextStyle(color: Colors.black87),
                    ),
                    MaterialButton(
                        child: Text(
                          'Completar Perfil',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.black,
                        shape: StadiumBorder(),
                        elevation: 1,
                        onPressed: () async {
                          if (_preferencia.userTipoDB == "paciente") {
                            Navigator.pushReplacementNamed(context, 'perfil');
                          } else {
                            Navigator.pushReplacementNamed(
                                context, 'perfil_dermatologo');
                          }
                        })
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [CircularProgressIndicator(), Text('cargando')],
                ),
        ),
      ),
    );
  }

  void _validarTipoUsuario() {
    Timer(Duration(seconds: 2), () {
      if (_preferencia.userTipoDB == "paciente") {
        if (primeraVez == false) {
          print('completar paciente');
          Navigator.pushReplacementNamed(context, 'perfil');
        } else {
          Navigator.pushReplacementNamed(context, 'home');
        }
      } else if (_preferencia.userTipoDB == "dermatologo") {
        if (primeraVez == false) {
          print('completar dermatologo');
          Navigator.pushReplacementNamed(context, 'perfil_dermatologo');
        } else {
          Navigator.pushReplacementNamed(context, 'home_dermatologo');
        }
      } else {
        Navigator.pushReplacementNamed(context, 'login');
      }
    });
  }
}
