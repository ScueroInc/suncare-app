import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart' as blue;
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:suncare/src/bloc/bluetooth_bloc.dart';
import 'package:suncare/src/widgets/my_snack_bar.dart';
import 'package:suncare/src/widgets/widget_blue.dart';
import 'package:bluetooth_enable/bluetooth_enable.dart';
import 'package:suncare/src/bloc/provider.dart';
import 'dart:async';

class MenuBlueToothPage extends StatelessWidget {
  BluetoothBloc _bluetoothBloc;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    _bluetoothBloc = Provider.of_BluetoothBloc(context);
    enableBT();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text('Bluetooth '),
      ),
      body: bodyReal(),
    );
  }

  Widget floatingView() {
    return StreamBuilder(
      // stream: blue.FlutterBlue.instance.isScanning,
      stream: _bluetoothBloc.buscandoDispositivosStream,
      initialData: false,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.data) {
          return FloatingActionButton(
            child: Icon(Icons.stop),
            onPressed: () => blue.FlutterBlue.instance.stopScan(),
            backgroundColor: Colors.red,
          );
        } else {
          return FloatingActionButton(
              child: Icon(Icons.search), onPressed: () => buscarDivece());
        }
      },
    );
  }

  Widget dispositivoSincronizado() {
    return StreamBuilder(
      stream: _bluetoothBloc.deviceStream,
      // initialData: initialData ,
      builder: (BuildContext context, AsyncSnapshot<BluetoothDevice> snapshot) {
        print('kinkin raa1 ${snapshot.hasData}');
        print('kinkin raa2 ${snapshot.data}');
        if (snapshot.hasData) {
          var device = snapshot.data;
          return Container(
            child: ListTile(
              onTap: () async {
                mostrarSnackBar(
                    Icons.thumb_up,
                    'Sincronización finalizada con éxito',
                    Colors.amber);
                _bluetoothBloc.desincronizar();
              },
              title: Text(device.name ?? "Dispositivo Desconocido"),
              subtitle: Text(device.address),
              leading: Icon(Icons.devices),
            ),
          );
        } else {
          return Container(
            height: 60,
          );
        }
      },
    );
  }

  // dispositivoBuscar
  Widget bodyReal() {
    return StreamBuilder(
      stream: _bluetoothBloc.escuchandoStateBlueStream,
      // initialData: blue.BluetoothState.unknown,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        final state = snapshot.data;
        print('raaaaaa bodyReal ${state}');
        if (state == true) {
          // return listarSacnResultado();

          // return Column(
          //   children: [
          //     Text('Dispositivo sincronizado'),
          //     Container(
          //       width: double.infinity,
          //       child: dispositivoSincronizado(),
          //     ),
          //     Text('Dispositivos encontrados'),
          //     Container(
          //       width: double.infinity,
          //       height: 500,
          //       child: StreamBuilder(
          //         stream: _bluetoothBloc.buscandoDispositivosStream,
          //         // initialData: false,
          //         builder:
          //             (BuildContext context, AsyncSnapshot<bool> snapshot) {
          //           if (snapshot.hasData) {
          //             if (snapshot.data == true) {
          //               return Center(
          //                   child: Column(
          //                       mainAxisAlignment: MainAxisAlignment.center,
          //                       children: [
          //                     CircularProgressIndicator(strokeWidth: 2),
          //                     Text('Buscando Dispositivos')
          //                   ]));
          //             } else {
          //               return listarSacnResultado();
          //             }
          //           }
          //           return Container();
          //         },
          //       ),
          //     )
          //   ],
          // );

          return Stack(
            children: [
              Column(
                children: [
                  Text('Dispositivo sincronizado'),
                  Container(
                    width: double.infinity,
                    child: dispositivoSincronizado(),
                  ),
                  Text('Dispositivos encontrados'),
                  Container(
                    width: double.infinity,
                    height: 500,
                    child: StreamBuilder(
                      stream: _bluetoothBloc.buscandoDispositivosStream,
                      // initialData: false,
                      builder:
                          (BuildContext context, AsyncSnapshot<bool> snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data == true) {
                            return Center(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                  CircularProgressIndicator(strokeWidth: 2),
                                  Text('Buscando dispositivos')
                                ]));
                          } else {
                            return listarSacnResultado();
                          }
                        }
                        return Container();
                      },
                    ),
                  )
                ],
              ),
              Positioned(bottom: 10, right: 10, child: floatingView())
            ],
          );
        } else {
          // encenderBluetooth(context);

          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Necesita encender el bluetooth',
                style: TextStyle(color: Colors.black87),
              ),
              MaterialButton(
                  child: Text(
                    'Encender',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.black,
                  shape: StadiumBorder(),
                  elevation: 1,
                  onPressed: () async {
                    // encenderBluetooth(context);
                    await enableBT();
                  })
            ],
          ));
        }
        // return Center(child: Text('blue apagado'));
      },
    );
  }

  Widget listarSacnResultado() {
    return StreamBuilder(
      stream: _bluetoothBloc.resultScanStream,
      builder: (BuildContext context,
          AsyncSnapshot<List<BluetoothDiscoveryResult>> snapshot) {
        if (snapshot.hasData) {
          var data = snapshot.data;

          // print('--> ${data.device.address}');
          // return Container(child: Text('find: ${data.length}'));
          return ListView.builder(
              itemCount: data.length,
              itemBuilder: (BuildContext context, index) {
                return ListTile(
                    onTap: () async {
                      bool isConectado = await _bluetoothBloc
                          .conectarDevice(data[index].device);
                      if (isConectado) {
                        mostrarSnackBar(
                            Icons.thumb_up,
                            'Sincronización exitosa',
                            Colors.amber);
                        _bluetoothBloc.limpiarLista();
                      } else {
                        mostrarSnackBar(
                            Icons.thumb_down,
                            'Sincronización fallida',
                            Colors.amber);
                      }
                    },
                    title: Text(
                        data[index].device.name ?? "Dispositivo Desconocido"),
                    subtitle: Text(data[index].device.address),
                    leading: Icon(Icons.devices),
                    trailing:
                        Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      data[index].device.isConnected
                          ? Icon(Icons.import_export)
                          : Container(width: 0, height: 0),
                      data[index].device.isBonded
                          ? Icon(Icons.link)
                          : Container(width: 0, height: 0),
                    ]));
              });
        } else {
          return Container(child: Text('0'));
        }
      },
    );
  }

  void buscarDivece() {
    _bluetoothBloc.startDiscovery();
  }

  static TextStyle _computeTextStyle(int rssi) {
    /**/ if (rssi >= -35)
      return TextStyle(color: Colors.greenAccent[700]);
    else if (rssi >= -45)
      return TextStyle(
          color: Color.lerp(
              Colors.greenAccent[700], Colors.lightGreen, -(rssi + 35) / 10));
    else if (rssi >= -55)
      return TextStyle(
          color: Color.lerp(
              Colors.lightGreen, Colors.lime[600], -(rssi + 45) / 10));
    else if (rssi >= -65)
      return TextStyle(
          color: Color.lerp(Colors.lime[600], Colors.amber, -(rssi + 55) / 10));
    else if (rssi >= -75)
      return TextStyle(
          color: Color.lerp(
              Colors.amber, Colors.deepOrangeAccent, -(rssi + 65) / 10));
    else if (rssi >= -85)
      return TextStyle(
          color: Color.lerp(
              Colors.deepOrangeAccent, Colors.redAccent, -(rssi + 75) / 10));
    else
      /*code symetry*/
      return TextStyle(color: Colors.redAccent);
  }

  void mostrarSnackBar(IconData icon, String mensaje, Color color) {
    final snackbar = mySnackBar(icon, mensaje, color);
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  /*void encenderBluetooth(BuildContext context) async {
    print('encenderBluetooth');

    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            title: Text('Encender Bluetooth'),
            actions: [
              TextButton(
                  child: Text('Ok'),
                  onPressed: () async {
                    await enableBT();
                  }),
            ],
          );
        });
    // var x = blue.FlutterBlue.instance.state;
  }*/

  Future<void> enableBT() async {
    BluetoothEnable.enableBluetooth.then((value) {
      print(value);
    });
  }
}
