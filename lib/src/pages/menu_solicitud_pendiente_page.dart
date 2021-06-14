import 'dart:async';

import 'package:flutter/material.dart';
import 'package:suncare/src/bloc/connectivity_bloc.dart';
import 'package:suncare/src/bloc/provider.dart';
import 'package:suncare/src/models/paciente_model.dart';
import 'package:suncare/src/models/solicitud_model.dart';
import 'package:suncare/src/providers/connectivity_provider.dart';
import 'package:suncare/src/widgets/my_snack_bar.dart';
import 'package:suncare/src/utils/utils.dart' as utils;

class SolicitudPendientePage extends StatelessWidget {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final String notImage =
      'https://static.wikia.nocookie.net/adventuretimewithfinnandjake/images/1/17/Evicted_Bee.png/revision/latest?cb=20120711195105';
  DermatologoBloc dermatologoBloc;
  ConnectivityProvider _connectivityProvider = ConnectivityProvider.instance;
  ConnectivityBloc _connectivityBloc;

  @override
  Widget build(BuildContext context) {
    _connectivityBloc = Provider.of_ConnectivityBloc(context);
    dermatologoBloc = Provider.of_DermatologoBloc(context);
    dermatologoBloc.listarSolicitudes();
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: Text('Solicitudes de vinculación'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamed(context, 'home_dermatologo');
            }),
      ),
      body: Stack(children: [
        // Text('s'),
        Container(
          child: _crearListado(),
        ),
        StreamBuilder(
          stream: _connectivityBloc.connectivityStream,
          initialData: true,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            var isConnected = snapshot.data;
            print('raaaaaaaa ${isConnected}');
            if (isConnected != null) {
              _connectivityProvider.setShowError(isConnected);
            }
            return utils.mostrarInternetConexionAnimatedWithStream(
                _connectivityProvider);
          },
        ),
      ]),
    );
  }

  Widget _crearListado() {
    return StreamBuilder(
        stream: dermatologoBloc.misSolicitudesStream,
        builder: (BuildContext context,
            AsyncSnapshot<List<SolicitudModel>> snapshot) {
          print('-------- ${snapshot.data}');
          if (snapshot.hasData) {
            final solicitud = snapshot.data;
            if (solicitud.length == 0) {
              return Center(
                child:
                    Text('No hay solicitudes pendientes de pacientes nuevos'),
              );
            }
            return ListView.builder(
                itemCount: solicitud.length,
                itemBuilder: (context, i) => _crearItem(context, solicitud[i]));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget _crearItem(BuildContext context, SolicitudModel solictud) {
    return Dismissible(
      key: UniqueKey(),
      background: Container(color: Colors.red),
      onDismissed: (direccion) async {
        print('eliminar ${solictud.idUser}');
      },
      child: Card(
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 30.0,
                child: ClipOval(
                  child: FadeInImage(
                    placeholder: AssetImage('assets/img/no-image.png'),
                    image: solictud.imagenProfile == null ? NetworkImage('assets/img/no-image.png'): NetworkImage(solictud.imagenProfile),
                    fit: BoxFit.contain,
                    height: 200.0,
                  ),
                ),
              ),
              title: Text(solictud.nombre),
              subtitle: Text(solictud.vinculacionFecha.substring(0, 10)),
              onTap: () async {
                print('click en el item');
                _aceptarSolicitud(context, solictud);
              },
              trailing: Wrap(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.check),
                    color: Colors.blue,
                    onPressed: () async {
                      _aceptarSolicitud(context, solictud);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () async {

                      _cancelarSolicitud(context, solictud);
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _aceptarSolicitud(BuildContext context, SolicitudModel solicitud) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Solicitud'),
            content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Container(
                height: 60,
                child:
                    Text('¿Desea aceptar la solicitud de ${solicitud.nombre}?'),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                TextButton(
                    child:
                        Text('No', style: TextStyle(color: Colors.amber[800])),
                    onPressed: () => Navigator.of(context).pop()),
                TextButton(
                    child:
                        Text('Sí', style: TextStyle(color: Colors.amber[800])),
                    onPressed: () async {
                      if(_connectivityBloc.conectividad==false){
                        _connectivityProvider.setShowError(false);
                        Navigator.of(context).pop();
                        mostrarSnackBar(Icons.signal_wifi_off,
                            "Error de conexión a Internet", Colors.red);
                      } else {
                      bool respuesta =
                          await dermatologoBloc.aceptarSolicitud(solicitud);
                      if (respuesta == true) {
                        Navigator.of(context).pop();
                        mostrarSnackBar(Icons.thumb_up,
                            "Paciente vinculado con éxito", Colors.amber);
                        dermatologoBloc.listarSolicitudes();
                        print("Selecciónm");
                      } else {
                        Navigator.of(context).pop();
                        mostrarSnackBar(
                            Icons.error, "Ocurrió un error", Colors.red);
                      }}
                    }),
              ])
            ]),
          );
        });
  }

  void _cancelarSolicitud(
      BuildContext context, SolicitudModel solicitud) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Solicitud'),
            content: Container(
              height: 60,
              child:
                  Text('¿Desea cancelar la solicitud de ${solicitud.nombre}?'),
            ),
            actions: [
              TextButton(
                  child: Text('No'),
                  onPressed: () => Navigator.of(context).pop()),
              TextButton(
                  child: Text('Sí'),
                  onPressed: () async {
                    if(_connectivityBloc.conectividad==false){
                    _connectivityProvider.setShowError(true);
                    Navigator.of(context).pop();
                    mostrarSnackBar(Icons.signal_wifi_off,
                        "Error de conexión a Internet", Colors.red);
                    } else {
                    bool respuesta =
                        await dermatologoBloc.cancelarSolicitud(solicitud);

                    if (respuesta == true) {
                      Navigator.of(context).pop();
                      mostrarSnackBar(Icons.thumb_up,
                          "Solicitud cancelada correctamente", Colors.amber);
                      dermatologoBloc.listarSolicitudes();
                    } else {
                      Navigator.of(context).pop();
                      mostrarSnackBar(
                          Icons.error, "Ocurrió un error", Colors.red);
                    }}
                  }),
            ],
          );
        });
  }

  void mostrarSnackBar(IconData icon, String mensaje, Color color) {
    final snackbar = mySnackBar(icon, mensaje, color);
    scaffoldKey.currentState.showSnackBar(snackbar);
  }
}

