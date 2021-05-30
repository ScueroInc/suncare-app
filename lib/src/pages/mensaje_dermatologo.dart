import 'package:flutter/material.dart';
import 'package:suncare/src/bloc/dermatologo_bloc.dart';
import 'package:suncare/src/bloc/mensaje_bloc.dart';
import 'package:suncare/src/bloc/provider.dart';
import 'package:suncare/src/models/mensaje_model.dart';
import 'package:suncare/src/models/paciente_model.dart';
import 'package:suncare/src/widgets/my_snack_bar.dart';

class MensajeDermatologo extends StatefulWidget {
  @override
  _MensajeDermatologoState createState() => _MensajeDermatologoState();
}

class _MensajeDermatologoState extends State<MensajeDermatologo> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  MensajesBloc _mensajesBloc;

  DermatologoBloc dermatologoBloc;

  String idUsuario;

  PacienteModel pacienteArgument;

  String miMensaje = '';
  bool show;

  @override
  void initState() {
    show = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dermatologoBloc = Provider.of_DermatologoBloc(context);
    // dermatologoBloc.listarMensajePorUsuario("2aJfwxkXSafcgPEnSvvaR4UX7073");
    _mensajesBloc = Provider.of_MensajeBloc(context);

    idUsuario = ModalRoute.of(context).settings.arguments;

    dermatologoBloc.listarMensajePorUsuario(idUsuario);
    print('** $idUsuario');
    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: scaffoldKey,
      appBar: AppBar(
          backgroundColor: Color.fromRGBO(143, 148, 251, 6),
          title: Text('Mensaje de pacientes')),
      body: SingleChildScrollView(
        child: Column(
          children:[_listaMensaje(context, _mensajesBloc),]
        ),
      ),
      
    );
  }

  _listaMensaje(BuildContext context, MensajesBloc bloc) {
    return Stack(children: <Widget>[
      show
          ? crearMensaje(context, bloc)
          : StreamBuilder(
              stream: dermatologoBloc.mensajePorUsuarioStream,
              builder: (BuildContext context,
                  AsyncSnapshot<List<MensajeModel>> snapshot) {
                if (snapshot.hasData) {
                  final mensajes = snapshot.data;
                  return ListView.builder(
                      itemCount: mensajes.length,
                      itemBuilder: (context, i) =>
                          _crearItem(context, mensajes[i]));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
    ]);
  }

  Widget _crearItem(BuildContext context, MensajeModel mensaje) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(mensaje.mensaje),
            subtitle: Text(mensaje.fecha.substring(0, 16)),
            leading: IconButton(
              icon: Icon(Icons.message),
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }

  Widget crearMensaje(BuildContext context, MensajesBloc bloc) {
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
                      style:
                          TextStyle(color: Color.fromRGBO(143, 148, 251, 6))),
                  onPressed: () => setState(() {
                        show = false;
                      })),
              FlatButton(
                  child: Text('Enviar',
                      style:
                          TextStyle(color: Color.fromRGBO(143, 148, 251, 6))),
                  onPressed: () async {
                    bool respuesta = await dermatologoBloc.crearMensaje(
                        idUsuario, miMensaje);
                        await dermatologoBloc.postNotificacion(idUsuario);
                    (respuesta)
                        ? mostrarSnackBar(
                            Icons.thumb_up, 'Mensaje enviado', Colors.blue)
                        : mostrarSnackBar(
                            Icons.error, 'Ocurrió un error', Colors.red);
                    setState(() {
                      show = false;
                    });
                  })
            ],
          )
        ],
      ),
    );
  }

  void mostrarSnackBar(IconData icon, String mensaje, Color color) {
    final snackbar = mySnackBar(icon, mensaje, color);
    // ignore: deprecated_member_use
    scaffoldKey.currentState.showSnackBar(snackbar);
  }
}
