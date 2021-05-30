import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:suncare/src/bloc/provider.dart';
// import 'package:firebase_auth';
import 'package:suncare/src/bloc/recuperarContrasena_bloc.dart';
import 'package:suncare/src/models/dermatologo_model.dart';
import 'package:suncare/src/models/paciente_model.dart';
import 'package:suncare/src/providers/usuario_provider.dart';
import 'package:suncare/src/utils/utils.dart' as utils;
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';

class RecuperarContrasenaPage extends StatefulWidget {
  @override
  _RecuperarContrasenaPageState createState() =>
      _RecuperarContrasenaPageState();
}

class _RecuperarContrasenaPageState extends State<RecuperarContrasenaPage> {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final UsuarioProvider usuarioProvider = new UsuarioProvider();

  PacienteBloc pacienteBloc;
  PacienteModel paciente = new PacienteModel();
  DermatologoBloc dermatologoBloc;
  DermatologoModel dermatologoModel = new DermatologoModel();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Container(
              padding: EdgeInsets.all(15.0),
              child: _formularioRecuperarContrasena(context),
            )));
  }

  Widget _formularioRecuperarContrasena(BuildContext context) {
    final bloc = Provider.of_RecuperarContrasenaBloc(context);

    return Form(
        key: formKey,
        child: Column(
          children: [
            SizedBox(height: 30),
            _titlePage(),
            SizedBox(height: 50),
            _crearCorreo(bloc),
            Divider(),
            _crearBoton(context, bloc),
            SizedBox(height: 5),
            _crearCancelar(context),
          ],
        ));
  }

  Widget _titlePage() {
    return Text('Recuperar contraseña',
        style:
            TextStyle(fontSize: 28.0, color: Color.fromRGBO(143, 148, 251, 1)));
  }

  Widget _crearCorreo(RecuperarContrasenaBloc bloc) {
    return StreamBuilder(
        stream: bloc.emailStream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return TextFormField(
            initialValue: paciente.correo,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
              icon: Icon(Icons.email),
              labelText: 'Ingrese su correo',
              errorText: snapshot.error,
            ),
            onSaved: (value) => paciente.correo = value,
            validator: (value) {
              if (utils.isEmail(value) == true) {
                return null;
              } else {
                return 'Ingrese un correo válido';
              }
            },
            onChanged: (value) => bloc.changeEmail(value),
          );
        });
  }

  Widget _crearBoton(BuildContext context, RecuperarContrasenaBloc bloc) {
    return StreamBuilder(
        stream: bloc.formValidStream,
        // initialData: null,
        builder: (BuildContext ctx, AsyncSnapshot snapshot) {
          return SizedBox(
            width: 180, //Changed
            height: 40,
            child: RaisedButton(
              child: Container(
                child: Text('Recuperar',
                    style: TextStyle(fontSize: 18.0)),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0)),
              elevation: 0.0,
              color: Color.fromRGBO(143, 148, 251, 1),
              textColor: Colors.white,
              onPressed: snapshot.hasData
                  ? () {
                      usuarioProvider.enviarRecuperarContrasena(bloc.email);
                      _showMesssageDialog('Se envió un correo');
                    }
                  : null,
            ),
          );
        });
  }

  void _showMesssageDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cambio de contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min, 
          children: <Widget>[
            Text(message),
            SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              FlatButton(
                  child: Text('Aceptar',style: TextStyle(color: Color.fromRGBO(143, 148, 251, 6))),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.pushReplacementNamed(context, 'login');
              })
            ])
        ]),
      ),
    );
  }

  Widget _crearCancelar(BuildContext context) {
    return SizedBox(
      width: 180, //Changed
      height: 40,
      child: RaisedButton(
        child: Container(
          child: Text('Cancelar', style: TextStyle(fontSize: 18.0)),
        ),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        elevation: 0.0,
        color: Color.fromRGBO(245, 90, 90, 1),
        textColor: Colors.white,
        onPressed: checkConnection
      ),
    );
  }



  checkConnection() async {
    var connection = await Connectivity().checkConnectivity();
    if(connection == ConnectivityResult.none){
      return AwesomeDialog(
        context: context,
        dialogType: DialogType.ERROR,
        animType: AnimType.RIGHSLIDE,
        title: 'En este momento no tienes conexión',
        desc: '',
      )..show();
    }
    else  {
      return AwesomeDialog(
        context: context,
        dialogType: DialogType.SUCCES,
        animType: AnimType.TOPSLIDE,
        title: 'Se restauró la conexión a Internet',
        desc: '',
      )..show();
    }
  }




}
