import 'dart:async';

import 'package:flutter/material.dart';
import 'package:suncare/src/bloc/connectivity_bloc.dart';
import 'package:suncare/src/providers/connectivity_provider.dart';

bool isNumeric(String value) {
  if (value.isEmpty) return false;

  final n = num.tryParse(value);

  return (n == null) ? false : true;
}

bool isText(String value) {
  if (value.isEmpty) return false;

  final n = num.tryParse(value);

  return (n == null) ? true : false;
}

bool isEmail(String email) {
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regExp = new RegExp(pattern);
  if (regExp.hasMatch(email)) {
    return true;
  } else {
    return false;
  }
}

bool isCMP(String CMP) {
  Pattern pattern =
      r'[0-9]*$';
  RegExp regExp = new RegExp(pattern);
  if (regExp.hasMatch(CMP)) {
    return true;
  } else {
    return false;
  }
}

bool isSpecialCaracter(String password) {
  String pattern =
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
  RegExp regExp = new RegExp(pattern);
  if (regExp.hasMatch(password)) {
    return true;
  } else {
    return false;
  }
}

void mostrarAlerta(BuildContext context, String mensaje) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Error al registrar cuenta',
            textAlign: TextAlign.center,
          ),
          content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Text(mensaje, textAlign: TextAlign.center),
            SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Aceptar',
                    style: TextStyle(color: Color.fromRGBO(143, 148, 251, 6))),
              )
            ])
          ]),
        );
      });
}

double medSegunPiel(int tipo) {
  return 2.0;
}

Widget mostrarInternetConexionWithStream(ConnectivityProvider _connectivity) {
  return StreamBuilder(
      stream: _connectivity.showErrorStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.data == false) {
          return Positioned(
            right: 0,
            left: 0,
            top: 0,
            height: 24,
            child: AnimatedContainer(
                curve: Curves.easeInBack,
                duration: Duration(milliseconds: 1000),
                color: Colors.grey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text("Error de conexión a Internet")],
                )),
          );
        } else {
          return Container();
        }
      });
}

Widget mostrarInternetConexionAnimatedWithStream(
    ConnectivityProvider _connectivity) {
  return StreamBuilder(
      stream: _connectivity.showErrorStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.data == false) {
          return AnimatedContainer(
              curve: Curves.easeInBack,
              duration: Duration(milliseconds: 1000),
              color: Colors.grey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text("Error de conexión a Internet")],
              ));
        } else {
          return Container();
        }
      });
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
        color: isConnected ? null : Colors.grey,
        child: isConnected
            ? null
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text("Error de conexión a Internet")],
              )),
  );
}

Widget nostrarInternetAnimated(bool isConnected) {
  return AnimatedContainer(
      curve: Curves.easeInBack,
      duration: Duration(milliseconds: 1000),
      color: isConnected ? null : Colors.grey,
      child: isConnected
          ? null
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text("Error de conexión a Internet")],
            ));
}

Widget mostrarSesionfinalizadan() {
  return Positioned(
    right: 0,
    left: 0,
    top: 0,
    height: 24,
    child: AnimatedContainer(
        curve: Curves.easeInBack,
        duration: Duration(milliseconds: 1000),
        color: Colors.grey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text("Sesión finalizada")],
        )),
  );
}

Widget nostrarInternetError() {
  return AnimatedContainer(
      curve: Curves.easeInBack,
      duration: Duration(milliseconds: 1000),
      color: Colors.grey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text("Error de conexión a Internet")],
      ));
}

Widget nostrarInternetErrorStream(ConnectivityBloc _connectivityBloc) {
  return StreamBuilder(
    stream: _connectivityBloc.showErrorStream,
    // initialData: initialData ,
    builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
      if (snapshot.data == true) {
        return AnimatedContainer(
            curve: Curves.easeInBack,
            duration: Duration(milliseconds: 1000),
            color: Colors.grey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text("Error de conexión a Internet")],
            ));
      } else {
        return Container();
      }
    },
  );
}

Widget mySnackBarError() {
  return SnackBar(
    backgroundColor: Colors.amber,
    content: Container(
      child: Row(
        children: [
          Icon(Icons.wifi_off),
          SizedBox(width: 20),
          Expanded(child: Text("Error de conexión a Internet"))
        ],
      ),
    ),
    behavior: SnackBarBehavior.floating,
    duration: Duration(milliseconds: 1800),
  );
}
