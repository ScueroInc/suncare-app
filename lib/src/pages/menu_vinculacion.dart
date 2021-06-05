import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/services/text_formatter.dart';
import 'package:suncare/src/bloc/connectivity_bloc.dart';
import 'package:suncare/src/bloc/provider.dart';
import 'package:suncare/src/bloc/validarCmp_bloc.dart';
import 'package:suncare/src/bloc/vinculacion_bloc.dart';
import 'package:suncare/src/models/dermatologo_model.dart';
import 'package:suncare/src/providers/connectivity_provider.dart';
import 'package:suncare/src/widgets/my_snack_bar.dart';
import 'package:suncare/src/utils/utils.dart' as utils;

class MenuVinculacion extends StatelessWidget {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  ConnectivityBloc _connectivityBloc;
  VinculacionBloc _vinculacionBloc;
  ConnectivityProvider _connectivityProvider;
  String idMedicoVincular = "";
  Size size;
  @override
  Widget build(BuildContext context) {
    _vinculacionBloc = Provider.of_VinculacionBloc(context);
    _connectivityBloc = Provider.of_ConnectivityBloc(context);
    _vinculacionBloc.estadoActual();
    _connectivityProvider = ConnectivityProvider.instance;
    size = MediaQuery.of(context).size;

    bool ultimoEstado = _connectivityBloc.conectividad;
    print('-internet- ${_connectivityBloc.conectividad}');

    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text('Estado de vinculación'),
          backgroundColor: Colors.amber,
        ),
        //body: contenido(),
        body: StreamBuilder(
          stream: _connectivityBloc.connectivityStream,
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            var status = snapshot.data;
            if (ultimoEstado == false && status == false) {
              return utils.nostrarInternetError();
            } else {
              return Stack(
                children: [
                  contenido(),
                  // utils.mostrarInternetConexionWithStream(_connectivityProvider)
                  utils.nostrarInternetErrorStream(_connectivityBloc)
                ],
              );
            }
          },
        )

        // floatingActionButton: botonFlotante(context),
        );
  }

  Widget contenido() {
    return StreamBuilder(
      stream: _vinculacionBloc.estadoStream,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        final bloc = Provider.of_ValidarCmpBloc(context);

        if (snapshot.hasData) {
          if (snapshot.data == "NULA") {
            // return vinculacionDesactivada();
            return AlertDialog(
              title: Text('Vincular doctor'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 60,
                    child: StreamBuilder(
                      stream: bloc.cmpStream,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        return TextField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            new LengthLimitingTextInputFormatter(6)
                          ],
                          decoration: InputDecoration(
                            icon: Icon(Icons.local_hospital,
                                color: Colors.deepPurple),
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            hintText: 'CMP',
                            errorText: snapshot.error,
                          ),
                          onChanged: (value) {
                            idMedicoVincular = value;
                            bloc.changeCmp(value);
                          },
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                          child: Text('Cancelar',
                              style: TextStyle(color: Colors.amber[800])),
                          onPressed: () => {
                                bloc.changeCmp(''),
                                Navigator.pushNamed(context, 'home')
                              }),
                      StreamBuilder(
                        //dashhhhhhh
                        // stream: _connectivityProvider.connectivityStream ,
                        stream: _connectivityBloc.connectivityStream,
                        initialData: true,
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          var isConnected = snapshot.data;
                          print('raaass ${isConnected}');
                          if (isConnected != null) {
                            if (isConnected == true) {
                              _connectivityProvider.setShowError(true);
                            }
                          }
                          return Container(
                              child: TextButton(
                                  child: Text('Aceptar',
                                      style:
                                          TextStyle(color: Colors.amber[800])),
                                  onPressed: () async {
                                    if (isConnected != null) {
                                      if (isConnected == true) {
                                        bool res = await _vinculacionBloc
                                            .crearVinculacion(idMedicoVincular);

                                        if (res == true) {
                                          // Navigator.of(context).pop();
                                          mostrarSnackBar(
                                              Icons.thumb_up,
                                              'Dermatólogo vinculado con éxito',
                                              Colors.amber);
                                          await _vinculacionBloc.estadoActual();
                                          Timer(Duration(seconds: 2), () {
                                            Navigator.pushReplacementNamed(
                                                context, 'vinculacion');
                                          });
                                        } else {
                                          // Navigator.of(context).pop();
                                          mostrarSnackBar(Icons.error,
                                              'Ocurrio un error', Colors.red);
                                        }
                                      } else {
                                        _connectivityProvider
                                            .setShowError(false);
                                      }
                                    }
                                  }));
                        },
                      ),
                      /* TextButton(
                      child: Text('Cancelar',
                              style: TextStyle(
                                  color: Color.fromRGBO(143, 148, 251, 6))
                                  ),
                      onPressed: () => {
                        bloc.changeCmp(''),
                        Navigator.pushNamed(context, 'home')                        
                        }
                        ), */
                      /* TextButton(
                          child: Text('Aceptar',
                              style: TextStyle(
                                  color: Color.fromRGBO(143, 148, 251, 6))),
                          onPressed: () async {
                            bool res = await _vinculacionBloc
                                .crearVinculacion(idMedicoVincular);

                            if (res == true) {
                              // Navigator.of(context).pop();
                              Navigator.pushReplacementNamed(context, 'vinculacion');
                              mostrarSnackBar(Icons.thumb_up,
                                  'Paciente vinculado con éxito', Colors.blue);
                              await _vinculacionBloc.estadoActual();
                            } else {
                              // Navigator.of(context).pop();
                              mostrarSnackBar(
                                  Icons.error, 'Ocurrio un error', Colors.red);
                            }
                          }), */
                    ],
                  ),
                ],
              ),
            );
          } else {
            return vinculacionEstado(snapshot.data);
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget vinculacionEstado(String estado) {
    return Column(
      children: [
        widgetEstado(estado),
        widgetMedicoDetalle(),
      ],
    );
  }

  Widget widgetEstado(String estado) {
    return Container(
      margin: EdgeInsets.all(20),
      width: size.width,
      child: Card(
        child: Column(
          children: [
            ListTile(
              title: Text(
                estado,
                style: TextStyle(fontSize: 25),
              ),
              subtitle: Text('Estado'),
            ),
          ],
        ),
      ),
    );
  }

  Widget widgetMedicoDetalle() {
    return Container(
      height: 300,
      margin: EdgeInsets.all(20),
      width: size.width,
      child: Card(
        child: StreamBuilder(
          stream: _vinculacionBloc.dermatologoVinculadoStream,
          builder:
              (BuildContext context, AsyncSnapshot<DermatologoModel> snapshot) {
            if (snapshot.hasData) {
              var dermatologo = snapshot.data;
              return Column(
                children: [
                  ListTile(
                    title: Text(
                      dermatologo.nombre,
                      style: TextStyle(fontSize: 25),
                    ),
                    subtitle: Text('Nombre'),
                  ),
                  ListTile(
                    title: Text(
                      dermatologo.apellido,
                      style: TextStyle(fontSize: 25),
                    ),
                    subtitle: Text('Apellidos'),
                  ),
                  ListTile(
                    title: Text(
                      dermatologo.codigo,
                      style: TextStyle(fontSize: 25),
                    ),
                    subtitle: Text('CMP'),
                  ),
                  Center(
                    child: _crearCancelar(context),
                  )
                ],
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Widget vinculacionDesactivada() {
    return Container(
      child: Center(child: Text('No posee ninguna vinculación activa')),
    );
  }

  Widget botonFlotante(BuildContext context) {
    final bloc = Provider.of_ValidarCmpBloc(context);
    return StreamBuilder(
      stream: _vinculacionBloc.estadoStream,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == "NULA") {
            return FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () => _mostrarVinculacion(context, bloc),
            );
          } else {
            return FloatingActionButton(
              child: Icon(Icons.cancel),
              onPressed: () => _cancelarVinculacion(context),
            );
          }
        } else {
          return FloatingActionButton(
            child: Icon(Icons.cached),
            onPressed: () {},
          );
        }
      },
    );
  }

  void _cancelarVinculacion(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Cancelar Vinculación'),
            content: Container(
              height: 60,
              child: Text('¿Está seguro que desea cancelar la solicitud?'),
            ),
            actions: [
              TextButton(
                  child: Text('No'),
                  onPressed: () => Navigator.of(context).pop()),
              TextButton(
                  child: Text('Sí'),
                  onPressed: () async {
                    bool respuesta =
                        await _vinculacionBloc.cancelarVinculacion();
                    if (respuesta) {
                      //se cancelo correctamente
                      print('se canceló correctamente');
                      Navigator.of(context).pop();
                      mostrarSnackBar(Icons.thumb_up,
                          'Se canceló correctamente', Colors.amber);
                      _vinculacionBloc.estadoActual();
                    } else {
                      //hubo un error
                      print('hubo un error');
                      Navigator.of(context).pop();
                      mostrarSnackBar(
                          Icons.error, 'Ocurrió un error', Colors.red);
                    }
                  }),
            ],
          );
        });
  }

  Widget _crearCancelar(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 45,
      child: StreamBuilder(
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
                padding: EdgeInsets.symmetric(horizontal: 80.0, vertical: 15.0),
                child: Text(
                  'Desvincular',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              color: Color.fromRGBO(245, 90, 90, 1),
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              onPressed: () async {
                if (isConnected != null) {
                  if (isConnected == true) {
                    // Navigator.pushReplacementNamed(context, 'perfil_dermatologo');
                    bool respuesta =
                        await _vinculacionBloc.cancelarVinculacion();
                    if (respuesta) {
                      //se cancelo correctamente
                      print('Dermatólogo desvincunlado con éxito');
                      // Navigator.of(context).pop();
                      mostrarSnackBar(Icons.thumb_up,
                          'Dermatólogo desvincunlado con éxito', Colors.amber);
                      _vinculacionBloc.estadoActual();
                      Timer(Duration(seconds: 2), () {
                        Navigator.pushNamed(context, 'home');
                      });
                    } else {
                      //hubo un error
                      print('hubo un error');
                      Navigator.of(context).pop();
                      mostrarSnackBar(
                          Icons.error, 'Ocurrio un error', Colors.red);
                    }
                  } else {
                    _connectivityProvider.setShowError(false);
                  }
                }
              },
            );
          }),
    );
  }

  void _mostrarVinculacion(BuildContext context, ValidarCmpBloc bloc) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Vincular Doctor'),
          content: Container(
            height: 60,
            child: StreamBuilder(
              stream: bloc.cmpStream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [new LengthLimitingTextInputFormatter(6)],
                  decoration: InputDecoration(
                    icon: Icon(Icons.local_hospital, color: Colors.deepPurple),
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    hintText: 'CMP',
                    errorText: snapshot.error,
                  ),
                  onChanged: (value) {
                    idMedicoVincular = value;
                    bloc.changeCmp(value);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
                child: Text('Cancelar'),
                onPressed: () => Navigator.of(context).pop()),
            TextButton(
                child: Text('Aceptar'),
                onPressed: () async {
                  bool res =
                      await _vinculacionBloc.crearVinculacion(idMedicoVincular);

                  if (res == true) {
                    Navigator.of(context).pop();
                    mostrarSnackBar(
                        Icons.thumb_up, 'Vinculación correcta', Colors.amber);
                    await _vinculacionBloc.estadoActual();
                  } else {
                    Navigator.of(context).pop();
                    mostrarSnackBar(
                        Icons.error, 'Ocurrió un error', Colors.red);
                  }
                }),
          ],
        );
      },
    );
  }

  void mostrarSnackBar(IconData icon, String mensaje, Color color) {
    final snackbar = mySnackBar(icon, mensaje, color);
    scaffoldKey.currentState.showSnackBar(snackbar);
  }
}
