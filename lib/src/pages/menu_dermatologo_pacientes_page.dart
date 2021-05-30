import 'package:flutter/material.dart';
import 'package:suncare/src/bloc/provider.dart';
import 'package:suncare/src/models/paciente_model.dart';
import 'package:suncare/src/models/solicitud_model.dart';

class MisSolicitudesPage extends StatelessWidget {
  DermatologoBloc dermatologoBloc;

  @override
  Widget build(BuildContext context) {
    dermatologoBloc = Provider.of_DermatologoBloc(context);
    dermatologoBloc.listarSolicitudes();

    return Scaffold(
      appBar: AppBar(
        title: Text('Mis pacientes'),
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
          return Text('lsit de firebase');
        });
  }
}
