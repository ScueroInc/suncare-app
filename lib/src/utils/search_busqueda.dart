import 'package:flutter/material.dart';
import 'package:suncare/src/bloc/connectivity_bloc.dart';
import 'package:suncare/src/bloc/provider.dart';
import 'package:suncare/src/models/paciente_model.dart';
import 'package:suncare/src/providers/connectivity_provider.dart';
import 'package:suncare/src/utils/utils.dart' as utils;

class SearchBusqueda extends SearchDelegate<PacienteModel> {
  DermatologoBloc dermatologoBloc;
  ConnectivityBloc _connectivityBloc;
  @override
  final String searchFieldLabel;
  ConnectivityProvider _connectivityProvider = ConnectivityProvider.instance;

  SearchBusqueda() : this.searchFieldLabel = 'Buscar...';
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () => this.query = '',
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // retornar algo
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => this.close(context, PacienteModel()),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _listarResultados(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _listarResultados(context);
  }

  Widget _listarResultados(BuildContext context) {
    dermatologoBloc = Provider.of_DermatologoBloc(context);
    _connectivityBloc = Provider.of_ConnectivityBloc(context);
    if (_connectivityBloc.conectividad == true) {
      return FutureBuilder(
        future: dermatologoBloc.buscarPacientesPorNombre(this.query),
        builder: (BuildContext context,
            AsyncSnapshot<List<PacienteModel>> snapshot) {
          if (!snapshot.hasData) {
            return Text("");
          } else {
            var pacientes = snapshot.data;
            if (pacientes.length > 0) {
              return Stack(
                children: [
                  ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, i) =>
                          _crearItem(context, pacientes[i])),
                  StreamBuilder(
                    stream: _connectivityProvider.connectivityStream,
                    initialData: true,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      var isConnected = snapshot.data;
                      if (isConnected != null) {
                        _connectivityProvider.setShowError(isConnected);
                      }
                      return utils.mostrarInternetConexionAnimatedWithStream(
                          _connectivityProvider);
                    },
                  ),
                ],
              );
            } else
              return Center(
                child: Text("¡Paciente no encontrado!",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(181, 181, 181, 1))),
              );
          }
        },
      );
    } else {
      return utils.nostrarInternetError();
      // return Positioned(
      //   right: 0,
      //   left: 0,
      //   top: 0,
      //   height: 24,
      //   child: AnimatedContainer(
      //       curve: Curves.easeInBack,
      //       duration: Duration(milliseconds: 1000),
      //       color: Colors.black38,
      //       child: Row(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: [Text("Error de conexión a Internet")],
      //       )),
      // );
    }
  }

  Widget _crearItem(BuildContext context, PacienteModel paciente) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 30.0,
              child: ClipOval(
                child: FadeInImage(
                  placeholder: AssetImage('assets/img/no-image.png'),
                  image: paciente.imagenProfile == null
                      ? NetworkImage('assets/img/no-image.png')
                      : NetworkImage(paciente.imagenProfile),
                  fit: BoxFit.contain,
                  height: 200.0,
                ),
              ),
            ),
            title: Text(paciente.nombre),
            subtitle: Text(paciente.correo),
            onTap: () => this.close(context, paciente),
          )
        ],
      ),
    );
  }
}
