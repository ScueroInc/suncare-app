import 'package:flutter/material.dart';
import 'package:suncare/src/bloc/paciente_bloc.dart';
import 'package:suncare/src/bloc/provider.dart';
import 'package:suncare/src/models/mensaje_model.dart';

class MenuMensajeUsuario extends StatelessWidget {
  PacienteBloc _pacienteBloc;

  @override
  Widget build(BuildContext context) {
    _pacienteBloc = Provider.of_PacienteBloc(context);
    _pacienteBloc.buscarMensajes();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(143, 148, 251, 6),
        title: Text('Recomendaciones'),
      ),
      body: _listaMensaje(context),
    );
  }

  _listaMensaje(BuildContext context) {
    return StreamBuilder(
      stream: _pacienteBloc.mensajesStream,
      builder:
          (BuildContext context, AsyncSnapshot<List<MensajeModel>> snapshot) {
        if (snapshot.hasData) {
          final mensajes = snapshot.data;
          return ListView.builder(
              itemCount: mensajes.length,
              itemBuilder: (context, i) => _crearItem(context, mensajes[i]));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
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
}
