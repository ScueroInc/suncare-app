import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:suncare/src/bloc/dermatologo_bloc.dart';
import 'package:suncare/src/bloc/provider.dart';
import 'package:suncare/src/models/dermatologo_model.dart';
import 'package:suncare/src/preferencias/preferencias_usuario.dart';

class MenuPerfilDermatologo extends StatefulWidget {
  @override
  _MenuPerfilDermatologoState createState() => _MenuPerfilDermatologoState();
}

class _MenuPerfilDermatologoState extends State<MenuPerfilDermatologo> {
  final PreferenciasUsuario _preferencia = new PreferenciasUsuario();

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();

  File foto;

  DermatologoModel dermatologo = new DermatologoModel();
  DermatologoBloc dermatologoBloc;
  @override
  Widget build(BuildContext context) {
    final idUser = _preferencia.userIdDB;

    dermatologoBloc = Provider.of_DermatologoBloc(context);
    dermatologoBloc.buscarDermatologo(idUser);

    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(143, 148, 251, 6),
          centerTitle: true,
          title: Text('Perfil dermatólogo'),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                // if (_preferencia.primeraVez)
                Navigator.pushNamed(context, 'home_dermatologo');
              }),
          actions: [
            // IconButton(
            //   icon: Icon(Icons.photo_size_select_actual),
            //   onPressed: _seleccionarFoto,
            // ),
            // IconButton(
            //   icon: Icon(Icons.camera_alt),
            //   onPressed: _tomarFoto,
            // ),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.pushNamed(context, 'modificarPerfilDermatologo');
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(left: 16, top: 25, right: 16),
            child: StreamBuilder(
              stream: dermatologoBloc.dermatologoBuscadoStream,
              builder: (BuildContext context,
                  AsyncSnapshot<DermatologoModel> snapshot) {
                print('-------0 ${snapshot.data}');
                if (snapshot.hasData) {
                  // PacienteModel paciente = snapshot.data;
                  dermatologo = snapshot.data;

                  return Form(
                    key: formKey,
                    child: Column(
                      children: <Widget>[
                        _mostrarFoto(),
                        _mostrarNombre(),
                        _mostrarApellido(),
                        _mostrarCorreo(),
                        _mostrarCmp(),
                        // _mostrarNacimiento(),
                        // _mostrarNacimiento(),
                        SizedBox(height: 20),
                        // _mostrarAcciones()
                      ],
                    ),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ));
  }

  Widget _mostrarFoto() {
    return Container(
      color: Colors.amber,
      child: _fotoVista(),
    );
  }

  _seleccionarFoto() async {
    _procesarImagen(ImageSource.gallery);
  }

  _tomarFoto() async {
    _procesarImagen(ImageSource.camera);
  }

  _procesarImagen(ImageSource origen) async {
    final _picker = ImagePicker();

    final pickedFile = await _picker.getImage(
        source: origen); //pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      foto = File(pickedFile.path);
      dermatologo.imagenProfile = null;
    }

    setState(() {});
  }

  Widget _fotoVista() {
    if (dermatologo.imagenProfile != null) {
      return FadeInImage(
        placeholder: AssetImage('assets/img/no-image.png'),
        image: NetworkImage(dermatologo.imagenProfile),
        fit: BoxFit.contain,
        height: 200.0,
      );
    } else {
      return foto == null
          ? Image(
              image: AssetImage('assets/img/no-image.png'),
              height: 200.00,
              fit: BoxFit.cover,
            )
          : Image.file(
              foto,
              height: 200.0,
              fit: BoxFit.cover,
            );
    }
  }

  Widget _mostrarNombre() {
    return TextFormField(
        initialValue: dermatologo.nombre,
        enabled: false,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: 'Nombre'),
        onSaved: (value) => dermatologo.nombre = value);
  }

  Widget _mostrarApellido() {
    return TextFormField(
      initialValue: dermatologo.apellido,
      enabled: false,
      decoration: InputDecoration(labelText: 'Apellido'),
      onSaved: (value) => dermatologo.apellido = value,
    );
  }

  Widget _mostrarCorreo() {
    return TextFormField(
      enabled: false,
      initialValue: dermatologo.correo,
      decoration: InputDecoration(labelText: 'Correo'),
      onSaved: (value) => dermatologo.correo = value,
    );
  }

  Widget _mostrarCmp() {
    return TextFormField(
      enabled: false,
      initialValue: dermatologo.codigo,
      decoration: InputDecoration(labelText: 'CMP'),
    );
  }

  Widget _mostrarNacimiento() {
    return TextFormField(
      enabled: false,
      initialValue: dermatologo.nacimiento,
      decoration: InputDecoration(labelText: 'Nacimiento'),
    );
  }

  Widget _mostrarAcciones() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // RaisedButton(
        //   child: Text('Cancelar'),
        //   elevation: 2,
        //   shape:
        //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        //   onPressed: () {},
        // ),
        RaisedButton(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 80.0, vertical: 15.0),
            child: Text(
              'Guardar',
              style: TextStyle(color: Colors.white),
            ),
          ),
          color: Color.fromRGBO(143, 148, 251, 1),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          onPressed: () async {
            await _submit(context);
          },
        )
      ],
    );
  }

  void _submit(BuildContext context) async {
    if (!formKey.currentState.validate()) return;

    formKey.currentState.save();

    if (foto != null) {
      dermatologo.imagenProfile = await dermatologoBloc
          .subirFoto(foto); //productoProvider.subirImagen(foto);
    }

    await dermatologoBloc.editarDermatologo(dermatologo);
    print('_submit primeraVez -> ${_preferencia.primeraVez}');
    if (_preferencia.primeraVez == false) {
      print('if ini -> ');
      _preferencia.primeraVez = true;
      print('if fin -> ${_preferencia.primeraVez}');
    }
    Navigator.pushReplacementNamed(context, 'perfil_dermatologo');
    // mostrarSnackBar('Registro Guardado');
  }
}
