import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:suncare/src/bloc/connectivity_bloc.dart';
import 'package:suncare/src/bloc/provider.dart';
import 'package:suncare/src/models/paciente_model.dart';
import 'package:suncare/src/preferencias/preferencias_usuario.dart';
import 'package:suncare/src/providers/connectivity_provider.dart';
import 'package:suncare/src/widgets/my_snack_bar.dart';
import 'package:suncare/src/utils/utils.dart' as utils;

class MenuEditPage extends StatefulWidget {
  @override
  _MenuEditPageState createState() => _MenuEditPageState();
}

class _MenuEditPageState extends State<MenuEditPage> {
  ConnectivityBloc _connectivityBloc;
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
  ConnectivityProvider _connectivityProvider = ConnectivityProvider.instance;

  @override
  Widget build(BuildContext context) {
    final PreferenciasUsuario _preferencia = new PreferenciasUsuario();

    _connectivityBloc = Provider.of_ConnectivityBloc(context);
    final idUser = _preferencia.userIdDB;

    pacienteBloc = Provider.of_PacienteBloc(context);
    pacienteBloc.buscarPaciente(idUser);

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text('Modificar perfil'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamed(context, 'perfil');
            }),
        actions: [
          IconButton(
            icon: Icon(Icons.photo_size_select_actual),
            onPressed: () {
              _seleccionarFoto(pacienteBloc);
            },
          ),
          IconButton(
              icon: Icon(Icons.camera_alt),
              onPressed: () {
                _tomarFoto(pacienteBloc);
              }),
        ],
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
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
                    // if (paciente.tipoPiel != null) {
                    //   _tipoDePiel = paciente.tipoPiel;
                    // }
                    print(_preferencia.token);
                    return Form(
                      key: formKey,
                      child: Column(
                        children: <Widget>[
                          _mostrarFoto(pacienteBloc),
                          _mostrarNombre(pacienteBloc),
                          _mostrarApellido(pacienteBloc),
                          _mostrarCorreo(pacienteBloc),
                          // _crearFecha(context),
                          _mostrarNacimiento(),
                          _mostrarTipoPiel(pacienteBloc),
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
            // utils.mostrarInternetConexionWithStream(_connectivityProvider)
            utils.nostrarInternetErrorStream(_connectivityBloc),
          ],
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
          maxLength: 30,
          buildCounter: (BuildContext context,
                  {int currentLength, int maxLength, bool isFocused}) =>
              null,
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
          maxLength: 30,
          buildCounter: (BuildContext context,
                  {int currentLength, int maxLength, bool isFocused}) =>
              null,
          initialValue: paciente.apellido,
          decoration: InputDecoration(
            labelText: 'Apellidos',
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

  Widget _mostrarTipoPiel(PacienteBloc bloc) {
    if (tipoPielChange != null) {
      paciente.tipoPiel = tipoPielChange;
    }
    if (paciente.tipoPiel != null) {
      bloc.changeTipoPiel(tipoPielChange);
    }
    return StreamBuilder(
        stream: bloc.tipoPielStream,
        builder: (context, snapshot) {
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
                bloc.changeTipoPiel(tipoPielChange);
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
        });
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
          builder: (BuildContext ctx, AsyncSnapshot snapshotform) {
            return StreamBuilder(
                stream: _connectivityProvider.connectivityStream,
                initialData: true,
                builder: (context, snapshot) {
                  var isConnected = snapshot.data;
                  if (isConnected != null) {
                    if (isConnected == true) {
                      _connectivityProvider.setShowError(true);
                    }
                  }
                  return RaisedButton(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 80.0, vertical: 15.0),
                      child: Text(
                        'Guardar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    color: Colors.amber[800],
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    onPressed: snapshotform.hasData
                        ? () {
                            // if (isConnected != null) {
                            //   if (isConnected == true) {
                            // mostrarSnackBar(
                            //   Icons.thumb_up,
                            //   'Cambios guardados con éxito',
                            //   Colors.amber,
                            // );

                            //     _submit(context);
                            //   } else {
                            //     _connectivityProvider.setShowError(false);
                            //   }
                            // }
                            if (_connectivityBloc.conectividad == true) {
                              mostrarSnackBar(
                                Icons.thumb_up,
                                'Cambios guardados con éxito',
                                Colors.amber,
                              );
                              _submit(context);
                            } else {
                              _connectivityBloc.setErrorStream(true);
                              // final snackbar = utils.mySnackBarError();
                              // scaffoldKey.currentState.showSnackBar(snackbar);
                            }
                          }
                        : null,
                  );
                });
          },
        ),
        SizedBox(height: 15),
        _crearCancelar(context),
        SizedBox(height: 15),
      ],
    );
  }

  Widget _mostrarFoto(PacienteBloc bloc) {
    return Container(
      color: Colors.amber,
      child: _fotoVista(bloc),
    );
  }

  Widget _fotoVista(PacienteBloc bloc) {
    return StreamBuilder(
      stream: pacienteBloc.imagenPerfilStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.data == null) {
          return FadeInImage(
            placeholder: AssetImage('assets/img/no-image.png'),
            image: paciente.imagenProfile == null
                ? NetworkImage('assets/img/no-image.png')
                : NetworkImage(paciente.imagenProfile),
            fit: BoxFit.contain,
            height: 200.0,
          );
        } else {
          return Image.file(
            snapshot.data,
            height: 200.0,
            fit: BoxFit.cover,
          );
        }
      },
    );
  }

  _tomarFoto(PacienteBloc bloc) async {
    _procesarImagen(ImageSource.camera, bloc);
  }

  _seleccionarFoto(PacienteBloc bloc) async {
    _procesarImagen(ImageSource.gallery, bloc);
  }

  _procesarImagen(ImageSource origen, PacienteBloc bloc) async {
    final _picker = ImagePicker();

    final pickedFile = await _picker.getImage(
        source: origen); //pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      foto = File(pickedFile.path);
      bloc.changeImagenPerfil(foto);
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
    paciente.first = true;
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
      /* child: RaisedButton(
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
      ), */
      child: Container(
          child: RaisedButton(
        child: Text(
          'Cancelar',
          style: TextStyle(color: Colors.white),
        ),
        color: Color.fromRGBO(245, 90, 90, 1),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () {
          // Navigator.pushReplacementNamed(context, 'perfil_dermatologo');
          Navigator.pushReplacementNamed(context, 'perfil');
        },
      )),
    );
  }
}
