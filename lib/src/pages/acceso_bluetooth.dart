import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
class AccesoBluetooth extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suncare'),
      ),
      body: Center(
        child: FutureBuilder(
          future: FlutterBlue.instance.isOn,
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {  
            return AlertDialog(
              title: Text('Bluetooth'),
              content: Text('¿Permitir que Suncare tenga acceso a bluetooth?'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Aceptar'),
                  onPressed: () {
                    print("Entró a bluetooth");
                    if(snapshot.data == true){
                       Navigator.pushNamedAndRemoveUntil(
                            context, 'home', (route) => false);
                       
                    }
                  },
                )
              ],
            );
          }
        ),
      ),
    );
  }
}