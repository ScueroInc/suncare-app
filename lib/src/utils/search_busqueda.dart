import 'package:flutter/material.dart';
import 'package:suncare/src/bloc/provider.dart';
import 'package:suncare/src/models/paciente_model.dart';

class SearchBusqueda extends SearchDelegate<PacienteModel> {
  DermatologoBloc dermatologoBloc;
  @override
  final String searchFieldLabel;

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

    return FutureBuilder(
      future: dermatologoBloc.buscarPacientesPorNombre(this.query),
      builder:
          (BuildContext context, AsyncSnapshot<List<PacienteModel>> snapshot) {
        if (!snapshot.hasData) {
          return Text("");
        } else {
          var pacientes = snapshot.data;
          if (pacientes.length > 0) {
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, i) => _crearItem(context, pacientes[i]));
          }
          else  return Center(
            child: Text("¡Paciente no encontrado!",
            style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(181, 181, 181, 1))),
          );
        }
      },
    );
  }

  Widget _crearItem(BuildContext context, PacienteModel paciente) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 30.0,
              child: ClipOval(
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/img/no-image.png',
                  image: NetworkImage(paciente.imagenProfile)!=null ? paciente.imagenProfile : 'assets/img/no-image.png',
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
