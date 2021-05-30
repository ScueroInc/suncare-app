import 'package:flutter/material.dart';
import 'package:suncare/src/bloc/provider.dart';
import 'package:suncare/src/models/paciente_model.dart';
import 'package:suncare/src/models/solicitud_model.dart';
import 'package:suncare/src/widgets/my_snack_bar.dart';

class SolicitudPendientePage extends StatelessWidget {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final String notImage =
      'https://static.wikia.nocookie.net/adventuretimewithfinnandjake/images/1/17/Evicted_Bee.png/revision/latest?cb=20120711195105';
  DermatologoBloc dermatologoBloc;

  @override
  Widget build(BuildContext context) {
    dermatologoBloc = Provider.of_DermatologoBloc(context);
    dermatologoBloc.listarSolicitudes();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(143, 148, 251, 6),
        centerTitle: true,
        title: Text('Solicitudes de vinculación'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamed(context, 'home_dermatologo');
            }),
      ),
      body: Container(
        child: _crearListado(),
      ),
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
        // productoProvider.eliminarProducto(producto.id);
        // productoBloc.borrarProducto(producto.id);

        print('eliminar ${solictud.idUser}');
        // await dermatologoBloc.cancelarSolicitud(solictud);
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
                    image: solictud.imagenProfile == null
                        ? NetworkImage('assets/img/no-image.png')
                        : NetworkImage(solictud.imagenProfile),
                    fit: BoxFit.contain,
                    height: 200.0,
                  ),
                ),
              ),
              title: Text(solictud.nombre),
              subtitle: Text(solictud.vinculacionFecha.substring(0, 10)),
              onTap: () async {
                // await dermatologoBloc.cancelarSolicitud(solictud);
                print('click en el item');
                _aceptarSolicitud(context, solictud);
              },
              trailing: Wrap(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.check),
                    color: Colors.blue,
                    onPressed: () async {
                      // _cancelarSolicitud(context, solictud);
                      bool respuesta =
                          await dermatologoBloc.aceptarSolicitud(solictud);
                      if (respuesta == true) {
                        mostrarSnackBar(Icons.thumb_up,
                            'Paciente vinculado con éxito', Color.fromRGBO(143, 148, 251, 6));
                        Navigator.of(context).pop();
                        dermatologoBloc.listarSolicitudes();
                      } else {
                        mostrarSnackBar(
                            Icons.error, 'Ocurrio un error', Colors.red);
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () async {
                      // _cancelarSolicitud(context, solictud);
                      bool respuesta =
                          await dermatologoBloc.cancelarSolicitud(solictud);

                      if (respuesta == true) {
                        Navigator.of(context).pop();
                        mostrarSnackBar(Icons.thumb_up,
                            'Paciente vinculado con éxito', Colors.blue);
                        dermatologoBloc.listarSolicitudes();
                      } else {
                        Navigator.of(context).pop();
                        mostrarSnackBar(
                            Icons.error, 'Ocurrio un error', Colors.red);
                      }
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
            content: Column(mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 60,
                child:
                    Text('¿Desea aceptar la solicitud de ${solicitud.nombre}?'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround, 
                children: [
                  TextButton(
                      child: Text('No',style: TextStyle(color: Color.fromRGBO(143, 148, 251, 6))),
                      onPressed: () => Navigator.of(context).pop()),
                  TextButton(
                      child: Text('Sí',style: TextStyle(color: Color.fromRGBO(143, 148, 251, 6))),
                      onPressed: () async {
                        bool respuesta =
                            await dermatologoBloc.aceptarSolicitud(solicitud);
                        if (respuesta == true) {
                          Navigator.of(context).pop();
                          mostrarSnackBar(Icons.thumb_up,
                              'Paciente vinculado con éxito', Colors.blue);
                          dermatologoBloc.listarSolicitudes();
                        } else {
                          Navigator.of(context).pop();
                          mostrarSnackBar(
                              Icons.error, 'Ocurrio un error', Colors.red);
                        }
                      }),
                ]
              )
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
                    bool respuesta =
                        await dermatologoBloc.cancelarSolicitud(solicitud);

                    if (respuesta == true) {
                      Navigator.of(context).pop();
                      mostrarSnackBar(Icons.thumb_up,
                          'Solicitud cancelada correctamente', Colors.blue);
                      dermatologoBloc.listarSolicitudes();
                    } else {
                      Navigator.of(context).pop();
                      mostrarSnackBar(
                          Icons.error, 'Ocurrio un error', Colors.red);
                    }
                  }),
            ],
          );
        });
  }

  void mostrarSnackBar(IconData icon, String mensaje, Color color) {
    final snackbar = mySnackBar(icon, mensaje, color);
    // ignore: deprecated_member_use
    scaffoldKey.currentState.showSnackBar(snackbar);
  }
}
