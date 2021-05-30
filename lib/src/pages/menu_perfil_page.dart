import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:suncare/src/bloc/provider.dart';
import 'package:suncare/src/models/paciente_model.dart';
import 'package:suncare/src/preferencias/preferencias_usuario.dart';

class MenuPerfil extends StatefulWidget {
  @override
  _MenuPerfilState createState() => _MenuPerfilState();
}

class _MenuPerfilState extends State<MenuPerfil> {
  final PreferenciasUsuario _preferencia = new PreferenciasUsuario();
  TextEditingController _inputFieldDateController = new TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  bool showPassword = false;
  File foto;

  String _tipoDePiel;
  List<String> _itemsData = [
    'Tipo I',
    'Tipo II',
    'Tipo III',
    'Tipo IV',
    'Tipo V',
    'Tipo VI',
  ];
  
  PacienteModel paciente = new PacienteModel();

  PacienteBloc pacienteBloc;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    print(_preferencia.token);
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    final idUser = _preferencia.userIdDB;

    pacienteBloc = Provider.of_PacienteBloc(context);
    pacienteBloc.buscarPaciente(idUser);
    return Container(
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(143, 148, 251, 6),
          centerTitle: true,
          title: Text('Perfil de usuario'),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                // if (_preferencia.primeraVez)
                Navigator.pushNamed(context, 'home');
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
                Navigator.pushNamed(context, 'modificarPerfil');
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(left: 16, top: 25, right: 16),
            child: StreamBuilder(
              stream: pacienteBloc.pacienteBuscadoStream,
              builder: (BuildContext context,
                  AsyncSnapshot<PacienteModel> snapshot) {
                print('-------0 ${snapshot.data}');
                if (snapshot.hasData) {
                  // PacienteModel paciente = snapshot.data;
                  print('-------0 ${snapshot.data.tipoPiel}');
                  paciente = snapshot.data;
                  if (paciente.tipoPiel != null) {
                    _tipoDePiel = paciente.tipoPiel;
                  }
                  return Form(
                    key: formKey,
                    child: Column(
                      children: <Widget>[
                        _mostrarFoto(),
                        _mostrarNombre(),
                        _mostrarApellido(),
                        _mostrarCorreo(),
                        _mostrarNacimiento(),
                        _mostrarTipoPiel(),
                        SizedBox(height: 20),
                        // _mostrarAcciones(),
                        // _suspenderCuenta()
                      ],
                    ),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ),
      ),
    );
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
      paciente.imagenProfile = null;
    }

    setState(() {});
  }

  Widget _fotoVista() {
    if (paciente.imagenProfile != null) {
      return FadeInImage(
        placeholder: AssetImage('assets/img/no-image.png'),
        image: NetworkImage(paciente.imagenProfile),
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
        initialValue: paciente.nombre,
        enabled: false,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: 'Nombre'),
        onSaved: (value) => paciente.nombre = value);
  }

  Widget _mostrarApellido() {
    return TextFormField(
      initialValue: paciente.apellido,
      enabled: false,
      decoration: InputDecoration(labelText: 'Apellido'),
      onSaved: (value) => paciente.apellido = value,
    );
  }

  Widget _mostrarCorreo() {
    return TextFormField(
      initialValue: paciente.correo,
      enabled: false,
      decoration: InputDecoration(labelText: 'Correo'),
      onSaved: (value) => paciente.correo = value,
    );
  }

  Widget _mostrarNacimiento() {
    print('el naciemiento es ${paciente.nacimiento}');
    _inputFieldDateController.text = paciente.nacimiento;
    return TextField(
      enabled: false,
      controller: _inputFieldDateController,
      decoration: InputDecoration(labelText: 'Nacimiento'),
    );
  }

  Widget _suspenderCuenta() {
    return RaisedButton(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 80.0, vertical: 15.0),
        child: Text(
          'Desactivar cuenta',
          style: TextStyle(color: Colors.white),
        ),
      ),
      color: Color.fromRGBO(245, 90, 90, 1),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () async {
        await _showMesssageDialog('Seguro que quiere desabilitar cuenta?');

        // await _submit(context);
      },
    );
  }

  void _showMesssageDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Suspender Cuenta'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Si'),
            onPressed: () {
              //TODO desabilitar
              // print(_preferencia.token);
              _preferencia.suspenderCuenta(_preferencia.token);
              Navigator.of(ctx).pop();
              Navigator.pushReplacementNamed(context, 'login');
            },
          ),
          FlatButton(
            child: Text('No'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Widget _mostrarTipoPiel() {
    return DropdownButton(
        hint: Text('Seleccione su tipo de piel'),
        dropdownColor: Colors.white,
        underline: SizedBox(),
        style: TextStyle(color: Colors.black),
        isExpanded: true,
        value: _tipoDePiel,
        // onChanged: (value) {
        //   print(' lili   $value');
        //   setState(() {
        //     _tipoDePiel = value;

        //     print(' lili2   $_tipoDePiel');
        //   });
        // },
        onChanged: null,
        items: _itemsData.map((element) {
          return DropdownMenuItem(
            value: element,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(element),
                Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      color: _tipoColorPiel(element, 1),
                    ),
                    Container(
                      width: 18,
                      height: 18,
                      color: _tipoColorPiel(element, 2),
                    ),
                    Container(
                      width: 18,
                      height: 18,
                      color: _tipoColorPiel(element, 3),
                    ),
                    Container(
                      width: 18,
                      height: 18,
                      color: _tipoColorPiel(element, 4),
                    )
                  ],
                ),
              ],
            ),
          );
        }).toList());
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
        ),
      ],
    );
  }

  Future<String> _selectDate2(BuildContext context) async {
    print(' calendario --> ${paciente.nombre}');
    print(' calendario --> ${paciente.apellido}');
    print(' calendario --> ${paciente.correo}');
    print(' calendario --> ${paciente.nacimiento}');

    DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(2020),
        lastDate: new DateTime(2030));
    print('abrir calendario para escoger');

    if (picked != null) {
      _inputFieldDateController.text = picked.toString();
      paciente.nacimiento = picked.toString();
      print(' calendario antiguo ${paciente.nacimiento}');
      print(' picked antiguo ${picked}');

      return picked.toString();
    } else {
      return "--";
    }
  }

  void _submit(BuildContext context) async {
    if (!formKey.currentState.validate()) return;

    formKey.currentState.save();

    if (foto != null) {
      paciente.imagenProfile = await pacienteBloc
          .subirFoto(foto); //productoProvider.subirImagen(foto);
    }

    print('* ${paciente.id} *');
    print('* ${paciente.nombre} *');
    print('* ${paciente.apellido} *');
    print('* ${paciente.correo} *');
    print('* ${paciente.nacimiento} *');
    print('* ${paciente.imagenProfile} *');
    paciente.tipoPiel = _tipoDePiel;
    print('* $_tipoDePiel *');
    print('* ${paciente.tipoPiel} *');

    await pacienteBloc.editarPaciente(paciente);
    print('_submit primeraVez -> ${_preferencia.primeraVez}');
    if (_preferencia.primeraVez == false) {
      print('if ini -> ');
      _preferencia.primeraVez = true;
      print('if fin -> ${_preferencia.primeraVez}');
    }
    Navigator.pushReplacementNamed(context, 'home');
    // mostrarSnackBar('Registro Guardado');
  }

  void mostrarSnackBar(String mensaje) {
    final snackbar = SnackBar(
      content: Text(mensaje),
      duration: Duration(microseconds: 1500),
    );

    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  Widget buildTextField(
      String labelText, String placeholder, bool isPasswordTextField) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
        obscureText: isPasswordTextField ? showPassword : false,
        decoration: InputDecoration(
            suffixIcon: isPasswordTextField
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                    icon: Icon(
                      Icons.remove_red_eye,
                      color: Colors.grey,
                    ),
                  )
                : null,
            contentPadding: EdgeInsets.only(bottom: 3),
            labelText: labelText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: placeholder,
            hintStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            )),
      ),
    );
  }

  Color _tipoColorPiel(String tipo, int tono) {
    Color color;

    switch (tipo) {
      case 'Tipo I':
        if (tono == 1) {
          color = Color(0xfff1dfd1);
        } else if (tono == 2) {
          color = Color(0xffeedacd);
        } else if (tono == 3) {
          color = Color(0xffe5cdbf);
        } else if (tono == 4) {
          color = Color(0xffe3c6b3);
        }
        break;
      case 'Tipo II':
        if (tono == 1) {
          color = Color(0xffe8d5c6);
        } else if (tono == 2) {
          color = Color(0xffedd1b9);
        } else if (tono == 3) {
          color = Color(0xffebc4a9);
        } else if (tono == 4) {
          color = Color(0xffddb191);
        }
        break;
      case 'Tipo III':
        if (tono == 1) {
          color = Color(0xffead4c0);
        } else if (tono == 2) {
          color = Color(0xffe7c8a6);
        } else if (tono == 3) {
          color = Color(0xffe8c79b);
        } else if (tono == 4) {
          color = Color(0xffdeb67f);
        }
        break;
      case 'Tipo IV':
        if (tono == 1) {
          color = Color(0xffe1c5b1);
        } else if (tono == 2) {
          color = Color(0xffddb798);
        } else if (tono == 3) {
          color = Color(0xffd0a37c);
        } else if (tono == 4) {
          color = Color(0xffca9165);
        }
        break;
      case 'Tipo V':
        if (tono == 1) {
          color = Color(0xffc2ab96);
        } else if (tono == 2) {
          color = Color(0xffbca085);
        } else if (tono == 3) {
          color = Color(0xffa98462);
        } else if (tono == 4) {
          color = Color(0xff8f653c);
        }
        break;
      case 'Tipo VI':
        if (tono == 1) {
          color = Color(0xffb29a8f);
        } else if (tono == 2) {
          color = Color(0xff9f8373);
        } else if (tono == 3) {
          color = Color(0xff8c6654);
        } else if (tono == 4) {
          color = Color(0xff724c34);
        }
        break;
      default:
    }
    return color;
  }
}
