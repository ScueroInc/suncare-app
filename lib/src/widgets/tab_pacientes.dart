import 'package:flutter/material.dart';
import 'package:suncare/src/bloc/data_bloc.dart';
import 'package:suncare/src/bloc/provider.dart';
import 'package:suncare/src/models/paciente_model.dart';
import 'package:suncare/src/models/solicitud_model.dart';
import 'package:suncare/src/widgets/searchbar.dart';

class Tab_Pacientes extends StatelessWidget {
  DermatologoBloc dermatologoBloc;

  @override
  Widget build(BuildContext context) {
    dermatologoBloc = Provider.of_DermatologoBloc(context);
    dermatologoBloc.listarPacientes();

    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(top: 55),
          child: _listaPaciente(context),
        ),
        Positioned(top: 10, child: MySearchBar())
      ],
    );
  }

  _listaPaciente(BuildContext context) {
    return StreamBuilder(
        stream: dermatologoBloc.misPacientesStream,
        builder: (BuildContext context,
            AsyncSnapshot<List<PacienteModel>> snapshot) {
          if (snapshot.hasData) {
            final solicitud = snapshot.data;

            return ListView.builder(
                itemCount: solicitud.length,
                itemBuilder: (context, i) => _crearItem(context, solicitud[i]));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget _crearItem(BuildContext context, PacienteModel paciente) {
    return Dismissible(
      key: UniqueKey(),
      background: Container(color: Colors.red),
      onDismissed: (direccion) {
        // productoProvider.eliminarProducto(producto.id);
        // productoBloc.borrarProducto(producto.id);
        print('eliminar');
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
              trailing: IconButton(
                icon: Icon(Icons.message),
                onPressed: () {
                  Navigator.pushNamed(context, 'mensaje_dermatologo',
                      arguments: paciente.id);
                },
              ),
              onTap: () => clickCard(context, paciente),
            )
          ],
        ),
      ),
    );
  }

  void clickCard(BuildContext context, PacienteModel paciente) {
    print('detalle_paciente');
    print(paciente.toJson());
    Navigator.pushNamed(context, 'detalle_paciente', arguments: paciente);
  }
}
