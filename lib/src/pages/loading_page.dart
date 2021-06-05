import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:suncare/src/bloc/data_bloc.dart';
import 'package:suncare/src/bloc/provider.dart';
import 'package:suncare/src/models/dermatologo_model.dart';
import 'package:suncare/src/models/paciente_model.dart';
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

  void _validarTipoUsuario() async {
    Timer(Duration(seconds: 2), () async {
      if (_preferencia.userTipoDB == "paciente") {
        // if (primeraVez == false) {
        //   print('completar paciente');
        //   Navigator.pushReplacementNamed(context, 'perfil');
        // } else {
        //   Navigator.pushReplacementNamed(context, 'home');
        // }
        bool resUser = await consultarPrimeraVezUsuario();
        if (resUser == true) {
          Navigator.pushReplacementNamed(context, 'home');
        } else {
          Navigator.pushReplacementNamed(context, 'perfil');
        }
      } else if (_preferencia.userTipoDB == "dermatologo") {
        // if (primeraVez == false) {
        //   print('completar dermatologo');
        //   Navigator.pushReplacementNamed(context, 'perfil_dermatologo');
        // } else {
        //   Navigator.pushReplacementNamed(context, 'home_dermatologo');
        // }
        bool resDerm = await consultarPrimeraVezDermatologo();
        if (resDerm == true) {
          Navigator.pushReplacementNamed(context, 'home_dermatologo');
        } else {
          Navigator.pushReplacementNamed(context, 'perfil_dermatologo');
        }
      } else {
        Navigator.pushReplacementNamed(context, 'login');
      }
    });
  }

  Future<bool> consultarPrimeraVezUsuario() async {
    final CollectionReference pacientes =
        FirebaseFirestore.instance.collection('usuarios');
    var id = _preferencia.userIdDB;
    var snapshot = await pacientes.doc(id).get();
    var user = PacienteModel.fromJson(snapshot.data());

    return user.first;
  }

  Future<bool> consultarPrimeraVezDermatologo() async {
    final CollectionReference dermatologos =
        FirebaseFirestore.instance.collection('dermatologos');
    var id = _preferencia.userIdDB;
    var snapshot = await dermatologos.doc(id).get();
    var derm = DermatologoModel.fromJson(snapshot.data());

    return derm.first;
  }
}
