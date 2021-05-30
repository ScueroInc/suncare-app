import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:suncare/src/widgets/widget_blue.dart';
import 'dart:async';

class MenuBlueToothPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var f = FlutterBlue.instance.state;
    print('f');
    print(f.listen((event) {
      print(event);
    }));
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth '),
      ),
      body: StreamBuilder(
        stream: FlutterBlue.instance.state,
        initialData: BluetoothState.unknown,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          final state = snapshot.data;
          if (state == BluetoothState.on) {
            return Center(child: Text('blue encendido'));
          }
          return Center(child: Text('blue apagado'));
        },
      ),
      floatingActionButton: StreamBuilder(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () => FlutterBlue.instance
                    .startScan(timeout: Duration(seconds: 4)));
          }
        },
      ),
    );
  }
}
