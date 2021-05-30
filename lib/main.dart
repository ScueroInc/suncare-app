import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:suncare/src/app.dart';
import 'package:suncare/src/preferencias/preferencias_usuario.dart';
// import ''
import 'package:suncare/src/bloc/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  final preferencia = new PreferenciasUsuario();
  await preferencia.initPreferencias();

  runApp(Provider(
    child: MyApp(),
  ));
}
