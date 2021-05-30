import 'package:flutter/material.dart';
import 'package:suncare/src/bloc/bluetooth_bloc.dart';
import 'package:suncare/src/bloc/data_bloc.dart';
import 'package:suncare/src/bloc/dermatologo_bloc.dart';
import 'package:suncare/src/bloc/login_bloc.dart';
import 'package:suncare/src/bloc/mensaje_bloc.dart';
import 'package:suncare/src/bloc/paciente_bloc.dart';
import 'package:suncare/src/bloc/recuperarContrasena_bloc.dart';
import 'package:suncare/src/bloc/registrarDermatologo_bloc.dart';
import 'package:suncare/src/bloc/registrar_bloc.dart';
import 'package:suncare/src/bloc/validarCmp_bloc.dart';
import 'package:suncare/src/bloc/vinculacion_bloc.dart';
export 'package:suncare/src/bloc/dermatologo_bloc.dart';
export 'package:suncare/src/bloc/login_bloc.dart';
export 'package:suncare/src/bloc/paciente_bloc.dart';

class Provider extends InheritedWidget {
  static Provider _instancia;
  final loginBloc = LoginBloc();
  final registrarBloc = RegistrarBloc();
  final registrarDermatologoBloc = RegistrarDermatologoBloc();
  final recuperarContrasenaBloc = RecuperarContrasenaBloc();
  final pacienteBloc = PacienteBloc();
  final dermatologoBloc = DermatologoBloc();
  final _climaBloc = DataCoreBloc();
  final _bluetoothBloc = BluetoothBloc();
  final _vinculacionBloc = VinculacionBloc();
  final validarCmpBloc = ValidarCmpBloc();
  final mensajesBloc = MensajesBloc();

  factory Provider({Key key, Widget child}) {
    if (_instancia == null) {
      _instancia = new Provider._internal(key: key, child: child);
    }

    return _instancia;
  }

  Provider._internal({Key key, Widget child}) : super(key: key, child: child);

  // Provider({Key key, Widget child}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;

  static LoginBloc of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Provider>().loginBloc;
  }

  static ValidarCmpBloc of_ValidarCmpBloc(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<Provider>()
        .validarCmpBloc;
  }

  static PacienteBloc of_PacienteBloc(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Provider>().pacienteBloc;
  }

  static MensajesBloc of_MensajeBloc(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Provider>().mensajesBloc;
  }

  static RegistrarBloc of_RegistrarBloc(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Provider>().registrarBloc;
  }

  static RecuperarContrasenaBloc of_RecuperarContrasenaBloc(
      BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<Provider>()
        .recuperarContrasenaBloc;
  }

  static RegistrarDermatologoBloc of_RegistrarDermatologoBloc(
      BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<Provider>()
        .registrarDermatologoBloc;
  }

  static DermatologoBloc of_DermatologoBloc(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<Provider>()
        .dermatologoBloc;
  }

  static DataCoreBloc of_DataCoreBloc(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Provider>()._climaBloc;
  }

  static BluetoothBloc of_BluetoothBloc(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<Provider>()
        ._bluetoothBloc;
  }

  static VinculacionBloc of_VinculacionBloc(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<Provider>()
        ._vinculacionBloc;
  }
}
