import 'package:flutter/material.dart';
// import 'package:suncare/src/bloc/paciente_bloc.dart';
import 'package:suncare/src/bloc/provider.dart';
import 'package:suncare/src/bloc/registrar_bloc.dart';
import 'package:suncare/src/models/paciente_model.dart';
import 'package:suncare/src/providers/usuario_provider.dart';
import 'package:suncare/src/utils/utils.dart' as utils;
import 'package:suncare/src/widgets/headers.dart';

import '../widgets/my_snack_bar.dart';

class RegistroUsuarioPage extends StatefulWidget {
  @override
  _RegistroUsuarioPageState createState() => _RegistroUsuarioPageState();
}

class _RegistroUsuarioPageState extends State<RegistroUsuarioPage> {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final UsuarioProvider usuarioProvider = new UsuarioProvider();

  PacienteBloc pacienteBloc;
  PacienteModel paciente = new PacienteModel();

  //controller
  TextEditingController _inputFieldDateController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    pacienteBloc = Provider.of_PacienteBloc(context);

    return SafeArea(
        child: Scaffold(
            key: scaffoldKey,
            resizeToAvoidBottomInset: false,
            body: Container(
              padding: EdgeInsets.all(15.0),
              child: _formularioUsuario(context),
              // child: Stack(
              //   children: [
              //     HeaderPico(),
              //     Column(
              //       children: [
              //         Container(
              //           width: double.infinity,
              //           height: 200.0,
              //           child: Text('F'),
              //         ),
              //         SingleChildScrollView(
              //           child: Container(
              //             padding: EdgeInsets.all(15.0),
              //             child: _formularioUsuario(context),
              //           ),
              //         ),
              //       ],
              //     )
              //   ],
              // ),
            )));
  }

  Widget _formularioUsuario(BuildContext context) {
    final bloc = Provider.of_RegistrarBloc(context);
    return Form(
        key: formKey,
        child: Column(
          children: [
            SizedBox(height: 30),
            _titlePage(),
            SizedBox(height: 50),
            _crearNombre(bloc),
            Divider(),
            _crearApellido(bloc),
            Divider(),
            _crearFecha(context),
            Divider(),
            _crearCorreo(bloc),
            Divider(),
            _crearPassword(bloc),
            Divider(),
            // _crearPasswordConfirmacion(),
            SizedBox(height: 5),
            _crearBoton(context, bloc),
            SizedBox(height: 5),
            _crearCancelar(context, bloc),
          ],
        ));
  }

  Widget _titlePage() {
    return Text('Crear Cuenta',
        style:
            TextStyle(fontSize: 28.0, color: Color.fromRGBO(143, 148, 251, 1)));
  }

  Widget _crearNombre(RegistrarBloc bloc) {
    return StreamBuilder(
      stream: bloc.nameStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return TextFormField(
          initialValue: paciente.nombre,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
            icon: Icon(Icons.person),
            labelText: 'Ingrese su nombre',
            errorText: snapshot.error,
          ),
          onSaved: (value) => paciente.nombre = value,
          validator: (value) {
            if (value.length < 3) {
              return 'Ingrese un nombre válido';
            } else if (value.length >= 50) {
              return 'Maximo 50 caracteres';
            } else {
              return null;
            }
          },
          onChanged: (value) => bloc.changeName(value),
        );
      },
    );
  }

  Widget _crearApellido(RegistrarBloc bloc) {
    return StreamBuilder(
        stream: bloc.lastNameStream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return TextFormField(
            initialValue: paciente.apellido,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
              icon: Icon(Icons.person),
              labelText: 'Ingrese sus apellidos',
              errorText: snapshot.error,
            ),
            onSaved: (value) => paciente.apellido = value,
            validator: (value) {
              if (value.length < 3) {
                return 'Ingrese un apellido válido';
              } else if (value.length >= 50) {
                return 'Maximo 50 caracteres';
              } else {
                return null;
              }
            },
            onChanged: (value) => bloc.changeLastName(value),
          );
        });
  }

  Widget _crearCorreo(RegistrarBloc bloc) {
    return StreamBuilder(
        stream: bloc.emailStream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return TextFormField(
            initialValue: paciente.correo,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
              icon: Icon(Icons.email),
              labelText: 'Ingrese su correo',
              errorText: snapshot.error,
            ),
            onSaved: (value) => paciente.correo = value,
            validator: (value) {
              if (utils.isEmail(value) == true) {
                return null;
              } else {
                return 'Ingrese un correo válido';
              }
            },
            onChanged: (value) => bloc.changeEmail(value),
          );
        });
  }

  Widget _crearFecha(BuildContext context) {
    return TextFormField(
      // initialValue: paciente.nacimiento,
      enableInteractiveSelection: false,
      controller: _inputFieldDateController,
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
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
      paciente.nacimiento =
          '${picked.year..toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      _inputFieldDateController.text = paciente.nacimiento;
    }

    print('la fecha es ${paciente.nacimiento}');
  }

  Widget _crearPassword(RegistrarBloc bloc) {
    return StreamBuilder(
        stream: bloc.passwordStream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return TextFormField(
            initialValue: paciente.password,
            obscureText: true,
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
              icon: Icon(Icons.lock),
              labelText: 'Ingrese una contraseña',
              errorText: snapshot.error,
            ),
            onSaved: (value) => paciente.password = value,
            validator: (value) {
              if (value.isEmpty) {
                return 'Ingrese un password válido';
              } else if (value.length < 8 || value.length > 16) {
                return 'La contraseña debe de tener entre 8 y 16 caracteres';
              } else if (utils.isSpecialCaracter(value) == false) {
                return 'Falta una mayúscula, un caracter especial y o numero';
              } else {
                return null;
              }
            },
            onChanged: (value) => bloc.changePassword(value),
          );
        });
  }

  // Widget _crearPasswordConfirmacion() {
  //   return TextFormField(
  //     initialValue: paciente.password2,
  //     obscureText: true,
  //     decoration: InputDecoration(
  //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
  //       icon: Icon(Icons.lock),
  //       labelText: 'Ingrese una contraseña',
  //     ),
  //     onSaved: (value) => paciente.password2 = value,
  //     validator: (value) {
  //       if (value.length < 6) {
  //         return 'Ingrese un password válido';
  //       } else {
  //         return null;
  //       }
  //     },
  //   );
  // }

  Widget _crearBoton(BuildContext context, RegistrarBloc bloc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StreamBuilder(
            stream: bloc.formValidStream,
            builder: (BuildContext ctx, AsyncSnapshot snapshot) {
              return RaisedButton(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 95.0, vertical: 10.0),
                    child: Text('Registrar', style: TextStyle(fontSize: 18.0)),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 2,
                  color: Color.fromRGBO(143, 148, 251, 1),
                  textColor: Colors.white,
                  onPressed: snapshot.hasData
                      ? () {
                          //_showMesssageDialog('Registro exitoso'); 
                          mostrarSnackBar(Icons.thumb_up,
                              'Cambios guardados con éxito',
                              Color.fromRGBO(143, 148, 251, 6)); 
                          _submit(context);                   
                          bloc.changeName('');
							bloc.changeLastName('');
							bloc.changeEmail('');
							bloc.changePassword('');
                        }
                      : null,
                
              );
            }),
      ],
    );
  }

  Widget _crearCancelar(BuildContext context, RegistrarBloc bloc) {
    return SizedBox(
      width: 300,
      height: 40,
      child: RaisedButton(
        child: Container(
          child: Text('Cancelar', style: TextStyle(fontSize: 18.0)),
        ),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        elevation: 0.0,
        color: Color.fromRGBO(245, 90, 90, 1),
        textColor: Colors.white,
        onPressed: () {
          bloc.changeName('');
          bloc.changeLastName('');
          bloc.changeEmail('');
          bloc.changePassword('');
          // print(bloc.email);
          // Navigator.pushReplacement(
          //     context,
          //     MaterialPageRoute(
          //         builder: (BuildContext context) => super.widget));
          Navigator.pushReplacementNamed(context, 'login');
        },
      ),
    );
  }

  void _showMesssageDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Bienvenido'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Aceptar'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  void _submit(BuildContext context) async {
    if (!formKey.currentState.validate()) return;
    formKey.currentState.save();

    print('correo---> ${paciente.correo}');
    print('password---> ${paciente.password}');
    Map respuestaLogin =
        await usuarioProvider.registrar(paciente.correo, paciente.password);
    print('registrarData: $respuestaLogin');

    if (respuestaLogin['ok'] == true) {
      // Map respuestaPacienteProvider = await paciente
      paciente.id = respuestaLogin['localId'];
      await pacienteBloc.crearPaciente(paciente);
      mostrarSnackBar(Icons.thumb_up, 'Cambios guardados con éxito', Color.fromRGBO(143, 148, 251, 6));
      Navigator.pushReplacementNamed(context, 'login');
    } else {
      // pacienteBloc.crearPaciente(paciente);
      final err = respuestaLogin['mensaje'];
      print('err: ${err}');
      utils.mostrarAlerta(context, 'El correo ya fue registrado');
    }

    print('nombre: ${paciente.nombre}');
    print('apellido: ${paciente.apellido}');
    print('correo: ${paciente.correo}');
    print('password: ${paciente.password}');
  }

  void mostrarSnackBar(IconData icon, String mensaje, Color color) {
      final snackbar = mySnackBar(icon, mensaje, color);
      scaffoldKey.currentState.showSnackBar(snackbar);
  }
}
