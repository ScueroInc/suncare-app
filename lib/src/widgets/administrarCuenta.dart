import 'package:flutter/material.dart';
import 'package:suncare/src/bloc/provider.dart';
import 'package:suncare/src/preferencias/preferencias_usuario.dart';

class AdministrarCuenta extends StatefulWidget {
  @override
  _AdministrarCuentaState createState() => _AdministrarCuentaState();
}

class _AdministrarCuentaState extends State<AdministrarCuenta> {
  final PreferenciasUsuario _preferencia = new PreferenciasUsuario();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: Color.fromRGBO(143, 148, 251, 6),
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
            body: Container(
              padding: EdgeInsets.all(15.0),
              child: _listaOpciones(context),
            )));
  }

  _listaOpciones(BuildContext context) {
    // final dataCoreBloc = Provider.of_DataCoreBloc(context);

    return Column(
      children: [
        Card(
          child: ListTile(
            title: Text('Deshabilitar cuenta'),
            onTap: () {
              _showMesssageDialog('¿Seguro que quiere desabilitar su cuenta?');
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
        title: Text('Suspender Cuenta'),
        content: Column(
            mainAxisSize: MainAxisSize.min, 
            children: <Widget>[
              Text(message),
              SizedBox(height: 20),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    FlatButton(
                      child: Text('No', style: TextStyle(color: Color.fromRGBO(143, 148, 251, 6))),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    ),
                    FlatButton(
                      child: Text('Sí', style: TextStyle(color: Color.fromRGBO(143, 148, 251, 6))),
                      onPressed: () {
                        _preferencia.suspenderCuenta(_preferencia.token);
                        Navigator.of(ctx).pop();
                        Navigator.pushReplacementNamed(context, 'login');
                      },
                    )
                  ])
            ])
      ),
    );
  }
}
