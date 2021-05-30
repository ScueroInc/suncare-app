import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:suncare/src/bloc/mensaje_bloc.dart';
import 'package:suncare/src/bloc/paciente_bloc.dart';
import 'package:suncare/src/bloc/provider.dart';
import 'package:suncare/src/models/paciente_model.dart';
import 'package:suncare/src/models/solicitud_model.dart';
import 'package:suncare/src/widgets/my_snack_bar.dart';

class DetallePacientePage extends StatelessWidget {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  PacienteBloc _pacienteBloc;
  DermatologoBloc _dermatologoBloc;
  PacienteModel pacienteArgument;
  MensajesBloc _mensajesBloc;
  String miMensaje = '';
  Size size;
  @override
  Widget build(BuildContext context) {
    _pacienteBloc = Provider.of_PacienteBloc(context);
    _dermatologoBloc = Provider.of_DermatologoBloc(context);
    _mensajesBloc = Provider.of_MensajeBloc(context);

    size = MediaQuery.of(context).size;

    pacienteArgument = ModalRoute.of(context).settings.arguments;
    print(pacienteArgument.id);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(143, 148, 251, 6),
        title: Text('Detalle'),
      ),
      body: contenido(),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.message),
          backgroundColor: Color.fromRGBO(143, 148, 251, 6),
          onPressed: () => crearMensaje(context, _mensajesBloc)),
    );
  }

  Widget contenido() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20.0),
        width: size.width,
        child: Column(
          children: [
            Container(
              width: size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 3.0,
                      offset: Offset(0.0, 5.0),
                      spreadRadius: 3.0),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      '${pacienteArgument.nombre}',
                      style: TextStyle(fontSize: 20),
                    ),
                    subtitle: Text('Nombre'),
                  ),
                  ListTile(
                    title: Text(
                      '${pacienteArgument.apellido}',
                      style: TextStyle(fontSize: 20),
                    ),
                    subtitle: Text('Apellido'),
                  ),
                  ListTile(
                    title: Text(
                      '${pacienteArgument.miEdad()}',
                      style: TextStyle(fontSize: 20),
                    ),
                    subtitle: Text('Edad'),
                  ),
                  ListTile(
                    title: Text(
                      '${pacienteArgument.tipoPiel}',
                      style: TextStyle(fontSize: 20),
                    ),
                    subtitle: Text('Tipo de piel'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Evolución',
              style: TextStyle(fontSize: 35),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 3.0,
                      offset: Offset(0.0, 5.0),
                      spreadRadius: 3.0),
                ],
              ),
              width: size.width,
              height: size.height * 0.62,
              child: Column(
                children: [
                  Text('--'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void crearMensaje(BuildContext context, MensajesBloc bloc) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            title: Text('Nuevo Mensaje'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: 160,
                  child: TextFormField(
                    initialValue: miMensaje,
                    minLines: 5,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      icon: Icon(Icons.mail),
                      border: InputBorder.none,
                      hintText: 'Mensaje',
                    ),
                    onChanged: (value) => miMensaje = value,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FlatButton(
                        child: Text('Cancelar',
                            style: TextStyle(
                                color: Color.fromRGBO(143, 148, 251, 6))),
                        onPressed: () => Navigator.of(context).pop()),
                    FlatButton(
                        child: Text('Enviar',
                            style: TextStyle(
                                color: Color.fromRGBO(143, 148, 251, 6))),
                        onPressed: () async {
                          bool respuesta = await _dermatologoBloc.crearMensaje(
                              pacienteArgument.id, miMensaje);
                          if (respuesta) {
                            mostrarSnackBar(
                                Icons.thumb_up, 'Mensaje enviado', Colors.blue);
                            Navigator.pushReplacementNamed(
                                context, 'mensaje_dermatologo');
                          } else {
                            mostrarSnackBar(
                                Icons.error, 'Ocurrió un error', Colors.red);
                          }
                        })
                  ],
                )
              ],
            ),
          );
        });
  }

  void mostrarSnackBar(IconData icon, String mensaje, Color color) {
    final snackbar = mySnackBar(icon, mensaje, color);
    scaffoldKey.currentState.showSnackBar(snackbar);
  }
}
