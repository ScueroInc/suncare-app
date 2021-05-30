import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:suncare/src/bloc/provider.dart';
import 'package:suncare/src/models/paciente_model.dart';
import 'package:suncare/src/preferencias/preferencias_usuario.dart';
import 'package:suncare/src/widgets/my_snack_bar.dart';

class MenuEditPage extends StatefulWidget {
  @override
  _MenuEditPageState createState() => _MenuEditPageState();
}

class _MenuEditPageState extends State<MenuEditPage> {
  final PreferenciasUsuario _preferencia = new PreferenciasUsuario();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  String dateChange;
  String tipoPielChange;
  TextEditingController _inputFieldDateController = new TextEditingController();
  PacienteModel paciente = new PacienteModel();
  PacienteBloc pacienteBloc;
  File foto;

  String _tipoDePiel;
  List _itemsData = [
    "Tipo I",
    "Tipo II",
    "Tipo III",
    "Tipo IV",
    "Tipo V",
    "Tipo VI",
  ];

  @override
  Widget build(BuildContext context) {
    final PreferenciasUsuario _preferencia = new PreferenciasUsuario();

    final idUser = _preferencia.userIdDB;

    pacienteBloc = Provider.of_PacienteBloc(context);
    pacienteBloc.buscarPaciente(idUser);
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(143, 148, 251, 6),
        title: Text('Modificar perfil'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamed(context, 'perfil');
            }),
        actions: [
          IconButton(
            icon: Icon(Icons.photo_size_select_actual),
            onPressed: _seleccionarFoto,
          ),
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: _tomarFoto,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(left: 16, top: 25, right: 16),
          child: StreamBuilder(
            stream: pacienteBloc.pacienteBuscadoStream,
            builder:
                (BuildContext context, AsyncSnapshot<PacienteModel> snapshot) {
              print('-------0 ${snapshot.data}');
              if (snapshot.hasData) {
                // PacienteModel paciente = snapshot.data;
                print('-------0 ${snapshot.data.tipoPiel}');
                paciente = snapshot.data;
                // if (paciente.tipoPiel != null) {
                //   _tipoDePiel = paciente.tipoPiel;
                // }
                print(_preferencia.token);
                return Form(
                  key: formKey,
                  child: Column(
                    children: <Widget>[
                      _mostrarFoto(),
                      _mostrarNombre(pacienteBloc),
                      _mostrarApellido(pacienteBloc),
                      _mostrarCorreo(pacienteBloc),
                      // _crearFecha(context),
                      _mostrarNacimiento(),
                      _mostrarTipoPiel(),
                      // Text('${_preferencia.token}'),
                      
                      SizedBox(height: 20),
                      _mostrarAcciones(pacienteBloc),
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
    );
  }

  void mostrarSnackBar(IconData icon, String mensaje, Color color) {
    final snackbar = mySnackBar(icon, mensaje, color);
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  Widget _mostrarNombre(PacienteBloc bloc) {
    return StreamBuilder(
      stream: bloc.nameStream,
      initialData: bloc.changeName(paciente.nombre),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return TextFormField(
          initialValue: paciente.nombre,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: 'Nombre',
            errorText: snapshot.error,
          ),
          onSaved: (value) => paciente.nombre = value,
          // onChanged: (value) => bloc.changeName(value),
          validator: (value) {
            if (value.length < 3) {
              return 'Ingrese un nombre válido';
            }
            return null;
          },
          onChanged: (value) => bloc.changeName(value),
        );
      },
    );
  }

  Widget _mostrarApellido(PacienteBloc bloc) {
    return StreamBuilder(
      stream: bloc.lastNameStream,
      initialData: bloc.changeLastName(paciente.apellido),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return TextFormField(
          initialValue: paciente.apellido,
          decoration: InputDecoration(
            labelText: 'Apellido',
            errorText: snapshot.error,
          ),
          onSaved: (value) => paciente.apellido = value,
          onChanged: (value) => bloc.changeLastName(value),
        );
      },
    );
  }

  Widget _mostrarCorreo(PacienteBloc bloc) {
    return StreamBuilder(
      stream: bloc.emailStream,
      initialData: bloc.changeEmail(paciente.correo),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return TextFormField(
          initialValue: paciente.correo,
          decoration: InputDecoration(
            labelText: 'Correo',
            errorText: snapshot.error,
          ),
          onSaved: (value) => paciente.correo = value,
          onChanged: (value) => bloc.changeEmail(value),
        );
      },
    );
  }

  Widget _mostrarNacimiento() {
    print('el naciemiento es ${paciente.nacimiento}');
    if (dateChange == null) {
      _inputFieldDateController.text = paciente.nacimiento;
    } else {
      paciente.nacimiento = dateChange;
      _inputFieldDateController.text = paciente.nacimiento;
    }
    return TextFormField(
      controller: _inputFieldDateController,
      decoration: InputDecoration(labelText: 'Nacimiento'),
      // onSaved: (value) => paciente.nacimiento = value,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        _selectDate(context);
      },
    );
  }

  Widget _crearFecha(BuildContext context) {
    return TextFormField(
      // initialValue: paciente.nacimiento,
      enableInteractiveSelection: false,
      controller: _inputFieldDateController,
      decoration: InputDecoration(
          // border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
          labelText: 'Fecha de nacimiento',
          icon: Icon(Icons.calendar_today)),
      onSaved: (value) => paciente.nacimiento = value,
      validator: (value) {
        print('la fecha es ${paciente.nacimiento}');
        if (paciente.nacimiento != null) {
          return null;
        } else {
          return 'Ingrese una fecha válido';
        }
      },
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        _selectDate(context);
      },
    );
  }

  _selectDate(BuildContext context) async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(1970),
        lastDate: new DateTime.now(),
        locale: Locale('es', 'ES'));
    if (picked != null) {
      print('la fecha picked es ${picked}');
      setState(() {
        paciente.nacimiento =
            '${picked.year..toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
        dateChange = paciente.nacimiento;
        _inputFieldDateController.text = paciente.nacimiento;
      });
    }

    print('la fecha es ${paciente.nacimiento}');
  }

  Widget _mostrarTipoPiel() {
    if (tipoPielChange != null) {
      paciente.tipoPiel = tipoPielChange;
    }
    return DropdownButton(
        hint: Text('Seleccione su tipo de piel'),
        dropdownColor: Colors.white,
        underline: SizedBox(),
        style: TextStyle(color: Colors.black),
        isExpanded: true,
        value: paciente.tipoPiel,
        onChanged: (newvalue) {
          // print(' lili   $value');
          setState(() {
            _tipoDePiel = newvalue;
            tipoPielChange = _tipoDePiel;
            // print(' lili2   $_tipoDePiel');
          });
        },
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

  Widget _mostrarAcciones(PacienteBloc bloc) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StreamBuilder(
          stream: bloc.formValidStream,
          builder: (BuildContext ctx, AsyncSnapshot snapshot) {
            return RaisedButton(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 80.0, vertical: 15.0),
                child: Text(
                  'Guardar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              color: Color.fromRGBO(143, 148, 251, 1),
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              onPressed: snapshot.hasData
                  ? () {
                      mostrarSnackBar(
                        Icons.thumb_up,
                        'Cambios guardados con éxito',
                        Color.fromRGBO(143, 148, 251, 6),
                      );

                      _submit(context);
                    }
                  : null,
            );
          },
        ),
        SizedBox(height: 15),
        _crearCancelar(context),
      ],
    );
  }

  Widget _mostrarFoto() {
    return Container(
      color: Colors.amber,
      child: _fotoVista(),
    );
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

  _tomarFoto() async {
    _procesarImagen(ImageSource.camera);
  }

  _seleccionarFoto() async {
    _procesarImagen(ImageSource.gallery);
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
    // paciente.tipoPiel = _tipoDePiel;
    print('* $_tipoDePiel *');
    print('* ${paciente.tipoPiel} *');

    await pacienteBloc.editarPaciente(paciente);
    print('_submit primeraVez -> ${_preferencia.primeraVez}');
    if (_preferencia.primeraVez == false) {
      print('if ini -> ');
      _preferencia.primeraVez = true;
      print('if fin -> ${_preferencia.primeraVez}');
    }
    // _showMesssageDialog('Cambios Guardados con exito');

    Navigator.pushReplacementNamed(context, 'perfil');
    // mostrarSnackBar('Registro Guardado');
  }

  void _showMesssageDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) {
        // Future.delayed(Duration(seconds: 1000000000), () {
        //   // Navigator.of(context).pop(true);
        // });
        return AlertDialog(
          title: Text('Cambios de perfil'),
          content: Text(message),
          // actions: [
          //   FlatButton(
          //     child: Text(''),
          //     onPressed: () {
          //       Navigator.of(ctx).pop();
          //     },
          //   ),
          // ],
        );
      },
    );
  }

  Widget _crearCancelar(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 45,
      child: RaisedButton(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 80.0, vertical: 15.0),
          child: Text(
            'Cancelar',
            style: TextStyle(color: Colors.white),
          ),
        ),
        color: Color.fromRGBO(245, 90, 90, 1),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () {
          // Navigator.pushReplacementNamed(context, 'perfil_dermatologo');
          Navigator.pushReplacementNamed(context, 'perfil');
        },
      ),
    );
  }
}
