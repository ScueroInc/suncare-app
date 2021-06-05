import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:suncare/src/animated/FadeAnimation.dart';
import 'package:suncare/src/bloc/connectivity_bloc.dart';
import 'package:suncare/src/bloc/provider.dart';
import 'package:suncare/src/preferencias/preferencias_usuario.dart';
import 'package:suncare/src/providers/connectivity_provider.dart';
import 'package:suncare/src/providers/usuario_provider.dart';
import 'package:suncare/src/utils/utils.dart' as utils;
import 'package:suncare/src/widgets/my_snack_bar.dart';

class LoginPage extends StatelessWidget {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // body: Center(
      //   child: Text('login app'),
      // ),
      key: scaffoldKey,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            FadeAnimation(
                1,
                Container(
                  height: size.height * 0.43,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/img/FondoInicio4.png'),
                          fit: BoxFit.fill)),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                          child: Container(
                        child: Center(
                          child: Text(
                            "Iniciar sesión",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ))
                    ],
                  ),
                )),
            Padding(
              //padding: EdgeInsets.all(30.0),
              padding: EdgeInsets.only(right: 30, left: 30, top: 10),
              child: _ContentLogin(scaffoldKey),
            )
          ],
        ),
      ),
    );
  }
}

class _ContentLogin extends StatelessWidget {
  final PreferenciasUsuario _preferencia = new PreferenciasUsuario();

  final UsuarioProvider usuarioProvider = new UsuarioProvider();
  final GlobalKey<ScaffoldState> scaffoldKey;

  _ContentLogin(this.scaffoldKey);

  ConnectivityBloc _connectivityBloc;
  ConnectivityProvider _connectivityProvider = ConnectivityProvider.instance;

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of(context);
    final size = MediaQuery.of(context).size;

    _connectivityBloc = Provider.of_ConnectivityBloc(context);

    return Column(
      children: <Widget>[
        // utils.mostrarInternetConexionAnimatedWithStream(_connectivityProvider),
        utils.nostrarInternetErrorStream(_connectivityBloc),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Color.fromRGBO(143, 148, 251, .2),
                    blurRadius: 20.0,
                    offset: Offset(0, 10))
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              _CrearEmail(bloc),
              _CrearPassword(bloc),
            ],
          ),
        ),
        SizedBox(
          height: 30,
        ),

        _crearBoton(bloc),
        // Container(
        //     height: 50,
        //     decoration: BoxDecoration(
        //       gradient: LinearGradient(
        //         colors: [
        //           Color.fromRGBO(143, 148, 251, 1),
        //           Color.fromRGBO(143, 148, 251, 6),
        //         ],
        //         begin: Alignment.topLeft,
        //         end: Alignment(0.8, 0.0),
        //         // 10% of the width, so there are ten blinds.
        //       ),
        //     ),
        //     child: Center(
        //       child: Text(
        //         "Iniciar Sesion",
        //         style:
        //             TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        //       ),
        //     )),
        SizedBox(
          height: 20,
        ),
        FlatButton(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onPressed: () {
            bloc.changeEmail('');
            bloc.changePassword('');
            Navigator.pushReplacementNamed(context, 'registro');
          },
          child: Text('Crear una cuenta',
              style: TextStyle(
                color: Color.fromRGBO(255, 191, 57, 1),
              )),
        ),

        FlatButton(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onPressed: () {
            bloc.changeEmail('');
            bloc.changePassword('');
            Navigator.pushReplacementNamed(context, 'recuperarContraseña');
          },
          child: Text('Olvidé mi contraseña',
              style: TextStyle(
                color: Color.fromRGBO(255, 191, 57, 1),
              )),
        ),
      ],
    );
  }

  Widget _CrearEmail(LoginBloc bloc) {
    return StreamBuilder(
      stream: bloc.emailStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[100]))),
            child: TextField(
              decoration: InputDecoration(
                  icon: Icon(Icons.alternate_email, color: Colors.amber[300]),
                  border: InputBorder.none,
                  hintText: "Ingrese su correo",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  errorText: snapshot.error),
              onChanged: (value) => bloc.changeEmail(value),
            ));
      },
    );
  }

  Widget _CrearPassword(LoginBloc bloc) {
    return StreamBuilder(
      stream: bloc.passwordStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Container(
          child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[100]))),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                    icon: Icon(Icons.lock_outline, color: Colors.amber[300]),
                    border: InputBorder.none,
                    hintText: "Contraseña",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    errorText: snapshot.error),
                onChanged: (value) => bloc.changePassword(value),
              )),
        );
      },
    );

    // return Container(
    //     padding: EdgeInsets.all(8.0),
    //     decoration: BoxDecoration(
    //         border: Border(bottom: BorderSide(color: Colors.grey[100]))),
    //     child: TextField(
    //       decoration: InputDecoration(
    //           border: InputBorder.none,
    //           hintText: "Contraseña",
    //           hintStyle: TextStyle(color: Colors.grey[400])),
    //     ));
  }

  Widget _crearBoton(LoginBloc bloc) {
    return StreamBuilder(
        stream: bloc.formValidStream,
        builder: (BuildContext context, AsyncSnapshot snapshotform) {
          return StreamBuilder<Object>(
              stream: _connectivityProvider.connectivityStream,
              initialData: true,
              builder: (context, snapshot) {
                var isConnected = snapshot.data;
                print('lililili $isConnected');
                if (isConnected != null) {
                  if (isConnected == true) {
                    print('lililili 2 $isConnected');
                    _connectivityProvider.setShowError(true);
                  }
                }
                return RaisedButton(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 80.0, vertical: 15.0),
                    child: Text('Ingresar'),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  elevation: 0.0,
                  color: Color.fromRGBO(255, 191, 57, 1),
                  textColor: Colors.white,
                  onPressed: snapshotform.hasData
                      ? () {
                          if (_connectivityBloc.conectividad == true) {
                            _login(bloc, context);
                          } else {
                            print('_checkStatus else');
                            _connectivityBloc.setErrorStream(true);
                          }
                          // if (isConnected == true) {
                          //   _login(bloc, context);
                          // } else {
                          //   _connectivityProvider.setShowError(false);
                          // }
                        }
                      : null,
                );
              });
        });
  }

  _login(LoginBloc bloc, BuildContext context) async {
    Map informacion = await usuarioProvider.login(bloc.email, bloc.password);
    print(informacion);
    if (informacion['ok']) {
      // Preguntar que tipo de usuario es
      String tipo = await usuarioProvider.tipoUsuario(informacion['localId']);
      String nombreCompleto =
          await usuarioProvider.getNombreUser(informacion['localId'], tipo);
      print(tipo);
      if (tipo == "paciente") {
        print('soy paciente');
        _preferencia.userTipoDB = tipo;
        _preferencia.userNombreDB = nombreCompleto;
        //aqui llamanos a preferencia nombreDB
        Navigator.pushReplacementNamed(context, 'home');
      } else if (tipo == "dermatologo") {
        print('soy dermatologo');
        String estadoSolicitud =
            await usuarioProvider.dermatogoloEsAceptado(informacion['localId']);

        if (estadoSolicitud == 'aceptada') {
          _preferencia.userTipoDB = tipo;
          _preferencia.userNombreDB = nombreCompleto;

          Navigator.pushReplacementNamed(context, 'home_dermatologo');
        } else {
          print('soy un error');
          mostrarSnackBar(Icons.error_outline,
              'Su solicitud aún está siendo procesada', Colors.amber);
        }
      } else {
        print('soy un error');
        mostrarSnackBar(Icons.error_outline,
            'Su solicitud aún está siendo procesada', Colors.amber);
      }
      // Navigator.pushReplacementNamed(context, 'home');

      bloc.changeEmail('');
      bloc.changePassword('');
    } else {
      mostrarSnackBar(
          Icons.error_outline, 'Correo o contraseña no válidos', Colors.amber);
      //mostrarAlerta(context, 'Contraseña o correo no valido');
    }

    // Navigator.pushReplacementNamed(context, 'home');
  }

  void mostrarSnackBar(IconData icon, String mensaje, Color color) {
    final snackbar = mySnackBar(icon, mensaje, color);
    scaffoldKey.currentState.showSnackBar(snackbar);
  }
}
