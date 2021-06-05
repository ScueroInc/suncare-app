import 'dart:async';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:suncare/src/bloc/connectivity_bloc.dart';
// import 'package:suncare/src/providers/dermatologo_provider.dart';
import 'package:suncare/src/bloc/provider.dart';
import 'package:suncare/src/bloc/registrarDermatologo_bloc.dart';
import 'package:suncare/src/models/dermatologo_model.dart';
import 'package:suncare/src/models/solicitud_validacion_model.dart';
import 'package:suncare/src/providers/connectivity_provider.dart';
import 'package:suncare/src/providers/usuario_provider.dart';
import 'package:suncare/src/utils/utils.dart' as utils;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widgets/my_snack_bar.dart';

class RegistroDermatologoPage extends StatefulWidget {
  @override
  _RegistroDermatologoPageState createState() =>
      _RegistroDermatologoPageState();
}

class _RegistroDermatologoPageState extends State<RegistroDermatologoPage> {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  File fotoProfile;
  File fotoDni;
  final UsuarioProvider usuarioProvider = new UsuarioProvider();
  DermatologoBloc dermatologoBloc;
  ConnectivityBloc _connectivityBloc;
  DermatologoModel dermatologo = new DermatologoModel();
  SolicitudValidacionModel solicitudValidacion = new SolicitudValidacionModel();
  RegistrarDermatologoBloc bloc;
  ConnectivityProvider _connectivityProvider = ConnectivityProvider.instance;

  @override
  Widget build(BuildContext context) {
    dermatologoBloc = Provider.of_DermatologoBloc(context);
    bloc = Provider.of_RegistrarDermatologoBloc(context);
    _connectivityBloc = Provider.of_ConnectivityBloc(context);

    return SafeArea(
        child: Scaffold(
      key: scaffoldKey,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(15.0),
              child: _formularioUsuario(context, bloc),
            ),
            utils.mostrarInternetConexionWithStream(_connectivityProvider)
          ],
        ),
      ),
      appBar: AppBar(
          backgroundColor: Colors.amber,
          title: Center(child: Text('Crear cuenta'))),
    ));
  }

  _seleccionarFoto(RegistrarDermatologoBloc bloc) async {
    _procesarImagen(ImageSource.gallery, bloc);
  }

  Widget _mostrarFoto() {
    return Container(
      color: Colors.amber,
      child: _fotoVista(),
    );
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
      return fotoProfile == null
          ? Image(
              image: AssetImage('assets/img/no-image.png'),
              height: 200.00,
              fit: BoxFit.cover,
            )
          : Image.file(
              fotoProfile,
              height: 200.0,
              fit: BoxFit.cover,
            );
    }
  }

  _procesarImagen(ImageSource origen, RegistrarDermatologoBloc bloc) async {
    final _picker = ImagePicker();
    final pickedFile = await _picker.getImage(
        source: origen);
    if (pickedFile != null) {
      fotoProfile = File(pickedFile.path);
      bloc.changeImagenPerfil(fotoProfile);
      dermatologo.imagenProfile = null;
    }
    setState(() {});
  }

  _seleccionarDNI(RegistrarDermatologoBloc bloc) async {
    _procesarImagenDNI(ImageSource.gallery, bloc);
  }

  _procesarImagenDNI(ImageSource origen, RegistrarDermatologoBloc bloc) async {
    final _picker = ImagePicker();
    final pickedFile = await _picker.getImage(source: origen);
    if (pickedFile != null) {
      fotoDni = File(pickedFile.path);
      bloc.changeImagenDni(fotoDni);
      dermatologo.imagenDni = null;
    }
    setState(() {});
  }

  Widget _formularioUsuario(BuildContext context, bloc) {
    return Form(
        key: formKey,
        child: Container(
          child: Column(
            children: [
              _crearNombre(bloc),
              SizedBox(height: 10),
              _crearApellido(bloc),
              SizedBox(height: 10),
              _crearCodigo(bloc),
              SizedBox(height: 10),
              _crearCorreo(bloc),
              SizedBox(height: 10),
              _crearPassword(bloc),
              SizedBox(height: 10),
              _crearimagenCarnet(bloc),
              SizedBox(height: 10),
              _crearimagenDni(bloc),
              SizedBox(height: 10),
              _crearBoton(context, bloc),
              SizedBox(height: 5),
              _crearCancelar(context, bloc)
            ],
          ),
        ));
  }

  Widget _titlePage() {
    return Center(
      child: Text('Crear cuenta',
          style: TextStyle(fontSize: 28.0, color: Colors.amber)),
    );
  }

  Widget _crearNombre(RegistrarDermatologoBloc bloc) {
    return StreamBuilder(
      stream: bloc.nameStream,
      builder:
          (BuildContext context, AsyncSnapshot snapshot) {
            return TextFormField(
              maxLength: 30,
              buildCounter:
                  (BuildContext context, {int currentLength, int maxLength, bool isFocused}) => null,
                  initialValue: dermatologo.nombre,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(border:OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
                    icon: Icon(Icons.person),
                    labelText: 'Ingrese su nombre',
                    errorText: snapshot.error,
                  ),
                  onSaved: (value) => dermatologo.nombre = value,
                  validator: (value) {
                    if (value.length < 3) {
                      return 'Ingrese un nombre válido';
                    } else {
                      return null;
                    }
                  },
              onChanged: (value) => bloc.changeName(value),
            );
          },
    );
  }

  Widget _crearApellido(RegistrarDermatologoBloc bloc) {
    return StreamBuilder(
      stream: bloc.lastNameStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return TextFormField(
          maxLength: 30,
          buildCounter: (BuildContext context,
                  {int currentLength, int maxLength, bool isFocused}) =>
              null,
          initialValue: dermatologo.apellido,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
            icon: Icon(Icons.person),
            labelText: 'Ingrese sus apellidos',
            errorText: snapshot.error,
          ),
          onSaved: (value) => dermatologo.apellido = value,
          validator: (value) {
            if (value.length < 3) {
              return 'Ingrese un apellido válido';
            } else {
              return null;
            }
          },
          onChanged: (value) => bloc.changeLastName(value),
        );
      },
    );
  }

  Widget _crearCodigo(RegistrarDermatologoBloc bloc) {
    return StreamBuilder(
      stream: bloc.cmpStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return TextFormField(
          initialValue: dermatologo.codigo,
          textCapitalization: TextCapitalization.sentences,
          inputFormatters: [new LengthLimitingTextInputFormatter(6),FilteringTextInputFormatter.digitsOnly],
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
            icon: Icon(Icons.person),
            labelText: 'Ingrese su CMP',
            errorText: snapshot.error,
          ),
          onSaved: (value) => dermatologo.codigo = value,
          validator: (value) {
            if (value.length < 6) {
              return 'Ingrese un CMP válido';
            } else{
            if(utils.isCMP(value)==false){
              return 'El CMP debe contener solo números';
            } else {
              return null;
            }
            }
          },
          onChanged: (value) => bloc.changeCmp(value),
        );
      },
    );
  }

  Widget _crearCorreo(RegistrarDermatologoBloc bloc) {
    return StreamBuilder(
      stream: bloc.emailStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return TextFormField(
          initialValue: dermatologo.correo,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
            icon: Icon(Icons.email),
            labelText: 'Ingrese su correo',
            errorText: snapshot.error,
          ),
          onSaved: (value) => dermatologo.correo = value,
          validator: (value) {
            if (utils.isEmail(value) == true) {
              return null;
            } else {
              return 'Ingrese un correo válido';
            }
          },
          onChanged: (value) => bloc.changeEmail(value),
        );
      },
    );
  }

  Widget _crearPassword(RegistrarDermatologoBloc bloc) {
    return StreamBuilder(
      stream: bloc.passwordStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return TextFormField(
          initialValue: dermatologo.password,
          obscureText: true,
          decoration: InputDecoration(
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
            icon: Icon(Icons.lock),
            labelText: 'Ingrese una contraseña',
            errorText: snapshot.error,
          ),
          onSaved: (value) => dermatologo.password = value,
          validator: (value) {
            if (value.length < 6) {
              return 'Ingrese un password válido';
            } else {
              return null;
            }
          },
          onChanged: (value) => bloc.changePassword(value),
        );
      },
    );
  }

  Widget _crearimagenCarnet(RegistrarDermatologoBloc bloc) {
    return StreamBuilder(
        stream: bloc.imagenPerfilStream,
        builder: (context, snapshot) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Inserte su foto tamaño carnet",
                  style: TextStyle(fontSize: 15)),
              RaisedButton(
                  child: Row(
                    children: [
                      Text("Subir",
                          style: TextStyle(
                              color:
                                  snapshot.hasData ? Colors.amber[800] : null)),
                      SizedBox(width: 10),
                      Icon(Icons.cloud_upload,
                          color: snapshot.hasData ? Colors.amber[800] : null)
                    ],
                  ),
                  onPressed: () {
                    _seleccionarFoto(bloc);
                  })
            ],
          );
        });
  }

  Widget _crearimagenDni(RegistrarDermatologoBloc bloc) {
    return StreamBuilder(
        stream: bloc.imagenDniStream,
        builder: (context, snapshot) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Ingrese foto de su DNI", style: TextStyle(fontSize: 15)),
              RaisedButton(
                  child: Row(
                    children: [
                      Text("Subir",
                          style: TextStyle(
                              color:
                                  snapshot.hasData ? Colors.amber[800] : null)),
                      SizedBox(width: 10),
                      Icon(Icons.cloud_upload,
                          color: snapshot.hasData ? Colors.amber[800] : null)
                    ],
                  ),
                  onPressed: () {
                    _seleccionarDNI(bloc);
                  })
            ],
          );
        });
  }

  Widget _crearBoton(BuildContext context, RegistrarDermatologoBloc bloc) {
    return StreamBuilder(
        stream: bloc.formValidStreamWithPhoto,
        builder: (BuildContext ctx, AsyncSnapshot snapshotform) {
          print('registrar estado');
          print(snapshotform.hasData);
          return StreamBuilder<Object>(
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 95.0, vertical: 10.0),
                    child: Text('Registrar', style: TextStyle(fontSize: 18.0)),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 0.0,
                  color: Colors.amber,
                  textColor: Colors.white,
                  onPressed: snapshotform.hasData
                      ? () {

                          if (_connectivityBloc.conectividad == true) {
                            _submit(context);
                          } else {
                            _connectivityProvider.setShowError(false);
                          }
                        }
                      : null,
                );
              });
        });
  }

  Widget _crearCancelar(BuildContext context, RegistrarDermatologoBloc bloc) {
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
          // Navigator.pushNamed(context, 'login');
          bloc.changeName('');
          bloc.changeLastName('');
          bloc.changeCmp('');
          bloc.changeEmail('');
          bloc.changePassword('');
          bloc.changeImagenPerfil(null);
          bloc.changeImagenDni(null);
          Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
        },
      ),
    );
  }

  void mostrarSnackBar(IconData icon, String mensaje, Color color) {
    final snackbar = mySnackBar(icon, mensaje, color);
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  void _showMesssageDialog(BuildContext context, String message) {
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
              Navigator.pushNamed(context, 'login');
            },
          )
        ],
      ),
    );
  }

  void _submit(BuildContext context) async {
    if (!formKey.currentState.validate()) return;
    formKey.currentState.save();

    if (fotoProfile != null) {
      dermatologo.imagenProfile = await dermatologoBloc.subirFoto(fotoProfile);
    }
    if (fotoDni != null) {
      dermatologo.imagenDni = await dermatologoBloc.subirFoto(fotoDni);
    }

    Map respuestaLogin = await usuarioProvider.registrar(
        dermatologo.correo, dermatologo.password);
    print('registrarData: $respuestaLogin');

    solicitudValidacion.estadoSolicitud = "pendiente";
    DateTime now = DateTime.now();
    solicitudValidacion.fechaSolicitud = DateFormat('yyyy-MM-dd').format(now);

    if (respuestaLogin['ok'] == true) {
      dermatologo.id = respuestaLogin['localId'];
      await dermatologoBloc.crearDermatologo(dermatologo, solicitudValidacion);
      await usuarioProvider.enviarVerificacionPorCorreo(dermatologo.correo);

      bloc.changeName('');
      bloc.changeLastName('');
      bloc.changeCmp('');
      bloc.changeEmail('');
      bloc.changePassword('');
      bloc.changeImagenPerfil(null);
      bloc.changeImagenDni(null);
      mostrarSnackBar(
          Icons.thumb_up,
          'Solicitud de registro enviada. Por favor, revise su correo',
          Colors.amber);
      //Navigator.pushReplacementNamed(context, 'login');
      Timer(Duration(seconds: 2), () {
        Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
      });
    } else {
      final err = respuestaLogin['mensaje'];
      print('err: ${err}');
      utils.mostrarAlerta(context, 'El CMP o correo ya fueron registrados');
    }

    print('nombre: ${dermatologo.nombre}');
    print('apellido: ${dermatologo.apellido}');
    print('correo: ${dermatologo.correo}');
    print('password: ${dermatologo.password}');
    print('imgprofile: ${dermatologo.imagenProfile}');
    print('imgDNI: ${dermatologo.imagenDni}');
  }
}

Future<bool> validarDermatologo(DermatologoModel dermatologo) async {
  var body = {
    "nombres": dermatologo.nombre,
    "apellidos": dermatologo.apellido,
    "cmp": dermatologo.codigo
  };
  var bodyString = json.encode(body);
  final respuesta = await http.post(
      'http://192.168.3.4:3000/api/administrador/validar',
      body: bodyString,
      headers: {
        "Content-type": "application/json",
        "Accept": "application/json"
      });

  final Map<String, dynamic> decodeData = json.decode(respuesta.body);
  print(decodeData);
  return decodeData["respuesta"];
}
