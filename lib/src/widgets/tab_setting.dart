import 'package:flutter/material.dart';
import 'package:suncare/src/bloc/data_bloc.dart';
import 'package:suncare/src/bloc/provider.dart';

class Tab_Setting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: _listaOpciones(context),
    );
  }
}

_listaOpciones(BuildContext context) {
  final dataCoreBloc = Provider.of_DataCoreBloc(context);

  return Column(
    children: [
      CheckboxListTile(
        value: true,
        subtitle: Text('Permitir las notificaciones'),
        title: Text('Notificaciones'),
        onChanged: (value) {},
      ),
      ListTile(
        title: Text('Administrar cuenta'),
        onTap: () {
          Navigator.pushReplacementNamed(context, 'adminitrarCuenta');
          // dataCoreBloc.insertarTiempoMaximo(30);
        },
      ),
      ListTile(
        title: Text('Cerrar Sesión'),
        onTap: () {
          // dataCoreBloc.insertarTiempoMaximo(30);
          Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
        },
      ),
    ],
  );
}
