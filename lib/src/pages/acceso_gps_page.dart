import 'dart:html';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AccesoGpsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text('Es necesario el GPS para usar esta app'),
            MaterialButton(
              child: Text('Solicitar Acceso'),
              onPressed: () async {
                final status = await Permission.location.request();
                accesoGPS(status);
              },
            )
          ],
        ),
      ),
    );
  }

  void accesoGPS(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        // navegar
        break;
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
      case PermissionStatus.permanentlyDenied:
        openAppSettings();
        break;
      case PermissionStatus.undetermined:
        break;
      case PermissionStatus.limited:
        break;
    }
  }
}
