import 'package:flutter/material.dart';
import 'package:suncare/src/animated/FadeAnimation.dart';
import 'package:suncare/src/bloc/provider.dart';
import 'package:suncare/src/preferencias/preferencias_usuario.dart';
import 'package:suncare/src/providers/usuario_provider.dart';
import 'package:suncare/src/utils/utils.dart';
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
                    height: size.height * 0.40,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/img/background.png'),
                            fit: BoxFit.fill)),
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                            left: 150,
                            width: 80,
                            height: 150,
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image:
                                          AssetImage('assets/img/clock.png'))),
                            )),
                        Positioned(
                            child: Container(
                          child: Center(
                            child: Text(
                              "Iniciar Sesión",
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
                padding: EdgeInsets.all(30.0),
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

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of(context);
    final size = MediaQuery.of(context).size;

    return Column(
      children: <Widget>[
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
          onPressed: () => Navigator.pushReplacementNamed(context, 'registro'),
          child: Text('Crear una cuenta',
              style: TextStyle(
                color: Color.fromRGBO(143, 148, 251, 1),
              )),
        ),

        FlatButton(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onPressed: () =>
              Navigator.pushReplacementNamed(context, 'recuperarContraseña'),
          child: Text('Olvidé mi contraseña',
              style: TextStyle(
                color: Color.fromRGBO(143, 148, 251, 1),
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
                  icon: Icon(Icons.alternate_email, color: Colors.deepPurple),
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
                    icon: Icon(Icons.lock_outline, color: Colors.deepPurple),
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
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return RaisedButton(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 80.0, vertical: 15.0),
              child: Text('Ingresar'),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            elevation: 0.0,
            color: Color.fromRGBO(143, 148, 251, 1),
            textColor: Colors.white,
            onPressed: snapshot.hasData
                ? () {
                    _login(bloc, context);
                    bloc.changeEmail('');
                    bloc.changePassword('');
                  }
                : null,
          );
        });
  }

  _login(LoginBloc bloc, BuildContext context) async {
    Map informacion = await usuarioProvider.login(bloc.email, bloc.password);
    print(informacion);
    if (informacion['ok']) {
      // Preguntar que tipo de usuario es
      String tipo = await usuarioProvider.tipoUsuario(informacion['localId']);
      
      print(tipo);
      if (tipo == "paciente") {
        print('soy paciente');
        _preferencia.userTipoDB = tipo;
        Navigator.pushReplacementNamed(context, 'home');
      } else if (tipo == "dermatologo") {
        print('soy dermatologo');
        String estadoSolicitud = await usuarioProvider.dermatogoloEsAceptado(informacion['localId']);

        if(estadoSolicitud == 'aceptada'){
          _preferencia.userTipoDB = tipo;

          Navigator.pushReplacementNamed(context, 'home_dermatologo');
        }else {
        print('soy un error');
        mostrarSnackBar(Icons.error_outline, 'Su solicitud aún está siendo procesada',Color.fromRGBO(143, 148, 251, 6));
      }
      } else {
        print('soy un error');
        mostrarSnackBar(Icons.error_outline, 'Su solicitud aún está siendo procesada',Color.fromRGBO(143, 148, 251, 6));
      }
      // Navigator.pushReplacementNamed(context, 'home');
    } else {
      mostrarSnackBar(Icons.error_outline, 'Correo o contraseña no válidos',Color.fromRGBO(143, 148, 251, 6));
      //mostrarAlerta(context, 'Contraseña o correo no valido');
    }

    // Navigator.pushReplacementNamed(context, 'home');
  }

  void mostrarSnackBar(IconData icon, String mensaje, Color color) {
    final snackbar = mySnackBar(icon, mensaje, color);
    scaffoldKey.currentState.showSnackBar(snackbar);
  }
  // Widget _loginForm(BuildContext context) {
  //   final bloc = Provider.of(context);
  //   final size = MediaQuery.of(context).size;

  //   return SingleChildScrollView(
  //     child: Column(
  //       children: <Widget>[
  //         SafeArea(
  //           child: Container(
  //             height: 180.0,
  //           ),
  //         ),
  //         Container(
  //           width: size.width * 0.85,
  //           margin: EdgeInsets.symmetric(vertical: 30.0),
  //           padding: EdgeInsets.symmetric(vertical: 50.0),
  //           decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(5.0),
  //               boxShadow: <BoxShadow>[
  //                 BoxShadow(
  //                     color: Colors.black26,
  //                     blurRadius: 3.0,
  //                     offset: Offset(0.0, 5.0),
  //                     spreadRadius: 3.0)
  //               ]),
  //           child: Column(
  //             children: <Widget>[
  //               Text('Ingreso', style: TextStyle(fontSize: 20.0)),
  //               SizedBox(height: 60.0),
  //               _crearEmail(bloc),
  //               SizedBox(height: 30.0),
  //               _crearPassword(bloc),
  //               SizedBox(height: 30.0),
  //               _crearBoton(bloc)
  //             ],
  //           ),
  //         ),
  //         Text('¿Olvido la contraseña?'),
  //         SizedBox(height: 100.0)
  //       ],
  //     ),
  //   );
  // }

  // Widget _crearEmail(LoginBloc bloc) {
  //   return StreamBuilder(
  //     stream: bloc.emailStream,
  //     builder: (BuildContext context, AsyncSnapshot snapshot) {
  //       return Container(
  //         padding: EdgeInsets.symmetric(horizontal: 20.0),
  //         child: TextField(
  //           keyboardType: TextInputType.emailAddress,
  //           decoration: InputDecoration(
  //               icon: Icon(Icons.alternate_email, color: Colors.deepPurple),
  //               hintText: 'ejemplo@correo.com',
  //               labelText: 'Correo electrónico',
  //               counterText: snapshot.data,
  //               errorText: snapshot.error),
  //           onChanged: bloc.changeEmail,
  //         ),
  //       );
  //     },
  //   );
  // }

  // Widget _crearPassword(LoginBloc bloc) {
  //   return StreamBuilder(
  //     stream: bloc.passwordStream,
  //     builder: (BuildContext context, AsyncSnapshot snapshot) {
  //       return Container(
  //         padding: EdgeInsets.symmetric(horizontal: 20.0),
  //         child: TextField(
  //           obscureText: true,
  //           decoration: InputDecoration(
  //               icon: Icon(Icons.lock_outline, color: Colors.deepPurple),
  //               labelText: 'Contraseña',
  //               counterText: snapshot.data,
  //               errorText: snapshot.error),
  //           onChanged: bloc.changePassword,
  //         ),
  //       );
  //     },
  //   );
  // }

  // Widget _crearBoton(LoginBloc bloc) {
  //   // formValidStream
  //   // snapshot.hasData
  //   //  true ? algo si true : algo si false

  //   return StreamBuilder(
  //     stream: bloc.formValidStream,
  //     builder: (BuildContext context, AsyncSnapshot snapshot) {
  //       return RaisedButton(
  //           child: Container(
  //             padding: EdgeInsets.symmetric(horizontal: 80.0, vertical: 15.0),
  //             child: Text('Ingresar'),
  //           ),
  //           shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(5.0)),
  //           elevation: 0.0,
  //           color: Colors.deepPurple,
  //           textColor: Colors.white,
  //           onPressed: snapshot.hasData ? () => _login(bloc, context) : null);
  //     },
  //   );
  // }

  // _login(LoginBloc bloc, BuildContext context) {
  //   print('================');
  //   print('Email: ${bloc.email}');
  //   print('Password: ${bloc.password}');
  //   print('================');

  //   Navigator.pushReplacementNamed(context, 'home');
  // }

}
