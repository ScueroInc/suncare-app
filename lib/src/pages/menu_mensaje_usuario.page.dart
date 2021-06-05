import 'package:flutter/material.dart';
import 'package:suncare/src/bloc/paciente_bloc.dart';
import 'package:suncare/src/bloc/provider.dart';
import 'package:suncare/src/models/mensaje_model.dart';
import 'package:suncare/src/providers/connectivity_provider.dart';
import 'package:suncare/src/utils/utils.dart' as utils;

class MenuMensajeUsuario extends StatelessWidget {
  PacienteBloc _pacienteBloc;
  ConnectivityProvider _connectivityProvider;  

  @override
  Widget build(BuildContext context) {
    _pacienteBloc = Provider.of_PacienteBloc(context);
    _connectivityProvider = ConnectivityProvider.instance;
    _pacienteBloc.buscarMensajes();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text('Recomendaciones'),
      ),
      body: Stack(
        children:[
          _listaMensaje(context),
          StreamBuilder(
            stream: _connectivityProvider.connectivityStream ,
            initialData: true,
            builder: (BuildContext context, AsyncSnapshot snapshot){
              var isConnected = snapshot.data;
              if(isConnected != null){
                _connectivityProvider.setShowError(isConnected);
              }
              return utils.mostrarInternetConexionWithStream(_connectivityProvider);
            },
          ), 
        ]
      )
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
