import 'dart:async';

import 'package:flutter/material.dart';

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

          title: Text('Error al registrar cuenta', style: TextStyle(fontSize: 25)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(mensaje,style: TextStyle(fontSize: 15)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Aceptar',style: TextStyle(color: Color.fromRGBO(143, 148, 251, 6))),
                  )]
            )
          ]
          ),
        );
      });
}

double medSegunPiel(int tipo) {
  return 2.0;
}
