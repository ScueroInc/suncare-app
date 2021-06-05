import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:suncare/src/bloc/dermatologo_bloc.dart';
import 'package:suncare/src/bloc/provider.dart';
import 'package:suncare/src/models/dermatologo_model.dart';
import 'package:suncare/src/preferencias/preferencias_usuario.dart';
import 'package:suncare/src/providers/connectivity_provider.dart';
import 'package:suncare/src/widgets/my_snack_bar.dart';
import 'package:suncare/src/utils/utils.dart' as utils;

class EditarDermatoloPage extends StatefulWidget {
  @override
  _EditarDermatoloPageState createState() => _EditarDermatoloPageState();
}

class _EditarDermatoloPageState extends State<EditarDermatoloPage> {
  final PreferenciasUsuario _preferencia = new PreferenciasUsuario();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();

  File foto;

  DermatologoModel dermatologo = new DermatologoModel();
  DermatologoBloc dermatologoBloc;

  ConnectivityProvider _connectivityProvider = ConnectivityProvider.instance;

  @override
  Widget build(BuildContext context) {
    final idUser = _preferencia.userIdDB;
    dermatologoBloc = Provider.of_DermatologoBloc(context);
    dermatologoBloc.buscarDermatologo(idUser);

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text('Modificar perfil'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, 'perfil_dermatologo');
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(left: 16, top: 25, right: 16),
              child: StreamBuilder(
                stream: dermatologoBloc.dermatologoBuscadoStream,
                builder: (BuildContext context,
                    AsyncSnapshot<DermatologoModel> snapshot) {
                  // print('-------0 ${snapshot.data}');
                  if (snapshot.hasData) {
                    dermatologo = snapshot.data;

                    return Form(
                      key: formKey,
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 100),
                          // _mostrarFoto(),
                          SizedBox(height: 20),
                          _mostrarNombre(dermatologoBloc),
                          SizedBox(height: 20),
                          _mostrarApellido(dermatologoBloc),
                          SizedBox(height: 20),
                          _mostrarCorreo(dermatologoBloc),
                          // _mostrarNacimiento(),
                          // _mostrarTipoPiel(),
                          SizedBox(height: 40),
                          _mostrarAcciones(dermatologoBloc),
                          SizedBox(height: 20),

                          _crearCancelar(context),
                          // _suspenderCuenta()
                        ],
                      ),
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            utils.mostrarInternetConexionWithStream(_connectivityProvider)
          ],
        ),
      ),
    );
  }

  Widget _mostrarNombre(DermatologoBloc bloc) {
    return StreamBuilder(
      stream: bloc.nameStream,
      initialData: bloc.changeName(dermatologo.nombre),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return TextFormField(
          maxLength: 30,
          buildCounter: (BuildContext context,
                  {int currentLength, int maxLength, bool isFocused}) =>
              null,
          initialValue: dermatologo.nombre,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: 'Nombre',
            errorText: snapshot.error,
          ),
          onSaved: (value) => dermatologo.nombre = value,
          onChanged: (value) => bloc.changeName(value),
        );
      },
    );
  }

  Widget _mostrarApellido(DermatologoBloc bloc) {
    return StreamBuilder(
      stream: bloc.lastNameStream,
      initialData: bloc.changeLastName(dermatologo.apellido),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return TextFormField(
          maxLength: 30,
          buildCounter: (BuildContext context,
                  {int currentLength, int maxLength, bool isFocused}) =>
              null,
          initialValue: dermatologo.apellido,
          decoration: InputDecoration(
            labelText: 'Apellidos',
            errorText: snapshot.error,
          ),
          onSaved: (value) => dermatologo.apellido = value,
          onChanged: (value) => bloc.changeLastName(value),
        );
      },
    );
  }

  Widget _mostrarCorreo(DermatologoBloc bloc) {
    return StreamBuilder(
      stream: bloc.emailStream,
      initialData: bloc.changeEmail(dermatologo.correo),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return TextFormField(
          // enabled: false,
          initialValue: dermatologo.correo,
          decoration: InputDecoration(
            labelText: 'Correo',
            errorText: snapshot.error,
          ),
          onSaved: (value) {
            dermatologo.correo = value;
          },
          onChanged: (value) => bloc.changeEmail(value),
        );
      },
    );
  }

  Widget _mostrarFoto() {
    return Container(
      color: Colors.amber,
      child: _fotoVista(),
    );
  }

  Widget _fotoVista() {
    if (dermatologo.imagenProfile != null) {
      return FadeInImage(
        placeholder: AssetImage('assets/img/no-image.png'),
        image: NetworkImage(dermatologo.imagenProfile),
        fit: BoxFit.contain,
        height: 200.0,
      );
    } else {
      return foto == null
          ? Image(
              image: AssetImage('assets/img/no-image.png'),
              height: 200.00,
              fit: BoxFit.cover,
            )
          : Image.file(
              foto,
              height: 200.0,
              fit: BoxFit.cover,
            );
    }
  }

  Widget _mostrarAcciones(DermatologoBloc bloc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StreamBuilder(
          stream: bloc.formValidStream,
          builder: (BuildContext ctx, AsyncSnapshot snapshotform) {
            return StreamBuilder(
                stream: _connectivityProvider.connectivityStream,
                initialData: true,
                builder: (context, snapshot) {
                  var isConnected = snapshot.data;
                  if (isConnected != null) {
                    if (isConnected == true) {
                      _connectivityProvider.setShowError(true);
                    }
                  }
                  return RaisedButton(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 80.0, vertical: 15.0),
                      child: Text(
                        'Guardar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    color: Colors.amber,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    onPressed: snapshotform.hasData
                        ? () {
                            if (isConnected != null) {
                              if (isConnected == true) {
                                mostrarSnackBar(
                                    Icons.thumb_up,
                                    'Cambios guardados con éxito',
                                    Colors.amber);
                                _submit(context);
                              } else {
                                _connectivityProvider.setShowError(false);
                              }
                            }
                          }
                        : null,
                  );
                });
          },
        )
      ],
    );
  }

  void _submit(BuildContext context) async {
    if (!formKey.currentState.validate()) return;

    formKey.currentState.save();

    if (foto != null) {
      dermatologo.imagenProfile = await dermatologoBloc
          .subirFoto(foto); //productoProvider.subirImagen(foto);
    }

    dermatologo.first = true;
    await dermatologoBloc.editarDermatologo(dermatologo);
    print('_submit primeraVez -> ${_preferencia.primeraVez}');
    if (_preferencia.primeraVez == false) {
      print('if ini -> ');
      _preferencia.primeraVez = true;
      print('if fin -> ${_preferencia.primeraVez}');
    }
    Navigator.pushReplacementNamed(context, 'home_dermatologo');
    mostrarSnackBar(Icons.thumb_up, 'Cambios guardados con éxito',
        Colors.amber);
  }

  Widget _crearCancelar(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 45,
      /* child: RaisedButton(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
          child: Text(
            'Cancelar',
            style: TextStyle(color: Colors.white),
          ),
        ),
        color: Color.fromRGBO(245, 90, 90, 1),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () {
          Navigator.pushReplacementNamed(context, 'perfil_dermatologo');
        },
      ), */
      child: Container(
          child: RaisedButton(
        child: Text(
          'Cancelar',
          style: TextStyle(color: Colors.white),
        ),
        color: Color.fromRGBO(245, 90, 90, 1),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () {
          Navigator.pushReplacementNamed(context, 'perfil_dermatologo');
        },
      )),
      // child: RaisedButton(
      //   child: Container(
      //       padding: EdgeInsets.symmetric(horizontal: 80.0, vertical: 15.0),

      //     child: Text('Cancelar', style: TextStyle(fontSize: 18.0)),
      //   ),
      //   shape:
      //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      //   elevation: 0.0,
      //   color: Color.fromRGBO(245, 90, 90, 1),
      //   textColor: Colors.white,
      //   onPressed: () {
      //     Navigator.pushReplacementNamed(context, 'login');
      //   },
      // ),
    );
  }

  void mostrarSnackBar(IconData icon, String mensaje, Color color) {
    final snackbar = mySnackBar(icon, mensaje, color);
    scaffoldKey.currentState.showSnackBar(snackbar);
  }
}
