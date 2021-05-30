import 'package:flutter/material.dart';
import 'package:suncare/src/models/paciente_model.dart';
import 'package:suncare/src/utils/search_busqueda.dart';

class MySearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        width: width,
        child: GestureDetector(
          onTap: () async {
            PacienteModel paciente =
                await showSearch(context: context, delegate: SearchBusqueda());
            print('paciente es ${paciente}');

            if (paciente.id != null) {
              Navigator.pushNamed(context, 'detalle_paciente',
                  arguments: paciente);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            width: double.infinity,
            child: Text(
              '¿Buscar un paciente?',
              style: TextStyle(color: Colors.black87),
            ),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 5))
                ]),
          ),
        ),
      ),
    );
  }
}
