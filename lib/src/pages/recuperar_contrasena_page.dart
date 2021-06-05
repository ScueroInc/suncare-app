import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:suncare/src/bloc/provider.dart';
// import 'package:firebase_auth';
import 'package:suncare/src/bloc/recuperarContrasena_bloc.dart';
import 'package:suncare/src/models/dermatologo_model.dart';
import 'package:suncare/src/models/paciente_model.dart';
import 'package:suncare/src/providers/connectivity_provider.dart';
import 'package:suncare/src/providers/usuario_provider.dart';
import 'package:suncare/src/utils/utils.dart' as utils;

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
  ConnectivityProvider _connectivityProvider = ConnectivityProvider.instance;

  @override
  Widget build(BuildContext context) {
    
    return SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                
                Container(
                  padding: EdgeInsets.all(15.0),
                  child: _formularioRecuperarContrasena(context),
                ),
                utils.mostrarInternetConexionWithStream(_connectivityProvider)
              ],
            )));
  }

  Widget _formularioRecuperarContrasena(BuildContext context) {
    final bloc = Provider.of_RecuperarContrasenaBloc(context);

    return Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
    textAlign: TextAlign.center,
        style:
            TextStyle(fontSize: 28.0, color: Colors.amber[800]));
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
        builder: (BuildContext ctx, AsyncSnapshot snapshotform) {
          return SizedBox(
            width: 300,
            height: 40,
            child: StreamBuilder(
              stream: _connectivityProvider.connectivityStream ,
              initialData: true,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                var isConnected = snapshot.data;
                if(isConnected != null){                           
                  if(isConnected == true){
                    _connectivityProvider.setShowError(true);
                  }
                }
                return RaisedButton(
                  child: Container(
                    child: Text('Recuperar',
                        style: TextStyle(fontSize: 18.0)),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0)),
                  elevation: 0.0,
                  color: Colors.amber,
                  textColor: Colors.white,
                  onPressed: snapshotform.hasData
                      ? () {
                        if(isConnected != null) {
                            if(isConnected == true) {
                              usuarioProvider.enviarRecuperarContrasena(bloc.email);
                              _showMesssageDialog('Por favor revise su correo');
                            } else {
                              _connectivityProvider.setShowError(false);
                            }
                        }
                      }
                      : null,
                );
              }
            ),
          );
        });
  }

  void _showMesssageDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Restablecer contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min, 
          children: <Widget>[
            Text(message),
            SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              FlatButton(
                  child: Text('Aceptar',style: TextStyle(color: Colors.amber[800])),
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
      width: 300,
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
        onPressed: () {
          Navigator.pushReplacementNamed(context, 'login');
        },
      ),
    );
  }
}
