import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter/material.dart';

class RegistroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: Color.fromRGBO(143, 148, 251, 6),
        body: _selectTypeUser(context, size));
  }

  Widget _selectTypeUser(BuildContext context, Size size) {
    return Center(
      child: Column(
        children: [
          Container(
            height: size.height * 0.35,
            child: SvgPicture.asset('assets/img/logo_registro.svg'),
          ),
          SizedBox(height: 50),
          Text(
            'TIPO DE USUARIO',
            style: TextStyle(color: Colors.white, fontSize: 28.0),
          ),
          SizedBox(height: 120),
          _buttonUsuario(context),
          SizedBox(
            height: 50,
          ),
          _buttonDermatologo(context),
        ],
      ),
    );
  }

  Widget _buttonUsuario(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 50,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          border: Border.all(width: 4, color: Colors.white),
        ),
        child: RaisedButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
          color: Color.fromRGBO(143, 148, 251, 1),
          textColor: Colors.white,
          child: Text('Usuario', style: TextStyle(fontSize: 18.0)),
          onPressed: () {
            _goRegistro(context, 1);
          },
        ),
      ),
    );
  }

  Widget _buttonDermatologo(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 50,
      child: Container(
        child: RaisedButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
          color: Colors.white,
          textColor: Color.fromRGBO(143, 148, 251, 1),
          child: Text('Dermatólogo', style: TextStyle(fontSize: 18.0)),
          onPressed: () {
            _goRegistro(context, 2);
          },
        ),
      ),
    );
  }

  void _goRegistro(BuildContext context, int tipoUsuario) {
    if (tipoUsuario == 1) {
      Navigator.pushReplacementNamed(context, 'goUsuario');
    } else {
      Navigator.pushReplacementNamed(context, 'goDermatologo');
    }
  }
}
