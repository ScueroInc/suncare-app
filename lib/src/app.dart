import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:suncare/src/pages/detalle_paciente_page.dart';
import 'package:suncare/src/pages/editar_dermatologo_page.dart';
import 'package:suncare/src/pages/mensaje_dermatologo.dart';
import 'package:suncare/src/pages/menu_bluetooth_page.dart';
import 'package:suncare/src/pages/menu_dermatologo_pacientes_page.dart';
// import 'package:suncare/src/bloc/provider.dart';
import 'package:suncare/src/pages/home_dermatologo_page.dart';
import 'package:suncare/src/pages/home_page.dart';
import 'package:suncare/src/pages/loading_page.dart';
import 'package:suncare/src/pages/login_page.dart';
import 'package:suncare/src/pages/menu_edit_page.dart';
import 'package:suncare/src/pages/menu_mensaje_usuario.page.dart';
import 'package:suncare/src/pages/menu_perfil_dermatologo_page.dart';
import 'package:suncare/src/pages/menu_perfil_page.dart';
// import 'package:suncare/src/pages/menu_vestimenta_page.dart';
import 'package:suncare/src/pages/menu_vinculacion.dart';
import 'package:suncare/src/pages/recuperar_contrasena_page.dart';
import 'package:suncare/src/pages/registro_dermatologo_page.dart';
import 'package:suncare/src/pages/registro_page.dart';
import 'package:suncare/src/pages/registro_usuario_page.dart';
import 'package:suncare/src/pages/menu_solicitud_pendiente_page.dart';
import 'package:suncare/src/pages/acceso_bluetooth.dart';
import 'package:suncare/src/widgets/administrarCuenta.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: MaterialApp(
            theme: ThemeData(primarySwatch: Colors.amber),
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate
            ],
            supportedLocales: [
              const Locale('en', 'US'),
              const Locale('es', 'ES'),
            ],
            title: 'App',
            // initialRoute: 'login',
            // home: Center(child: Text('Hola Mundooo ')),
            home: LoadingPage(),
            routes: {
              'login': (BuildContext context) => LoginPage(),
              'registro': (BuildContext context) => RegistroPage(),
              'recuperarContraseña': (BuildContext context) =>
                  RecuperarContrasenaPage(),
              'goUsuario': (BuildContext context) => RegistroUsuarioPage(),
              'mensaje': (BuildContext context) => MenuMensajeUsuario(),
              'detalle_paciente': (BuildContext context) =>
                  DetallePacientePage(),
              'goDermatologo': (BuildContext context) =>
                  RegistroDermatologoPage(),
              'adminitrarCuenta': (BuildContext context) => AdministrarCuenta(),
              'modificarPerfil': (BuildContext context) => MenuEditPage(),
              'modificarPerfilDermatologo': (BuildContext context) =>
                  EditarDermatoloPage(),
              'home': (BuildContext context) => HomePage(),
              // 'vestimenta': (BuildContext context) => MenuVestimenta(),
              'vinculacion': (BuildContext context) => MenuVinculacion(),
              'perfil': (BuildContext context) => MenuPerfil(),
              'perfil_dermatologo': (BuildContext context) =>
                  MenuPerfilDermatologo(),
              'bluetooth': (BuildContext context) => MenuBlueToothPage(),
              'mensaje_dermatologo': (BuildContext context) =>
                  MensajeDermatologo(),
              'missolicitudes': (BuildContext context) => MisSolicitudesPage(),
              'home_dermatologo': (BuildContext context) =>
                  HomeDermatologoPage(),
              'solicitudes': (BuildContext context) => SolicitudPendientePage(),
              'acceso_bluetooth': (BuildContext context) => AccesoBluetooth()
            }));
  }
}
